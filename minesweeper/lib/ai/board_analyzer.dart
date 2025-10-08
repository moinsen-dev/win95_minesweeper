import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/game_state.dart';
import 'cell_probabilities.dart';

/// Base class for analyzing Minesweeper boards and calculating probabilities
abstract class BoardAnalyzer {
  /// Analyze the board and return probabilities for all unrevealed cells
  Future<BoardAnalysisResult> analyze(
    List<List<Cell>> board,
    GameState gameState,
    int totalMines,
    int flagsPlaced,
  );

  /// Find all safe moves (cells with 0% mine probability)
  List<Position> findSafeMoves(BoardAnalysisResult result) {
    return result.safeMoves;
  }

  /// Find the best move based on probabilities
  Position? findBestMove(BoardAnalysisResult result) {
    return result.bestMove;
  }

  /// Detect patterns on the board
  List<DetectedPattern> detectPatterns(List<List<Cell>> board);
}

/// Simple probability-based board analyzer
class SimpleBoardAnalyzer extends BoardAnalyzer {
  @override
  Future<BoardAnalysisResult> analyze(
    List<List<Cell>> board,
    GameState gameState,
    int totalMines,
    int flagsPlaced,
  ) async {
    final stopwatch = Stopwatch()..start();

    // Run analysis in compute isolate for better performance
    final result = await compute(
      _analyzeInIsolate,
      _AnalysisParams(
        board: board,
        gameState: gameState,
        totalMines: totalMines,
        flagsPlaced: flagsPlaced,
      ),
    );

    stopwatch.stop();

    return BoardAnalysisResult(
      probabilities: result.probabilities,
      safeMoves: result.safeMoves,
      definitelyMines: result.definitelyMines,
      patterns: detectPatterns(board),
      solvability: result.solvability,
      analysisTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  @override
  List<DetectedPattern> detectPatterns(List<List<Cell>> board) {
    // Simple pattern detection - can be enhanced later
    final patterns = <DetectedPattern>[];

    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        final cell = board[row][col];

        if (!cell.isRevealed || cell.neighborMines == 0) continue;

        // Check for 1-2-1 pattern (common pattern)
        final pattern = _detect121Pattern(board, row, col);
        if (pattern != null) {
          patterns.add(pattern);
        }
      }
    }

    return patterns;
  }

  /// Detect 1-2-1 pattern (horizontal)
  DetectedPattern? _detect121Pattern(List<List<Cell>> board, int row, int col) {
    if (col < 1 || col >= board[row].length - 1) return null;

    final left = board[row][col - 1];
    final center = board[row][col];
    final right = board[row][col + 1];

    if (left.isRevealed &&
        center.isRevealed &&
        right.isRevealed &&
        left.neighborMines == 1 &&
        center.neighborMines == 2 &&
        right.neighborMines == 1) {
      // This is a 1-2-1 pattern
      // The mine is definitely above or below the center
      return DetectedPattern(
        name: '1-2-1 Pattern',
        description: 'Classic horizontal pattern - mine is vertically adjacent to center',
        cells: [
          Position(row, col - 1),
          Position(row, col),
          Position(row, col + 1),
        ],
        safeMoves: _findSafeMovesFor121(board, row, col),
        difficulty: 2,
      );
    }

    return null;
  }

  List<Position> _findSafeMovesFor121(List<List<Cell>> board, int row, int col) {
    final safe = <Position>[];
    // Cells horizontally adjacent to outer 1s are safe
    if (col >= 2 && !board[row][col - 2].isRevealed) {
      safe.add(Position(row, col - 2));
    }
    if (col < board[row].length - 2 && !board[row][col + 2].isRevealed) {
      safe.add(Position(row, col + 2));
    }
    return safe;
  }
}

/// Parameters for isolate-based analysis
class _AnalysisParams {
  final List<List<Cell>> board;
  final GameState gameState;
  final int totalMines;
  final int flagsPlaced;

  _AnalysisParams({
    required this.board,
    required this.gameState,
    required this.totalMines,
    required this.flagsPlaced,
  });
}

/// Result from isolate analysis
class _AnalysisResult {
  final Map<Position, CellProbability> probabilities;
  final List<Position> safeMoves;
  final List<Position> definitelyMines;
  final double solvability;

  _AnalysisResult({
    required this.probabilities,
    required this.safeMoves,
    required this.definitelyMines,
    required this.solvability,
  });
}

/// Perform analysis in an isolate (separate thread)
_AnalysisResult _analyzeInIsolate(_AnalysisParams params) {
  final board = params.board;
  final probabilities = <Position, CellProbability>{};
  final safeMoves = <Position>[];
  final definitelyMines = <Position>[];

  final rows = board.length;
  final cols = board.isEmpty ? 0 : board[0].length;

  // Simple constraint-based analysis
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      final cell = board[row][col];

      // Skip revealed or flagged cells
      if (cell.isRevealed || cell.isFlagged) continue;

      // Calculate probability for this cell
      final prob = _calculateCellProbability(board, row, col, params.totalMines, params.flagsPlaced);

      final cellProb = CellProbability(
        position: Position(row, col),
        probability: prob,
        confidence: prob == 0.0 || prob == 1.0 ? 1.0 : 0.7,
      );

      probabilities[Position(row, col)] = cellProb;

      if (prob == 0.0) {
        safeMoves.add(Position(row, col));
      } else if (prob == 1.0) {
        definitelyMines.add(Position(row, col));
      }
    }
  }

  // Calculate solvability (percentage of cells that can be determined with certainty)
  final totalUnrevealed = probabilities.length;
  final determined = safeMoves.length + definitelyMines.length;
  final solvability = totalUnrevealed > 0 ? determined / totalUnrevealed : 1.0;

  return _AnalysisResult(
    probabilities: probabilities,
    safeMoves: safeMoves,
    definitelyMines: definitelyMines,
    solvability: solvability,
  );
}

/// Calculate probability for a single cell using constraint propagation
double _calculateCellProbability(
  List<List<Cell>> board,
  int row,
  int col,
  int totalMines,
  int flagsPlaced,
) {
  final rows = board.length;
  final cols = board[0].length;

  // Get all adjacent revealed cells
  final adjacentConstraints = <_Constraint>[];

  for (int dr = -1; dr <= 1; dr++) {
    for (int dc = -1; dc <= 1; dc++) {
      if (dr == 0 && dc == 0) continue;

      final r = row + dr;
      final c = col + dc;

      if (r < 0 || r >= rows || c < 0 || c >= cols) continue;

      final adjCell = board[r][c];
      if (adjCell.isRevealed) {
        // Count unrevealed neighbors and flagged neighbors
        int unrevealedCount = 0;
        int flaggedCount = 0;
        bool includesTargetCell = false;

        for (int dr2 = -1; dr2 <= 1; dr2++) {
          for (int dc2 = -1; dc2 <= 1; dc2++) {
            if (dr2 == 0 && dc2 == 0) continue;

            final r2 = r + dr2;
            final c2 = c + dc2;

            if (r2 < 0 || r2 >= rows || c2 < 0 || c2 >= cols) continue;

            final neighbor = board[r2][c2];
            if (r2 == row && c2 == col) {
              includesTargetCell = true;
            }
            if (!neighbor.isRevealed && !neighbor.isFlagged) {
              unrevealedCount++;
            } else if (neighbor.isFlagged) {
              flaggedCount++;
            }
          }
        }

        // Only add constraint if target cell is a neighbor
        if (includesTargetCell) {
          adjacentConstraints.add(_Constraint(
            minesNeeded: adjCell.neighborMines - flaggedCount,
            unrevealedCells: unrevealedCount,
          ));
        }
      }
    }
  }

  if (adjacentConstraints.isEmpty) {
    // No constraints - use global probability
    final totalCells = rows * cols;
    final revealedCount = _countRevealed(board);
    final remainingCells = totalCells - revealedCount - flagsPlaced;
    final remainingMines = totalMines - flagsPlaced;

    if (remainingCells == 0) return 0.0;
    return remainingMines / remainingCells;
  }

  // Apply constraints
  double minProb = 0.0;
  double maxProb = 1.0;

  for (final constraint in adjacentConstraints) {
    if (constraint.unrevealedCells == 0) continue;

    if (constraint.minesNeeded == 0) {
      // All surrounding mines are flagged - this cell is safe
      return 0.0;
    }

    if (constraint.minesNeeded == constraint.unrevealedCells) {
      // All unrevealed cells must be mines - this cell is definitely a mine
      return 1.0;
    }

    // Update probability bounds
    final prob = constraint.minesNeeded / constraint.unrevealedCells;
    minProb = minProb > prob ? minProb : prob;
    maxProb = maxProb < prob ? maxProb : prob;
  }

  // Return average of bounds
  return (minProb + maxProb) / 2;
}

/// Count revealed cells
int _countRevealed(List<List<Cell>> board) {
  int count = 0;
  for (final row in board) {
    for (final cell in row) {
      if (cell.isRevealed) count++;
    }
  }
  return count;
}

/// Constraint from a revealed cell
class _Constraint {
  final int minesNeeded; // Number of mines still needed
  final int unrevealedCells; // Number of unrevealed cells

  _Constraint({
    required this.minesNeeded,
    required this.unrevealedCells,
  });
}
