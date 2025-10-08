import 'package:flutter/material.dart';
import '../models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool gameOver;

  const CellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    this.gameOver = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFC0C0C0),
          border: Border(
            top: BorderSide(
              color: cell.isRevealed
                  ? const Color(0xFF808080)
                  : const Color(0xFFFFFFFF),
              width: 2,
            ),
            left: BorderSide(
              color: cell.isRevealed
                  ? const Color(0xFF808080)
                  : const Color(0xFFFFFFFF),
              width: 2,
            ),
            bottom: BorderSide(
              color: cell.isRevealed
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF808080),
              width: 2,
            ),
            right: BorderSide(
              color: cell.isRevealed
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF808080),
              width: 2,
            ),
          ),
        ),
        child: Center(child: _buildCellContent()),
      ),
    );
  }

  Widget _buildCellContent() {
    if (cell.isFlagged && !cell.isRevealed) {
      return const Icon(
        Icons.flag,
        color: Color(0xFFFF0000),
        size: 16,
      );
    }

    if (cell.isQuestionMarked && !cell.isRevealed) {
      return const Text(
        '?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0000FF),
        ),
      );
    }

    if (!cell.isRevealed) {
      return const SizedBox.shrink();
    }

    if (cell.isMine) {
      return Container(
        decoration: BoxDecoration(
          color: gameOver ? const Color(0xFFFF0000) : const Color(0xFFC0C0C0),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.circle,
          color: Color(0xFF000000),
          size: 12,
        ),
      );
    }

    if (cell.neighborMines == 0) {
      return const SizedBox.shrink();
    }

    return Text(
      cell.neighborMines.toString(),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _getNumberColor(cell.neighborMines),
      ),
    );
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return const Color(0xFF0000FF); // Blue
      case 2:
        return const Color(0xFF008000); // Green
      case 3:
        return const Color(0xFFFF0000); // Red
      case 4:
        return const Color(0xFF000080); // Dark Blue
      case 5:
        return const Color(0xFF800000); // Maroon
      case 6:
        return const Color(0xFF008080); // Teal
      case 7:
        return const Color(0xFF000000); // Black
      case 8:
        return const Color(0xFF808080); // Gray
      default:
        return const Color(0xFF000000);
    }
  }
}
