import '../game/minesweeper_game.dart';
import '../models/game_state.dart';
import '../models/difficulty.dart';
import '../models/cell.dart';
import 'game_snapshot.dart';

/// Context that provides features access to game state and coordination
class GameContext {
  /// Reference to the game instance
  final MinesweeperGame game;

  /// Saved game snapshot (for state preservation)
  GameSnapshot? _savedSnapshot;

  /// Callbacks for game events
  final List<Function()> _gameStateListeners = [];
  final List<Function(int row, int col)> _moveListeners = [];
  final List<Function()> _resetListeners = [];

  GameContext({required this.game});

  /// Get current game state
  GameState get gameState => game.gameState;

  /// Get current difficulty
  Difficulty get difficulty => game.difficulty;

  /// Get board dimensions
  int get rows => game.board.length;
  int get cols => game.board.isEmpty ? 0 : game.board[0].length;

  /// Get mine count
  int get mineCount => difficulty.mines;

  /// Get flag count
  int get flagCount => game.flagsPlaced;

  /// Get elapsed time
  int get elapsedTime => game.elapsedSeconds;

  /// Access to the game board
  List<List<Cell>> get board => game.board;

  /// Save current game state
  void saveState() {
    _savedSnapshot = GameSnapshot.fromGame(game);
  }

  /// Restore saved game state
  void restoreState() {
    if (_savedSnapshot != null) {
      _savedSnapshot!.restoreToGame(game);
    }
  }

  /// Clear saved state
  void clearSavedState() {
    _savedSnapshot = null;
  }

  /// Check if there is a saved state
  bool get hasSavedState => _savedSnapshot != null;

  /// Register a listener for game state changes
  void addGameStateListener(Function() listener) {
    _gameStateListeners.add(listener);
  }

  /// Register a listener for moves
  void addMoveListener(Function(int row, int col) listener) {
    _moveListeners.add(listener);
  }

  /// Register a listener for resets
  void addResetListener(Function() listener) {
    _resetListeners.add(listener);
  }

  /// Remove a game state listener
  void removeGameStateListener(Function() listener) {
    _gameStateListeners.remove(listener);
  }

  /// Remove a move listener
  void removeMoveListener(Function(int row, int col) listener) {
    _moveListeners.remove(listener);
  }

  /// Remove a reset listener
  void removeResetListener(Function() listener) {
    _resetListeners.remove(listener);
  }

  /// Notify all listeners of a game state change
  void notifyGameStateChanged() {
    for (final listener in _gameStateListeners) {
      listener();
    }
  }

  /// Notify all listeners of a move
  void notifyMove(int row, int col) {
    for (final listener in _moveListeners) {
      listener(row, col);
    }
  }

  /// Notify all listeners of a reset
  void notifyReset() {
    for (final listener in _resetListeners) {
      listener();
    }
  }

  /// Clean up all listeners
  void dispose() {
    _gameStateListeners.clear();
    _moveListeners.clear();
    _resetListeners.clear();
    _savedSnapshot = null;
  }
}
