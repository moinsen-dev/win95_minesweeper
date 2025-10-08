import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/ai/advanced_board_analyzer.dart';
import 'package:minesweeper/models/cell.dart';
import 'package:minesweeper/models/game_state.dart';

void main() {
  group('CSP Solver Benchmarks', () {
    test('Benchmark: Beginner board (9x9, 10 mines)', () async {
      final analyzer = AdvancedBoardAnalyzer();

      // Create a 9x9 beginner board with some revealed cells
      final board = List.generate(
        9,
        (row) => List.generate(
          9,
          (col) {
            // Reveal center cell with neighbors
            if (row == 4 && col == 4) {
              return Cell(
                row: row,
                col: col,
                isMine: false,
                neighborMines: 2,
                isRevealed: true,
              );
            }
            // Reveal some surrounding cells
            if ((row >= 3 && row <= 5) && (col >= 3 && col <= 5)) {
              if ((row == 3 || row == 5) && (col == 3 || col == 5)) {
                return Cell(
                  row: row,
                  col: col,
                  isMine: false,
                  neighborMines: 1,
                  isRevealed: true,
                );
              }
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        10,
        0,
      );

      print('📊 Beginner (9x9, 10 mines):');
      print('   Analysis time: ${result.analysisTimeMs}ms');
      print('   Frontier cells: ${result.probabilities.length}');
      print('   Safe moves found: ${result.safeMoves.length}');
      print('   Solvability: ${(result.solvability * 100).toStringAsFixed(1)}%');

      expect(result.analysisTimeMs, lessThan(200));
    });

    test('Benchmark: Intermediate board (16x16, 40 mines)', () async {
      final analyzer = AdvancedBoardAnalyzer();

      // Create a 16x16 intermediate board
      final board = List.generate(
        16,
        (row) => List.generate(
          16,
          (col) {
            // Create a pattern of revealed cells
            if (row == 8 && col >= 6 && col <= 10) {
              return Cell(
                row: row,
                col: col,
                isMine: false,
                neighborMines: col == 8 ? 3 : 2,
                isRevealed: true,
              );
            }
            if (row == 7 && col >= 7 && col <= 9) {
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

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        40,
        0,
      );

      print('📊 Intermediate (16x16, 40 mines):');
      print('   Analysis time: ${result.analysisTimeMs}ms');
      print('   Frontier cells: ${result.probabilities.length}');
      print('   Safe moves found: ${result.safeMoves.length}');
      print('   Solvability: ${(result.solvability * 100).toStringAsFixed(1)}%');

      expect(result.analysisTimeMs, lessThan(1000));
    });

    test('Benchmark: Complex pattern (overlapping constraints)', () async {
      final analyzer = AdvancedBoardAnalyzer();

      // Create a board with complex overlapping constraints (1-2-2-1 pattern)
      final board = List.generate(
        5,
        (row) => List.generate(
          10,
          (col) {
            if (row == 2) {
              // Create 1-2-2-1 pattern
              if (col == 2) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              }
              if (col == 3) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 2, isRevealed: true);
              }
              if (col == 4) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 2, isRevealed: true);
              }
              if (col == 5) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              }
              // Additional pattern
              if (col == 7) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 1, isRevealed: true);
              }
              if (col == 8) {
                return Cell(row: row, col: col, isMine: false, neighborMines: 2, isRevealed: true);
              }
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final result = await analyzer.analyze(
        board,
        GameState.playing,
        5,
        0,
      );

      print('📊 Complex Pattern (overlapping constraints):');
      print('   Analysis time: ${result.analysisTimeMs}ms');
      print('   Patterns detected: ${result.patterns.length}');
      for (final pattern in result.patterns) {
        print('      - ${pattern.name}');
      }
      print('   Frontier cells: ${result.probabilities.length}');
      print('   Safe moves found: ${result.safeMoves.length}');

      expect(result.analysisTimeMs, lessThan(500));
      expect(result.patterns.length, greaterThan(0));
    });

    test('Benchmark: Worst case scenario (many interconnected regions)', () async {
      final analyzer = AdvancedBoardAnalyzer();

      // Create a board with many interconnected cells (worst case for CSP)
      final board = List.generate(
        10,
        (row) => List.generate(
          10,
          (col) {
            // Create a checkerboard pattern of revealed cells
            if ((row + col) % 2 == 0 && row >= 2 && row <= 7 && col >= 2 && col <= 7) {
              return Cell(
                row: row,
                col: col,
                isMine: false,
                neighborMines: 3,
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
        20,
        0,
      );

      print('📊 Worst Case (interconnected regions):');
      print('   Analysis time: ${result.analysisTimeMs}ms');
      print('   Frontier cells: ${result.probabilities.length}');
      print('   Safe moves found: ${result.safeMoves.length}');

      // Should still complete in under 2 seconds
      expect(result.analysisTimeMs, lessThan(2000));
    });

    test('Performance comparison: Multiple analyses', () async {
      final analyzer = AdvancedBoardAnalyzer();

      final times = <int>[];

      // Run 5 analyses
      for (int i = 0; i < 5; i++) {
        final board = List.generate(
          12,
          (row) => List.generate(
            12,
            (col) {
              if (row == 6 && col >= 4 && col <= 8) {
                return Cell(
                  row: row,
                  col: col,
                  isMine: false,
                  neighborMines: 2,
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
          15,
          0,
        );

        times.add(result.analysisTimeMs);
      }

      final avgTime = times.reduce((a, b) => a + b) / times.length;
      final minTime = times.reduce((a, b) => a < b ? a : b);
      final maxTime = times.reduce((a, b) => a > b ? a : b);

      print('📊 Performance Statistics (5 runs):');
      print('   Average: ${avgTime.toStringAsFixed(1)}ms');
      print('   Min: ${minTime}ms');
      print('   Max: ${maxTime}ms');
      print('   Variance: ${(maxTime - minTime)}ms');

      expect(avgTime, lessThan(1000));
    });
  });
}
