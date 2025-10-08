import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/difficulty.dart';
import '../models/game_state.dart';

class MinesweeperGame extends ChangeNotifier {
  Difficulty _difficulty = Difficulty.beginner;
  List<List<Cell>> _board = [];
  GameState _gameState = GameState.ready;
  int _flagsPlaced = 0;
  int _cellsRevealed = 0;
  int _elapsedSeconds = 0;
  bool _firstClick = true;

  Difficulty get difficulty => _difficulty;
  List<List<Cell>> get board => _board;
  GameState get gameState => _gameState;
  int get flagsPlaced => _flagsPlaced;
  int get minesRemaining => _difficulty.mines - _flagsPlaced;
  int get elapsedSeconds => _elapsedSeconds;
  int get rows => _difficulty.rows;
  int get cols => _difficulty.cols;

  MinesweeperGame() {
    _initializeBoard();
  }

  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    resetGame();
  }

  void incrementTimer() {
    if (_gameState == GameState.playing && _elapsedSeconds < 999) {
      _elapsedSeconds++;
      notifyListeners();
    }
  }

  void resetGame() {
    _gameState = GameState.ready;
    _flagsPlaced = 0;
    _cellsRevealed = 0;
    _elapsedSeconds = 0;
    _firstClick = true;
    _initializeBoard();
    notifyListeners();
  }

  void _initializeBoard() {
    _board = List.generate(
      _difficulty.rows,
      (row) => List.generate(
        _difficulty.cols,
        (col) => Cell(row: row, col: col),
      ),
    );
  }

  void _placeMines(int excludeRow, int excludeCol) {
    final random = Random();
    int minesPlaced = 0;

    while (minesPlaced < _difficulty.mines) {
      final row = random.nextInt(_difficulty.rows);
      final col = random.nextInt(_difficulty.cols);

      // Don't place mine on first click or if already a mine
      if ((row == excludeRow && col == excludeCol) || _board[row][col].isMine) {
        continue;
      }

      _board[row][col] = _board[row][col].copyWith(isMine: true);
      minesPlaced++;
    }

    _calculateNeighborMines();
  }

  void _calculateNeighborMines() {
    for (int row = 0; row < _difficulty.rows; row++) {
      for (int col = 0; col < _difficulty.cols; col++) {
        if (!_board[row][col].isMine) {
          int count = 0;
          for (var dr = -1; dr <= 1; dr++) {
            for (var dc = -1; dc <= 1; dc++) {
              if (dr == 0 && dc == 0) continue;
              final newRow = row + dr;
              final newCol = col + dc;
              if (_isValidCell(newRow, newCol) &&
                  _board[newRow][newCol].isMine) {
                count++;
              }
            }
          }
          _board[row][col] = _board[row][col].copyWith(neighborMines: count);
        }
      }
    }
  }

  bool _isValidCell(int row, int col) {
    return row >= 0 &&
        row < _difficulty.rows &&
        col >= 0 &&
        col < _difficulty.cols;
  }

  void revealCell(int row, int col) {
    if (_gameState == GameState.won || _gameState == GameState.lost) {
      return;
    }

    final cell = _board[row][col];

    if (cell.isRevealed || cell.isFlagged) {
      return;
    }

    // First click: place mines and start game
    if (_firstClick) {
      _placeMines(row, col);
      _firstClick = false;
      _gameState = GameState.playing;
    }

    _board[row][col] = cell.copyWith(isRevealed: true, isQuestionMarked: false);
    _cellsRevealed++;

    if (cell.isMine) {
      _gameOver(false);
      return;
    }

    // Auto-reveal adjacent cells if no neighboring mines
    if (cell.neighborMines == 0) {
      _revealAdjacentCells(row, col);
    }

    _checkWinCondition();
    notifyListeners();
  }

  void _revealAdjacentCells(int row, int col) {
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final newRow = row + dr;
        final newCol = col + dc;
        if (_isValidCell(newRow, newCol)) {
          final adjacentCell = _board[newRow][newCol];
          if (!adjacentCell.isRevealed && !adjacentCell.isFlagged) {
            _board[newRow][newCol] = adjacentCell.copyWith(
              isRevealed: true,
              isQuestionMarked: false,
            );
            _cellsRevealed++;
            if (adjacentCell.neighborMines == 0) {
              _revealAdjacentCells(newRow, newCol);
            }
          }
        }
      }
    }
  }

  void toggleFlag(int row, int col) {
    if (_gameState == GameState.won || _gameState == GameState.lost) {
      return;
    }

    final cell = _board[row][col];

    if (cell.isRevealed) {
      return;
    }

    // Cycle through: normal -> flag -> question -> normal
    if (!cell.isFlagged && !cell.isQuestionMarked) {
      _board[row][col] = cell.copyWith(isFlagged: true);
      _flagsPlaced++;
    } else if (cell.isFlagged) {
      _board[row][col] = cell.copyWith(isFlagged: false, isQuestionMarked: true);
      _flagsPlaced--;
    } else {
      _board[row][col] = cell.copyWith(isQuestionMarked: false);
    }

    notifyListeners();
  }

  void _checkWinCondition() {
    final totalCells = _difficulty.rows * _difficulty.cols;
    final safeCells = totalCells - _difficulty.mines;

    if (_cellsRevealed == safeCells) {
      _gameOver(true);
    }
  }

  void _gameOver(bool won) {
    _gameState = won ? GameState.won : GameState.lost;

    // Reveal all mines when game is over
    if (!won) {
      for (var row = 0; row < _difficulty.rows; row++) {
        for (var col = 0; col < _difficulty.cols; col++) {
          if (_board[row][col].isMine) {
            _board[row][col] = _board[row][col].copyWith(isRevealed: true);
          }
        }
      }
    }

    notifyListeners();
  }
}
