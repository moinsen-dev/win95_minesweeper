import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/game_state.dart';
import 'board_analyzer.dart';
import 'cell_probabilities.dart';
import 'csp_solver.dart';

/// Advanced CSP-based board analyzer with exact probability calculation
class AdvancedBoardAnalyzer extends BoardAnalyzer {
  final CSPSolver solver;

  AdvancedBoardAnalyzer({
    int maxSolutions = 10000,
    bool useEarlyTermination = true,
  }) : solver = CSPSolver(
          maxSolutions: maxSolutions,
          useEarlyTermination: useEarlyTermination,
        );

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
      _AdvancedAnalysisParams(
        board: board,
        gameState: gameState,
        totalMines: totalMines,
        flagsPlaced: flagsPlaced,
        maxSolutions: solver.maxSolutions,
        useEarlyTermination: solver.useEarlyTermination,
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
    final patterns = <DetectedPattern>[];
    final rows = board.length;
    final cols = board.isEmpty ? 0 : board[0].length;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cell = board[row][col];

        if (!cell.isRevealed || cell.neighborMines == 0) continue;

        // Detect horizontal 1-2-1 pattern
        final h121 = _detect121Horizontal(board, row, col);
        if (h121 != null) patterns.add(h121);

        // Detect vertical 1-2-1 pattern
        final v121 = _detect121Vertical(board, row, col);
        if (v121 != null) patterns.add(v121);

        // Detect 1-2-2-1 pattern
        final p1221 = _detect1221Pattern(board, row, col);
        if (p1221 != null) patterns.add(p1221);

        // Detect corner patterns
        final corner = _detectCornerPattern(board, row, col);
        if (corner != null) patterns.add(corner);
      }
    }

    return patterns;
  }

  DetectedPattern? _detect121Horizontal(List<List<Cell>> board, int row, int col) {
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
      return DetectedPattern(
        name: '1-2-1 Horizontal',
        description: 'Mine is directly above or below center cell',
        cells: [
          Position(row, col - 1),
          Position(row, col),
          Position(row, col + 1),
        ],
        safeMoves: _findSafeMoves121Horizontal(board, row, col),
        difficulty: 2,
      );
    }

    return null;
  }

  DetectedPattern? _detect121Vertical(List<List<Cell>> board, int row, int col) {
    if (row < 1 || row >= board.length - 1) return null;

    final top = board[row - 1][col];
    final center = board[row][col];
    final bottom = board[row + 1][col];

    if (top.isRevealed &&
        center.isRevealed &&
        bottom.isRevealed &&
        top.neighborMines == 1 &&
        center.neighborMines == 2 &&
        bottom.neighborMines == 1) {
      return DetectedPattern(
        name: '1-2-1 Vertical',
        description: 'Mine is directly left or right of center cell',
        cells: [
          Position(row - 1, col),
          Position(row, col),
          Position(row + 1, col),
        ],
        safeMoves: _findSafeMoves121Vertical(board, row, col),
        difficulty: 2,
      );
    }

    return null;
  }

  DetectedPattern? _detect1221Pattern(List<List<Cell>> board, int row, int col) {
    if (col < 1 || col >= board[row].length - 2) return null;

    final c1 = board[row][col - 1];
    final c2 = board[row][col];
    final c3 = board[row][col + 1];
    final c4 = board[row][col + 2];

    if (c1.isRevealed &&
        c2.isRevealed &&
        c3.isRevealed &&
        c4.isRevealed &&
        c1.neighborMines == 1 &&
        c2.neighborMines == 2 &&
        c3.neighborMines == 2 &&
        c4.neighborMines == 1) {
      return DetectedPattern(
        name: '1-2-2-1 Pattern',
        description: 'Two mines positioned vertically adjacent to middle cells',
        cells: [
          Position(row, col - 1),
          Position(row, col),
          Position(row, col + 1),
          Position(row, col + 2),
        ],
        safeMoves: [],
        difficulty: 3,
      );
    }

    return null;
  }

  DetectedPattern? _detectCornerPattern(List<List<Cell>> board, int row, int col) {
    final cell = board[row][col];
    if (cell.neighborMines != 1) return null;

    // Check if this is a corner configuration
    final rows = board.length;
    final cols = board[row].length;

    // Count unrevealed neighbors
    int unrevealedNeighbors = 0;

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final r = row + dr;
        final c = col + dc;

        if (r < 0 || r >= rows || c < 0 || c >= cols) continue;

        if (!board[r][c].isRevealed && !board[r][c].isFlagged) {
          unrevealedNeighbors++;
        }
      }
    }

    // Corner "1" with only one unrevealed neighbor means that neighbor is a mine
    if (unrevealedNeighbors == 1) {
      return DetectedPattern(
        name: 'Corner Mine',
        description: 'Single unrevealed neighbor of "1" must be a mine',
        cells: [Position(row, col)],
        safeMoves: [],
        difficulty: 1,
      );
    }

    return null;
  }

  List<Position> _findSafeMoves121Horizontal(List<List<Cell>> board, int row, int col) {
    final safe = <Position>[];
    final cols = board[row].length;

    // Cells horizontally adjacent to outer 1s are safe
    if (col >= 2 && !board[row][col - 2].isRevealed) {
      safe.add(Position(row, col - 2));
    }
    if (col < cols - 2 && !board[row][col + 2].isRevealed) {
      safe.add(Position(row, col + 2));
    }

    return safe;
  }

  List<Position> _findSafeMoves121Vertical(List<List<Cell>> board, int row, int col) {
    final safe = <Position>[];
    final rows = board.length;

    // Cells vertically adjacent to outer 1s are safe
    if (row >= 2 && !board[row - 2][col].isRevealed) {
      safe.add(Position(row - 2, col));
    }
    if (row < rows - 2 && !board[row + 2][col].isRevealed) {
      safe.add(Position(row + 2, col));
    }

    return safe;
  }
}

/// Parameters for isolate-based analysis
class _AdvancedAnalysisParams {
  final List<List<Cell>> board;
  final GameState gameState;
  final int totalMines;
  final int flagsPlaced;
  final int maxSolutions;
  final bool useEarlyTermination;

  _AdvancedAnalysisParams({
    required this.board,
    required this.gameState,
    required this.totalMines,
    required this.flagsPlaced,
    required this.maxSolutions,
    required this.useEarlyTermination,
  });
}

/// Result from isolate analysis
class _AdvancedAnalysisResult {
  final Map<Position, CellProbability> probabilities;
  final List<Position> safeMoves;
  final List<Position> definitelyMines;
  final double solvability;

  _AdvancedAnalysisResult({
    required this.probabilities,
    required this.safeMoves,
    required this.definitelyMines,
    required this.solvability,
  });
}

/// Perform CSP analysis in an isolate (separate thread)
_AdvancedAnalysisResult _analyzeInIsolate(_AdvancedAnalysisParams params) {
  final board = params.board;
  final solver = CSPSolver(
    maxSolutions: params.maxSolutions,
    useEarlyTermination: params.useEarlyTermination,
  );

  // Extract constraints from board
  final constraints = ConstraintExtractor.extractConstraints(board);

  // Get frontier cells (unrevealed cells adjacent to revealed ones)
  final frontierCells = ConstraintExtractor.getFrontierCells(board);

  // If no frontier cells, return empty result
  if (frontierCells.isEmpty) {
    return _AdvancedAnalysisResult(
      probabilities: {},
      safeMoves: [],
      definitelyMines: [],
      solvability: 1.0,
    );
  }

  // Segment board into independent regions for better performance
  final segments = _segmentBoard(constraints, frontierCells);

  final allProbabilities = <Position, double>{};
  final allSafeMoves = <Position>[];
  final allDefinitelyMines = <Position>[];

  // Solve each segment independently
  for (final segment in segments) {
    // Calculate mines remaining for this segment
    final minesRemaining = params.totalMines - params.flagsPlaced;

    // Solve CSP for this segment
    final solutions = solver.solve(
      constraints: segment.constraints,
      variables: segment.variables,
      totalMinesRemaining: minesRemaining,
    );

    // Calculate exact probabilities
    final segmentProbs = solver.calculateProbabilities(solutions, segment.variables);

    allProbabilities.addAll(segmentProbs);

    // Find safe moves and definite mines
    for (final entry in segmentProbs.entries) {
      if (entry.value == 0.0) {
        allSafeMoves.add(entry.key);
      } else if (entry.value == 1.0) {
        allDefinitelyMines.add(entry.key);
      }
    }
  }

  // Convert probabilities to CellProbability objects
  final cellProbabilities = <Position, CellProbability>{};
  for (final entry in allProbabilities.entries) {
    cellProbabilities[entry.key] = CellProbability(
      position: entry.key,
      probability: entry.value,
      confidence: 1.0, // CSP gives exact probabilities
    );
  }

  // Calculate solvability
  final totalUnrevealed = frontierCells.length;
  final determined = allSafeMoves.length + allDefinitelyMines.length;
  final solvability = totalUnrevealed > 0 ? determined / totalUnrevealed : 1.0;

  return _AdvancedAnalysisResult(
    probabilities: cellProbabilities,
    safeMoves: allSafeMoves,
    definitelyMines: allDefinitelyMines,
    solvability: solvability,
  );
}

/// Represents a segment of the board
class _BoardSegment {
  final Set<Position> variables;
  final List<MineConstraint> constraints;

  _BoardSegment(this.variables, this.constraints);
}

/// Segment board into independent regions using union-find
List<_BoardSegment> _segmentBoard(
  List<MineConstraint> constraints,
  Set<Position> frontierCells,
) {
  // Build parent map for union-find
  final parent = <Position, Position>{};
  for (final cell in frontierCells) {
    parent[cell] = cell;
  }

  Position find(Position cell) {
    if (parent[cell] != cell) {
      parent[cell] = find(parent[cell]!);
    }
    return parent[cell]!;
  }

  void union(Position a, Position b) {
    final rootA = find(a);
    final rootB = find(b);
    if (rootA != rootB) {
      parent[rootB] = rootA;
    }
  }

  // Union cells that appear in the same constraint
  for (final constraint in constraints) {
    final cells = constraint.cells.toList();
    if (cells.length < 2) continue;

    for (int i = 1; i < cells.length; i++) {
      union(cells[0], cells[i]);
    }
  }

  // Group cells by segment
  final segmentMap = <Position, Set<Position>>{};
  for (final cell in frontierCells) {
    final root = find(cell);
    segmentMap.putIfAbsent(root, () => {}).add(cell);
  }

  // Create segments with their constraints
  final segments = <_BoardSegment>[];
  for (final cellSet in segmentMap.values) {
    final segmentConstraints = constraints
        .where((c) => c.cells.any((cell) => cellSet.contains(cell)))
        .toList();

    segments.add(_BoardSegment(cellSet, segmentConstraints));
  }

  return segments;
}
