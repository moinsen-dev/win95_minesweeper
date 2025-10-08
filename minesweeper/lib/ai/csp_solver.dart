import '../models/cell.dart';
import 'cell_probabilities.dart';

/// Represents a constraint in the CSP
class MineConstraint {
  /// Cells involved in this constraint
  final Set<Position> cells;

  /// Number of mines among these cells
  final int mineCount;

  MineConstraint(this.cells, this.mineCount);

  @override
  String toString() => 'Constraint($mineCount mines in ${cells.length} cells)';
}

/// Represents a partial or complete solution
class Solution {
  /// Maps positions to mine assignment (true = mine, false = safe)
  final Map<Position, bool> assignments;

  Solution([Map<Position, bool>? initial])
      : assignments = Map.from(initial ?? {});

  Solution copy() => Solution(assignments);

  int get mineCount => assignments.values.where((v) => v).length;

  @override
  String toString() => 'Solution(${assignments.length} cells, $mineCount mines)';
}

/// Advanced CSP-based Minesweeper solver
class CSPSolver {
  /// Maximum number of solutions to enumerate before stopping
  /// (for performance on large boards)
  final int maxSolutions;

  /// Whether to use early termination for probability estimation
  final bool useEarlyTermination;

  CSPSolver({
    this.maxSolutions = 10000,
    this.useEarlyTermination = true,
  });

  /// Solve the CSP and return all valid mine configurations
  List<Solution> solve({
    required List<MineConstraint> constraints,
    required Set<Position> variables,
    required int totalMinesRemaining,
  }) {
    final solutions = <Solution>[];

    // Build adjacency map for efficient constraint lookup
    final cellToConstraints = <Position, Set<MineConstraint>>{};
    for (final constraint in constraints) {
      for (final cell in constraint.cells) {
        cellToConstraints.putIfAbsent(cell, () => {}).add(constraint);
      }
    }

    // Start backtracking
    _backtrack(
      solution: Solution(),
      constraints: constraints,
      cellToConstraints: cellToConstraints,
      remainingVars: variables.toList(),
      varIndex: 0,
      totalMinesRemaining: totalMinesRemaining,
      solutions: solutions,
    );

    return solutions;
  }

  /// Backtracking search to enumerate all solutions
  bool _backtrack({
    required Solution solution,
    required List<MineConstraint> constraints,
    required Map<Position, Set<MineConstraint>> cellToConstraints,
    required List<Position> remainingVars,
    required int varIndex,
    required int totalMinesRemaining,
    required List<Solution> solutions,
  }) {
    // Early termination if we have enough solutions
    if (useEarlyTermination && solutions.length >= maxSolutions) {
      return true;
    }

    // Base case: all variables assigned
    if (varIndex >= remainingVars.length) {
      // Check global mine constraint
      if (solution.mineCount == totalMinesRemaining) {
        solutions.add(solution.copy());
      }
      return false;
    }

    final currentVar = remainingVars[varIndex];

    // Try assigning mine = false
    if (_isConsistent(solution, currentVar, false, cellToConstraints)) {
      solution.assignments[currentVar] = false;
      final shouldStop = _backtrack(
        solution: solution,
        constraints: constraints,
        cellToConstraints: cellToConstraints,
        remainingVars: remainingVars,
        varIndex: varIndex + 1,
        totalMinesRemaining: totalMinesRemaining,
        solutions: solutions,
      );
      solution.assignments.remove(currentVar);
      if (shouldStop) return true;
    }

    // Try assigning mine = true
    if (_isConsistent(solution, currentVar, true, cellToConstraints)) {
      // Prune if we've already placed too many mines
      if (solution.mineCount + 1 <= totalMinesRemaining) {
        solution.assignments[currentVar] = true;
        final shouldStop = _backtrack(
          solution: solution,
          constraints: constraints,
          cellToConstraints: cellToConstraints,
          remainingVars: remainingVars,
          varIndex: varIndex + 1,
          totalMinesRemaining: totalMinesRemaining,
          solutions: solutions,
        );
        solution.assignments.remove(currentVar);
        if (shouldStop) return true;
      }
    }

    return false;
  }

  /// Check if assigning a value to a variable is consistent with constraints
  bool _isConsistent(
    Solution solution,
    Position variable,
    bool isMine,
    Map<Position, Set<MineConstraint>> cellToConstraints,
  ) {
    final relatedConstraints = cellToConstraints[variable];
    if (relatedConstraints == null) return true;

    for (final constraint in relatedConstraints) {
      // Count assigned mines and unassigned cells in this constraint
      int assignedMines = 0;
      int unassignedCount = 0;

      for (final cell in constraint.cells) {
        final assignment = solution.assignments[cell];
        if (assignment == null) {
          // This is the current variable we're trying to assign
          if (cell == variable) {
            if (isMine) assignedMines++;
          } else {
            unassignedCount++;
          }
        } else if (assignment) {
          assignedMines++;
        }
      }

      // Check if constraint can still be satisfied
      // If we already have too many mines, it's inconsistent
      if (assignedMines > constraint.mineCount) {
        return false;
      }

      // If we need more mines than unassigned cells remaining, it's inconsistent
      final minesNeeded = constraint.mineCount - assignedMines;
      if (minesNeeded > unassignedCount) {
        return false;
      }

      // If all cells are assigned, check if mine count matches exactly
      if (unassignedCount == 0 && assignedMines != constraint.mineCount) {
        return false;
      }
    }

    return true;
  }

  /// Calculate exact probabilities from solutions
  Map<Position, double> calculateProbabilities(
    List<Solution> solutions,
    Set<Position> allVariables,
  ) {
    if (solutions.isEmpty) {
      // No solutions found - return 0.5 (unknown)
      return Map.fromEntries(
        allVariables.map((pos) => MapEntry(pos, 0.5)),
      );
    }

    final mineCounts = <Position, int>{};
    for (final pos in allVariables) {
      mineCounts[pos] = 0;
    }

    // Count how many solutions have each cell as a mine
    for (final solution in solutions) {
      for (final entry in solution.assignments.entries) {
        if (entry.value) {
          mineCounts[entry.key] = (mineCounts[entry.key] ?? 0) + 1;
        }
      }
    }

    // Calculate probabilities
    final probabilities = <Position, double>{};
    for (final pos in allVariables) {
      probabilities[pos] = mineCounts[pos]! / solutions.length;
    }

    return probabilities;
  }
}

/// Extracts constraints from the current board state
class ConstraintExtractor {
  /// Extract all constraints from revealed cells
  static List<MineConstraint> extractConstraints(
    List<List<Cell>> board,
  ) {
    final constraints = <MineConstraint>[];
    final rows = board.length;
    final cols = board.isEmpty ? 0 : board[0].length;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cell = board[row][col];

        // Only revealed cells with numbers create constraints
        if (!cell.isRevealed || cell.neighborMines == 0) continue;

        // Get all unrevealed neighbors
        final unrevealedNeighbors = <Position>{};
        int flaggedNeighbors = 0;

        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;

            final r = row + dr;
            final c = col + dc;

            if (r < 0 || r >= rows || c < 0 || c >= cols) continue;

            final neighbor = board[r][c];
            if (neighbor.isFlagged) {
              flaggedNeighbors++;
            } else if (!neighbor.isRevealed) {
              unrevealedNeighbors.add(Position(r, c));
            }
          }
        }

        // Create constraint if there are unrevealed neighbors
        if (unrevealedNeighbors.isNotEmpty) {
          final minesNeeded = cell.neighborMines - flaggedNeighbors;

          // Skip trivial constraints (though we could handle them separately)
          if (minesNeeded >= 0 && minesNeeded <= unrevealedNeighbors.length) {
            constraints.add(MineConstraint(unrevealedNeighbors, minesNeeded));
          }
        }
      }
    }

    return constraints;
  }

  /// Get all frontier cells (unrevealed cells adjacent to revealed cells)
  static Set<Position> getFrontierCells(List<List<Cell>> board) {
    final frontier = <Position>{};
    final rows = board.length;
    final cols = board.isEmpty ? 0 : board[0].length;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cell = board[row][col];

        if (cell.isRevealed || cell.isFlagged) continue;

        // Check if this unrevealed cell is adjacent to any revealed cell
        bool isAdjacentToRevealed = false;

        for (int dr = -1; dr <= 1 && !isAdjacentToRevealed; dr++) {
          for (int dc = -1; dc <= 1 && !isAdjacentToRevealed; dc++) {
            if (dr == 0 && dc == 0) continue;

            final r = row + dr;
            final c = col + dc;

            if (r < 0 || r >= rows || c < 0 || c >= cols) continue;

            if (board[r][c].isRevealed) {
              isAdjacentToRevealed = true;
            }
          }
        }

        if (isAdjacentToRevealed) {
          frontier.add(Position(row, col));
        }
      }
    }

    return frontier;
  }
}
