import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/ai/csp_solver.dart';
import 'package:minesweeper/ai/cell_probabilities.dart';
import 'package:minesweeper/models/cell.dart';

void main() {
  group('CSPSolver', () {
    late CSPSolver solver;

    setUp(() {
      solver = CSPSolver(maxSolutions: 10000);
    });

    test('solves simple constraint: 1 mine in 1 cell', () {
      // Constraint: exactly 1 mine among {(0,0)}
      final constraint = MineConstraint({Position(0, 0)}, 1);
      final variables = {Position(0, 0)};

      final solutions = solver.solve(
        constraints: [constraint],
        variables: variables,
        totalMinesRemaining: 1,
      );

      expect(solutions.length, 1);
      expect(solutions[0].assignments[Position(0, 0)], true);
    });

    test('solves simple constraint: 0 mines in 1 cell', () {
      // Constraint: exactly 0 mines among {(0,0)}
      final constraint = MineConstraint({Position(0, 0)}, 0);
      final variables = {Position(0, 0)};

      final solutions = solver.solve(
        constraints: [constraint],
        variables: variables,
        totalMinesRemaining: 0,
      );

      expect(solutions.length, 1);
      expect(solutions[0].assignments[Position(0, 0)], false);
    });

    test('solves constraint: 1 mine in 2 cells', () {
      // Constraint: exactly 1 mine among {(0,0), (0,1)}
      final constraint = MineConstraint({Position(0, 0), Position(0, 1)}, 1);
      final variables = {Position(0, 0), Position(0, 1)};

      final solutions = solver.solve(
        constraints: [constraint],
        variables: variables,
        totalMinesRemaining: 1,
      );

      // Should have 2 solutions: mine at (0,0) or mine at (0,1)
      expect(solutions.length, 2);

      // Check that we have both possibilities
      final sol1 = solutions.firstWhere(
        (s) => s.assignments[Position(0, 0)] == true,
      );
      expect(sol1.assignments[Position(0, 1)], false);

      final sol2 = solutions.firstWhere(
        (s) => s.assignments[Position(0, 1)] == true,
      );
      expect(sol2.assignments[Position(0, 0)], false);
    });

    test('solves constraint: 2 mines in 3 cells', () {
      // Constraint: exactly 2 mines among {(0,0), (0,1), (0,2)}
      final constraint = MineConstraint(
        {Position(0, 0), Position(0, 1), Position(0, 2)},
        2,
      );
      final variables = {Position(0, 0), Position(0, 1), Position(0, 2)};

      final solutions = solver.solve(
        constraints: [constraint],
        variables: variables,
        totalMinesRemaining: 2,
      );

      // Should have 3 solutions: C(3,2) = 3
      expect(solutions.length, 3);

      // Each solution should have exactly 2 mines
      for (final solution in solutions) {
        expect(solution.mineCount, 2);
      }
    });

    test('solves multiple independent constraints', () {
      // Two independent constraints:
      // - 1 mine among {(0,0), (0,1)}
      // - 1 mine among {(2,0), (2,1)}
      final constraint1 = MineConstraint({Position(0, 0), Position(0, 1)}, 1);
      final constraint2 = MineConstraint({Position(2, 0), Position(2, 1)}, 1);

      final variables = {
        Position(0, 0),
        Position(0, 1),
        Position(2, 0),
        Position(2, 1),
      };

      final solutions = solver.solve(
        constraints: [constraint1, constraint2],
        variables: variables,
        totalMinesRemaining: 2,
      );

      // Should have 2 * 2 = 4 solutions
      expect(solutions.length, 4);

      // All solutions should have exactly 2 mines total
      for (final solution in solutions) {
        expect(solution.mineCount, 2);
      }
    });

    test('solves overlapping constraints', () {
      // Two overlapping constraints (classic 1-2-1 pattern):
      // - 1 mine among {(0,0), (0,1), (1,0), (1,1)}
      // - 2 mines among {(0,1), (0,2), (1,1), (1,2)}
      // - 1 mine among {(0,2), (0,3), (1,2), (1,3)}
      final constraint1 = MineConstraint(
        {Position(0, 0), Position(0, 1), Position(1, 0), Position(1, 1)},
        1,
      );
      final constraint2 = MineConstraint(
        {Position(0, 1), Position(0, 2), Position(1, 1), Position(1, 2)},
        2,
      );
      final constraint3 = MineConstraint(
        {Position(0, 2), Position(0, 3), Position(1, 2), Position(1, 3)},
        1,
      );

      final variables = {
        Position(0, 0),
        Position(0, 1),
        Position(0, 2),
        Position(0, 3),
        Position(1, 0),
        Position(1, 1),
        Position(1, 2),
        Position(1, 3),
      };

      final solutions = solver.solve(
        constraints: [constraint1, constraint2, constraint3],
        variables: variables,
        totalMinesRemaining: 2,
      );

      // Should have valid solutions
      expect(solutions.isNotEmpty, true);

      // All solutions should satisfy all constraints
      for (final solution in solutions) {
        expect(solution.mineCount, 2);

        // Verify constraint1: 1 mine
        final mines1 = constraint1.cells
            .where((pos) => solution.assignments[pos] == true)
            .length;
        expect(mines1, 1);

        // Verify constraint2: 2 mines
        final mines2 = constraint2.cells
            .where((pos) => solution.assignments[pos] == true)
            .length;
        expect(mines2, 2);

        // Verify constraint3: 1 mine
        final mines3 = constraint3.cells
            .where((pos) => solution.assignments[pos] == true)
            .length;
        expect(mines3, 1);
      }
    });

    test('returns empty solutions when constraints are unsatisfiable', () {
      // Impossible constraint: 3 mines among 2 cells
      final constraint = MineConstraint({Position(0, 0), Position(0, 1)}, 3);
      final variables = {Position(0, 0), Position(0, 1)};

      final solutions = solver.solve(
        constraints: [constraint],
        variables: variables,
        totalMinesRemaining: 3,
      );

      expect(solutions.isEmpty, true);
    });

    test('respects global mine count constraint', () {
      // Constraint: 1 mine among {(0,0), (0,1)}
      // But global count says 0 mines remaining
      final constraint = MineConstraint({Position(0, 0), Position(0, 1)}, 1);
      final variables = {Position(0, 0), Position(0, 1)};

      final solutions = solver.solve(
        constraints: [constraint],
        variables: variables,
        totalMinesRemaining: 0,
      );

      // Should have no solutions (constraint requires 1 mine, but 0 remaining)
      expect(solutions.isEmpty, true);
    });

    test('calculateProbabilities returns exact probabilities', () {
      // Two solutions:
      // Solution 1: (0,0) = mine, (0,1) = safe
      // Solution 2: (0,0) = safe, (0,1) = mine
      final solution1 = Solution();
      solution1.assignments[Position(0, 0)] = true;
      solution1.assignments[Position(0, 1)] = false;

      final solution2 = Solution();
      solution2.assignments[Position(0, 0)] = false;
      solution2.assignments[Position(0, 1)] = true;

      final solutions = [solution1, solution2];
      final variables = {Position(0, 0), Position(0, 1)};

      final probabilities = solver.calculateProbabilities(solutions, variables);

      // Each cell should have 50% probability
      expect(probabilities[Position(0, 0)], 0.5);
      expect(probabilities[Position(0, 1)], 0.5);
    });

    test('calculateProbabilities handles certain mines', () {
      // Three solutions, all have (0,0) as mine
      final solution1 = Solution();
      solution1.assignments[Position(0, 0)] = true;
      solution1.assignments[Position(0, 1)] = false;
      solution1.assignments[Position(0, 2)] = false;

      final solution2 = Solution();
      solution2.assignments[Position(0, 0)] = true;
      solution2.assignments[Position(0, 1)] = true;
      solution2.assignments[Position(0, 2)] = false;

      final solution3 = Solution();
      solution3.assignments[Position(0, 0)] = true;
      solution3.assignments[Position(0, 1)] = false;
      solution3.assignments[Position(0, 2)] = true;

      final solutions = [solution1, solution2, solution3];
      final variables = {Position(0, 0), Position(0, 1), Position(0, 2)};

      final probabilities = solver.calculateProbabilities(solutions, variables);

      // (0,0) appears in all solutions
      expect(probabilities[Position(0, 0)], 1.0);

      // (0,1) appears in 1/3 solutions
      expect(probabilities[Position(0, 1)], closeTo(0.333, 0.01));

      // (0,2) appears in 1/3 solutions
      expect(probabilities[Position(0, 2)], closeTo(0.333, 0.01));
    });

    test('calculateProbabilities handles no solutions', () {
      final solutions = <Solution>[];
      final variables = {Position(0, 0), Position(0, 1)};

      final probabilities = solver.calculateProbabilities(solutions, variables);

      // Should return 0.5 (unknown) for all cells
      expect(probabilities[Position(0, 0)], 0.5);
      expect(probabilities[Position(0, 1)], 0.5);
    });
  });

  group('ConstraintExtractor', () {
    test('extracts simple constraint from board', () {
      // Board with one revealed cell showing "1"
      // X X X
      // X 1 X
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
                neighborMines: 1,
                isRevealed: true,
              );
            }
            return Cell(row: row, col: col, isMine: false);
          },
        ),
      );

      final constraints = ConstraintExtractor.extractConstraints(board);

      expect(constraints.length, 1);
      expect(constraints[0].mineCount, 1);
      expect(constraints[0].cells.length, 8); // All 8 neighbors
    });

    test('extracts multiple constraints', () {
      // Board:
      // X 1 X
      // 1 X 1
      // X 1 X
      final board = List.generate(
        3,
        (row) => List.generate(
          3,
          (col) {
            if ((row == 0 && col == 1) ||
                (row == 1 && col == 0) ||
                (row == 1 && col == 2) ||
                (row == 2 && col == 1)) {
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

      final constraints = ConstraintExtractor.extractConstraints(board);

      // Should have 4 constraints (one for each revealed "1")
      expect(constraints.length, 4);
    });

    test('accounts for flagged cells in constraints', () {
      // Board:
      // F 1 X
      // X X X
      final board = [
        [
          Cell(row: 0, col: 0, isMine: true, isFlagged: true),
          Cell(row: 0, col: 1, isMine: false, neighborMines: 1, isRevealed: true),
          Cell(row: 0, col: 2, isMine: false),
        ],
        [
          Cell(row: 1, col: 0, isMine: false),
          Cell(row: 1, col: 1, isMine: false),
          Cell(row: 1, col: 2, isMine: false),
        ],
      ];

      final constraints = ConstraintExtractor.extractConstraints(board);

      expect(constraints.length, 1);
      // Mine count should be 0 (1 mine - 1 flagged = 0)
      expect(constraints[0].mineCount, 0);
      // Should only include unrevealed, unflagged neighbors
      expect(constraints[0].cells.length, 4);
    });

    test('ignores revealed cells with 0 neighbor mines', () {
      // Board with revealed "0"
      // X 0 X
      final board = [
        [
          Cell(row: 0, col: 0, isMine: false),
          Cell(row: 0, col: 1, isMine: false, neighborMines: 0, isRevealed: true),
          Cell(row: 0, col: 2, isMine: false),
        ],
      ];

      final constraints = ConstraintExtractor.extractConstraints(board);

      // Should have no constraints (0 doesn't create meaningful constraints)
      expect(constraints.isEmpty, true);
    });

    test('getFrontierCells returns unrevealed cells adjacent to revealed', () {
      // Board:
      // X R X
      // R R R
      // X R X
      // Where R = revealed, X = unrevealed
      final board = List.generate(
        3,
        (row) => List.generate(
          3,
          (col) {
            final isRevealed = (row == 0 && col == 1) ||
                (row == 1) ||
                (row == 2 && col == 1);
            return Cell(
              row: row,
              col: col,
              isMine: false,
              isRevealed: isRevealed,
            );
          },
        ),
      );

      final frontier = ConstraintExtractor.getFrontierCells(board);

      // Frontier should be the 4 corner cells
      expect(frontier.length, 4);
      expect(frontier.contains(Position(0, 0)), true);
      expect(frontier.contains(Position(0, 2)), true);
      expect(frontier.contains(Position(2, 0)), true);
      expect(frontier.contains(Position(2, 2)), true);
    });

    test('getFrontierCells excludes flagged cells', () {
      // Board:
      // F R X
      final board = [
        [
          Cell(row: 0, col: 0, isMine: true, isFlagged: true),
          Cell(row: 0, col: 1, isMine: false, isRevealed: true),
          Cell(row: 0, col: 2, isMine: false),
        ],
      ];

      final frontier = ConstraintExtractor.getFrontierCells(board);

      // Should only include (0,2), not (0,0) which is flagged
      expect(frontier.length, 1);
      expect(frontier.contains(Position(0, 2)), true);
      expect(frontier.contains(Position(0, 0)), false);
    });
  });
}
