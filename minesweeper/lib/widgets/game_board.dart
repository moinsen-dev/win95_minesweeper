import 'package:flutter/material.dart';
import '../game/minesweeper_game.dart';
import '../models/game_state.dart';
import 'cell_widget.dart';

class GameBoard extends StatelessWidget {
  final MinesweeperGame game;

  const GameBoard({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final cellSize = _calculateCellSize(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF808080), width: 3),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: game.cols,
          childAspectRatio: 1.0,
        ),
        itemCount: game.rows * game.cols,
        itemBuilder: (context, index) {
          final row = index ~/ game.cols;
          final col = index % game.cols;
          final cell = game.board[row][col];

          return SizedBox(
            width: cellSize,
            height: cellSize,
            child: CellWidget(
              cell: cell,
              onTap: () => game.revealCell(row, col),
              onLongPress: () => game.toggleFlag(row, col),
              gameOver: game.gameState == GameState.lost,
            ),
          );
        },
      ),
    );
  }

  double _calculateCellSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBoardWidth = screenWidth - 40; // padding
    final cellSize = maxBoardWidth / game.cols;
    return cellSize.clamp(20.0, 30.0);
  }
}
