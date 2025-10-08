import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/ai/board_analyzer.dart';
import 'package:minesweeper/ai/cell_probabilities.dart';
import 'package:minesweeper/models/cell.dart';
import 'package:minesweeper/models/game_state.dart';

void main() {
  group('BoardAnalyzer', () {
    late SimpleBoardAnalyzer analyzer;

    setUp(() {
      analyzer = SimpleBoardAnalyzer();
    });

    test('detects safe cells correctly', () async {
      // Create a simple 3x3 board with one mine
      // Layout:
      //  1 1 0
      //  1 M 0
      //  0 0 0
      final board = _createBoard(3, 3);

      // Reveal cells around the mine at (1,1)
      board[0][0] = board[0][0].copyWith(isRevealed: true, neighborMines: 1);
      board[0][1] = board[0][1].copyWith(isRevealed: true, neighborMines: 1);
      board[0][2] = board[0][2].copyWith(isRevealed: true, neighborMines: 0);
      board[1][0] = board[1][0].copyWith(isRevealed: true, neighborMines: 1);
      board[1][1] = board[1][1].copyWith(isMine: true); // Mine (unrevealed)
      board[1][2] = board[1][2].copyWith(isRevealed: true, neighborMines: 0);
      board[2][0] = board[2][0].copyWith(isRevealed: true, neighborMines: 0);
      board[2][1] = board[2][1].copyWith(isRevealed: true, neighborMines: 0);
      board[2][2] = board[2][2].copyWith(isRevealed: true, neighborMines: 0);

      final result = await analyzer.analyze(board, GameState.playing, 1, 0);

      // Cell (1,1) should be definitely a mine (probability = 1.0) - it's the only unrevealed cell
      final cell11Prob = result.probabilities[Position(1, 1)];
      expect(cell11Prob?.probability, 1.0);
      expect(result.definitelyMines, contains(Position(1, 1)));
    });

    test('calculates probabilities for uncertain cells', () async {
      // Create a board where some cells have uncertain probabilities
      final board = _createBoard(4, 4);

      // Reveal some cells
      board[0][0] = board[0][0].copyWith(isRevealed: true, neighborMines: 1);
      board[0][1] = board[0][1].copyWith(isRevealed: true, neighborMines: 2);

      final result = await analyzer.analyze(board, GameState.playing, 3, 0);

      // Should have probabilities for unrevealed cells
      expect(result.probabilities.isNotEmpty, true);

      // Probabilities should be between 0 and 1
      for (final prob in result.probabilities.values) {
        expect(prob.probability >= 0.0 && prob.probability <= 1.0, true);
      }
    });

    test('detects 1-2-1 pattern', () async {
      // Create a board with 1-2-1 pattern
      final board = _createBoard(5, 5);

      // Create horizontal 1-2-1 pattern
      board[2][1] = board[2][1].copyWith(isRevealed: true, neighborMines: 1);
      board[2][2] = board[2][2].copyWith(isRevealed: true, neighborMines: 2);
      board[2][3] = board[2][3].copyWith(isRevealed: true, neighborMines: 1);

      final patterns = analyzer.detectPatterns(board);

      // Should detect at least one pattern
      expect(patterns.isNotEmpty, true);

      final pattern121 = patterns.firstWhere(
        (p) => p.name.contains('1-2-1'),
        orElse: () => patterns.first,
      );

      expect(pattern121.cells.length, 3);
    });

    test('finds best move among safe moves', () async {
      final board = _createBoard(3, 3);

      // Reveal some cells, leaving some safe
      board[0][0] = board[0][0].copyWith(isRevealed: true, neighborMines: 0);
      board[0][1] = board[0][1].copyWith(isRevealed: true, neighborMines: 0);

      final result = await analyzer.analyze(board, GameState.playing, 1, 0);

      // Should find safe moves
      expect(result.safeMoves.isNotEmpty, true);

      // Best move should be a safe move
      final bestMove = result.bestMove;
      expect(bestMove, isNotNull);
      expect(result.safeMoves, contains(bestMove));
    });

    test('handles empty board', () async {
      final board = _createBoard(3, 3);

      final result = await analyzer.analyze(board, GameState.ready, 1, 0);

      // Should return probabilities for all cells
      expect(result.probabilities.length, 9);

      // All cells should have equal probability (global probability)
      final expectedProb = 1 / 9; // 1 mine in 9 cells
      for (final prob in result.probabilities.values) {
        expect((prob.probability - expectedProb).abs() < 0.15, true);
      }
    });

    test('analysis completes within reasonable time', () async {
      final board = _createBoard(16, 16); // Intermediate size

      final stopwatch = Stopwatch()..start();
      await analyzer.analyze(board, GameState.playing, 40, 0);
      stopwatch.stop();

      // Should complete within 1 second for intermediate board
      expect(stopwatch.elapsedMilliseconds < 1000, true);
    });

    test('solvability calculation is correct', () async {
      final board = _createBoard(3, 3);

      // Create a situation where all cells can be determined
      board[0][0] = board[0][0].copyWith(isRevealed: true, neighborMines: 1);
      board[0][1] = board[0][1].copyWith(isRevealed: true, neighborMines: 1);
      board[0][2] = board[0][2].copyWith(isRevealed: true, neighborMines: 0);
      board[1][0] = board[1][0].copyWith(isRevealed: true, neighborMines: 1);
      board[2][0] = board[2][0].copyWith(isRevealed: true, neighborMines: 1);
      board[2][1] = board[2][1].copyWith(isRevealed: true, neighborMines: 1);
      board[2][2] = board[2][2].copyWith(isRevealed: true, neighborMines: 0);

      final result = await analyzer.analyze(board, GameState.playing, 1, 0);

      // Solvability should be relatively high
      expect(result.solvability > 0.5, true);
    });
  });

  group('CellProbability', () {
    test('correctly identifies safe cells', () {
      final safe = CellProbability(
        position: Position(0, 0),
        probability: 0.0,
      );

      expect(safe.isSafe, true);
      expect(safe.isMine, false);
      expect(safe.isUncertain, false);
    });

    test('correctly identifies mine cells', () {
      final mine = CellProbability(
        position: Position(0, 0),
        probability: 1.0,
      );

      expect(mine.isSafe, false);
      expect(mine.isMine, true);
      expect(mine.isUncertain, false);
    });

    test('correctly identifies uncertain cells', () {
      final uncertain = CellProbability(
        position: Position(0, 0),
        probability: 0.5,
      );

      expect(uncertain.isSafe, false);
      expect(uncertain.isMine, false);
      expect(uncertain.isUncertain, true);
    });
  });
}

/// Helper to create an empty board
List<List<Cell>> _createBoard(int rows, int cols) {
  return List.generate(
    rows,
    (row) => List.generate(
      cols,
      (col) => Cell(row: row, col: col),
    ),
  );
}
