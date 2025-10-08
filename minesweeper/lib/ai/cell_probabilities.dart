import '../models/cell.dart';

/// Position on the game board
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col)';
}

/// Represents the probability of a cell containing a mine
class CellProbability {
  /// Position of the cell
  final Position position;

  /// Probability of containing a mine (0.0 - 1.0)
  final double probability;

  /// Confidence level of this probability (0.0 - 1.0)
  final double confidence;

  /// Whether this cell is definitely safe (probability = 0.0)
  bool get isSafe => probability == 0.0;

  /// Whether this cell is definitely a mine (probability = 1.0)
  bool get isMine => probability == 1.0;

  /// Whether this probability is uncertain
  bool get isUncertain => probability > 0.0 && probability < 1.0;

  const CellProbability({
    required this.position,
    required this.probability,
    this.confidence = 1.0,
  });

  @override
  String toString() =>
      'CellProbability(${position.row},${position.col}: ${(probability * 100).toStringAsFixed(1)}%)';
}

/// Pattern detected on the board (for Pattern Sensei dimension)
class DetectedPattern {
  /// Name of the pattern (e.g., "1-2-1", "Corner Lock")
  final String name;

  /// Description of what this pattern means
  final String description;

  /// Cells involved in this pattern
  final List<Position> cells;

  /// Safe moves suggested by this pattern
  final List<Position> safeMoves;

  /// Difficulty level of recognizing this pattern (1-5)
  final int difficulty;

  const DetectedPattern({
    required this.name,
    required this.description,
    required this.cells,
    required this.safeMoves,
    this.difficulty = 1,
  });

  @override
  String toString() => 'Pattern: $name (${cells.length} cells, ${safeMoves.length} safe moves)';
}

/// Analysis result for the entire board
class BoardAnalysisResult {
  /// Probability for each unrevealed cell
  final Map<Position, CellProbability> probabilities;

  /// Cells that are definitely safe
  final List<Position> safeMoves;

  /// Cells that are definitely mines
  final List<Position> definitelyMines;

  /// Detected patterns on the board
  final List<DetectedPattern> patterns;

  /// Overall board solvability (0.0 - 1.0)
  final double solvability;

  /// Time taken for analysis in milliseconds
  final int analysisTimeMs;

  const BoardAnalysisResult({
    required this.probabilities,
    required this.safeMoves,
    required this.definitelyMines,
    this.patterns = const [],
    this.solvability = 0.0,
    this.analysisTimeMs = 0,
  });

  /// Get the best move (lowest probability cell among uncertain cells)
  Position? get bestMove {
    if (safeMoves.isNotEmpty) {
      return safeMoves.first;
    }

    // Find lowest probability among uncertain cells
    CellProbability? bestProb;
    for (final prob in probabilities.values) {
      if (prob.isUncertain) {
        if (bestProb == null || prob.probability < bestProb.probability) {
          bestProb = prob;
        }
      }
    }

    return bestProb?.position;
  }

  /// Get all cells sorted by safety (lowest probability first)
  List<Position> get movesBySafety {
    final allMoves = probabilities.values.toList();
    allMoves.sort((a, b) => a.probability.compareTo(b.probability));
    return allMoves.map((p) => p.position).toList();
  }

  @override
  String toString() {
    return 'BoardAnalysisResult(\n'
        '  Safe moves: ${safeMoves.length}\n'
        '  Definite mines: ${definitelyMines.length}\n'
        '  Patterns: ${patterns.length}\n'
        '  Solvability: ${(solvability * 100).toStringAsFixed(1)}%\n'
        '  Analysis time: ${analysisTimeMs}ms\n'
        ')';
  }
}
