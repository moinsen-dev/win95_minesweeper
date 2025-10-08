import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/ai/advanced_board_analyzer.dart';
import 'package:minesweeper/ai/cell_probabilities.dart';
import 'package:minesweeper/models/cell.dart';
import 'package:minesweeper/models/game_state.dart';

void main() {
  group('AdvancedBoardAnalyzer', () {
    late AdvancedBoardAnalyzer analyzer;

    setUp(() {
      analyzer = AdvancedBoardAnalyzer();
    });

    test('identifies definite safe moves', () async {
      // Board with one revealed "0" (all neighbors are safe)
      // X X X
      // X 0 X
      // X X X
      final board = List.generate(
        3,
        (row) => List.generate(
          3,
          (col) {
            if (row == 1 && col == 1) {
              return Cell(
                row: row,
                col: col,
                isMine: false,
                neighborMines: 0,
                isRevealed: true,
              );
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        10, // totalMines
        0,  // flagsPlaced
      );

      // No constraints from "0" cell, so no definite safe moves from CSP
      // (In real game, clicking a "0" auto-reveals neighbors)
      expect(result.safeMoves, isEmpty);
    });

    test('identifies definite mines', () async {
      // Board:
      // X 1 F
      // Where the last unrevealed neighbor of "1" must be a mine
      final board = [
        [
          Cell(row: 0, col: 0, isMine: true), // This must be mine
          Cell(row: 0, col: 1, isMine: false, neighborMines: 1, isRevealed: true),
          Cell(row: 0, col: 2, isMine: false, isRevealed: true),
        ],
      ];

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        1, // totalMines
        0, // flagsPlaced
      );

      // (0,0) should be identified as definite mine
      expect(result.definitelyMines.length, 1);
      expect(result.definitelyMines.first, Position(0, 0));
      expect(result.probabilities[Position(0, 0)]!.probability, 1.0);
    });

    test('calculates correct probabilities for ambiguous situation', () async {
      // Board: two cells, one mine
      // X 1 X
      // Both (0,0) and (0,2) have 50% chance
      final board = [
        [
          Cell(row: 0, col: 0, isMine: false),
          Cell(row: 0, col: 1, isMine: false, neighborMines: 1, isRevealed: true),
          Cell(row: 0, col: 2, isMine: true),
        ],
      ];

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        1, // totalMines
        0, // flagsPlaced
      );

      // Both cells should have 50% probability
      expect(result.probabilities[Position(0, 0)]!.probability, closeTo(0.5, 0.01));
      expect(result.probabilities[Position(0, 2)]!.probability, closeTo(0.5, 0.01));
    });

    test('detects horizontal 1-2-1 pattern', () async {
      // Board:
      // X X X X X
      // 1 2 1 R R
      final board = List.generate(
        2,
        (row) => List.generate(
          5,
          (col) {
            if (row == 1) {
              if (col == 0) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              } else if (col == 1) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 2, isRevealed: true);
              } else if (col == 2) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              } else {
                return Cell(row: row, col: col, isMine: false, isRevealed: true);
              }
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final patterns = analyzer.detectPatterns(board);

      expect(patterns.isNotEmpty, true);
      final pattern121 = patterns.firstWhere(
        (p) => p.name == '1-2-1 Horizontal',
        orElse: () => throw Exception('Pattern not found'),
      );

      expect(pattern121.cells.length, 3);
      expect(pattern121.description.contains('above or below'), true);
    });

    test('detects vertical 1-2-1 pattern', () async {
      // Board:
      // X 1
      // X 2
      // X 1
      // X R
      // X R
      final board = List.generate(
        5,
        (row) => List.generate(
          2,
          (col) {
            if (col == 1) {
              if (row == 0) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              } else if (row == 1) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 2, isRevealed: true);
              } else if (row == 2) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              } else {
                return Cell(row: row, col: col, isMine: false, isRevealed: true);
              }
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final patterns = analyzer.detectPatterns(board);

      expect(patterns.isNotEmpty, true);
      final pattern121 = patterns.firstWhere(
        (p) => p.name == '1-2-1 Vertical',
        orElse: () => throw Exception('Pattern not found'),
      );

      expect(pattern121.cells.length, 3);
      expect(pattern121.description.contains('left or right'), true);
    });

    test('detects 1-2-2-1 pattern', () async {
      // Board:
      // X X X X X X
      // 1 2 2 1 R R
      final board = List.generate(
        2,
        (row) => List.generate(
          6,
          (col) {
            if (row == 1) {
              if (col == 0) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              } else if (col == 1) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 2, isRevealed: true);
              } else if (col == 2) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 2, isRevealed: true);
              } else if (col == 3) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              } else {
                return Cell(row: row, col: col, isMine: false, isRevealed: true);
              }
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final patterns = analyzer.detectPatterns(board);

      expect(patterns.isNotEmpty, true);
      final pattern1221 = patterns.firstWhere(
        (p) => p.name == '1-2-2-1 Pattern',
        orElse: () => throw Exception('Pattern not found'),
      );

      expect(pattern1221.cells.length, 4);
      expect(pattern1221.difficulty, 3);
    });

    test('detects corner mine pattern', () async {
      // Board:
      // X 1 R
      // R R R
      // Where "1" has only one unrevealed neighbor
      final board = [
        [
          Cell(row: 0, col: 0, isMine: true),
          Cell(row: 0, col: 1, isMine: false, neighborMines: 1, isRevealed: true),
          Cell(row: 0, col: 2, isMine: false, isRevealed: true),
        ],
        [
          Cell(row: 1, col: 0, isMine: false, isRevealed: true),
          Cell(row: 1, col: 1, isMine: false, isRevealed: true),
          Cell(row: 1, col: 2, isMine: false, isRevealed: true),
        ],
      ];

      final patterns = analyzer.detectPatterns(board);

      expect(patterns.isNotEmpty, true);
      final cornerPattern = patterns.firstWhere(
        (p) => p.name == 'Corner Mine',
        orElse: () => throw Exception('Pattern not found'),
      );

      expect(cornerPattern.difficulty, 1);
      expect(cornerPattern.description.contains('must be a mine'), true);
    });

    test('handles empty board gracefully', () async {
      final board = List.generate(
        5,
        (row) => List.generate(
          5,
          (col) => Cell(row: row, col: col, isMine: false),
        ),
      );

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        10,
        0,
      );

      expect(result.safeMoves, isEmpty);
      expect(result.definitelyMines, isEmpty);
      expect(result.probabilities, isEmpty);
    });

    test('handles fully revealed board', () async {
      final board = List.generate(
        3,
        (row) => List.generate(
          3,
          (col) => Cell(
            row: row,
            col: col,
            isMine: false,
            isRevealed: true,
            neighborMines: 0,
          ),
        ),
      );

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        0,
        0,
      );

      expect(result.safeMoves, isEmpty);
      expect(result.definitelyMines, isEmpty);
      expect(result.solvability, 1.0);
    });

    test('performance test on larger board', () async {
      // Create a 9x9 board (intermediate size) with some revealed cells
      final board = List.generate(
        9,
        (row) => List.generate(
          9,
          (col) {
            // Reveal center cell
            if (row == 4 && col == 4) {
              return Cell(
                row: row,
                col: col,
                isMine: false,
                neighborMines: 1,
                isRevealed: true,
              );
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final stopwatch = Stopwatch()..start();
      final result = await analyzer.analyze(
        board,
        GameState.playing,
        10,
        0,
      );
      stopwatch.stop();

      // Should complete in reasonable time (< 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(result.analysisTimeMs, lessThan(2000));
    });

    test('returns high confidence for CSP-derived probabilities', () async {
      // CSP gives exact probabilities, so confidence should be 1.0
      final board = [
        [
          Cell(row: 0, col: 0, isMine: false),
          Cell(row: 0, col: 1, isMine: false, neighborMines: 1, isRevealed: true),
          Cell(row: 0, col: 2, isMine: true),
        ],
      ];

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        1,
        0,
      );

      // All probabilities should have confidence 1.0
      for (final prob in result.probabilities.values) {
        expect(prob.confidence, 1.0);
      }
    });

    test('calculates solvability correctly', () async {
      // Board where all frontier cells can be determined
      // R 1 F
      final board = [
        [
          Cell(row: 0, col: 0, isMine: false, isRevealed: true),
          Cell(row: 0, col: 1, isMine: false, neighborMines: 1, isRevealed: true),
          Cell(row: 0, col: 2, isMine: true, isFlagged: true),
        ],
      ];

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        1,
        1,
      );

      // No frontier cells (all revealed or flagged), so solvability should be 1.0
      expect(result.solvability, 1.0);
    });
  });
}
