import '../game/minesweeper_game.dart';
import '../models/game_state.dart';
import '../models/difficulty.dart';
import '../models/cell.dart';

/// Immutable snapshot of game state for time travel and state preservation
class GameSnapshot {
  /// Board state at time of snapshot
  final List<List<Cell>> boardState;

  /// Current game state
  final GameState gameState;

  /// Difficulty level
  final Difficulty difficulty;

  /// Number of flags placed
  final int flagCount;

  /// Elapsed time in seconds
  final int elapsedTime;

  /// Timestamp when snapshot was taken
  final DateTime timestamp;

  const GameSnapshot({
    required this.boardState,
    required this.gameState,
    required this.difficulty,
    required this.flagCount,
    required this.elapsedTime,
    required this.timestamp,
  });

  /// Create a snapshot from current game state
  factory GameSnapshot.fromGame(MinesweeperGame game) {
    // Deep copy the board
    final boardCopy = <List<Cell>>[];
    for (final row in game.board) {
      final rowCopy = <Cell>[];
      for (final cell in row) {
        rowCopy.add(Cell(
          row: cell.row,
          col: cell.col,
          isMine: cell.isMine,
          isRevealed: cell.isRevealed,
          isFlagged: cell.isFlagged,
          isQuestionMarked: cell.isQuestionMarked,
          neighborMines: cell.neighborMines,
        ));
      }
      boardCopy.add(rowCopy);
    }

    return GameSnapshot(
      boardState: boardCopy,
      gameState: game.gameState,
      difficulty: game.difficulty,
      flagCount: game.flagsPlaced,
      elapsedTime: game.elapsedSeconds,
      timestamp: DateTime.now(),
    );
  }

  /// Restore this snapshot to a game instance
  void restoreToGame(MinesweeperGame game) {
    // This would need to be implemented with game setters
    // For now, this is a placeholder showing the intent
    // The actual implementation would depend on MinesweeperGame's API

    // game.restoreState(
    //   boardState: boardState,
    //   gameState: gameState,
    //   flagCount: flagCount,
    //   elapsedTime: elapsedTime,
    // );
  }

  /// Create a copy with modifications
  GameSnapshot copyWith({
    List<List<Cell>>? boardState,
    GameState? gameState,
    Difficulty? difficulty,
    int? flagCount,
    int? elapsedTime,
    DateTime? timestamp,
  }) {
    return GameSnapshot(
      boardState: boardState ?? this.boardState,
      gameState: gameState ?? this.gameState,
      difficulty: difficulty ?? this.difficulty,
      flagCount: flagCount ?? this.flagCount,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Get the number of revealed cells
  int get revealedCount {
    int count = 0;
    for (final row in boardState) {
      for (final cell in row) {
        if (cell.isRevealed) count++;
      }
    }
    return count;
  }

  /// Get the number of cells with flags
  int get flaggedCount {
    int count = 0;
    for (final row in boardState) {
      for (final cell in row) {
        if (cell.isFlagged) count++;
      }
    }
    return count;
  }

  /// Check if this snapshot represents a won game
  bool get isWon => gameState == GameState.won;

  /// Check if this snapshot represents a lost game
  bool get isLost => gameState == GameState.lost;

  /// Check if this snapshot represents an active game
  bool get isPlaying => gameState == GameState.playing;

  @override
  String toString() {
    return 'GameSnapshot(state: $gameState, difficulty: ${difficulty.displayName}, '
        'flags: $flagCount, time: ${elapsedTime}s, timestamp: $timestamp)';
  }
}

/// Manager for maintaining game history (for Time Machine dimension)
class GameHistory {
  /// List of all snapshots in chronological order
  final List<GameSnapshot> _snapshots = [];

  /// Maximum number of snapshots to keep
  final int maxSnapshots;

  GameHistory({this.maxSnapshots = 100});

  /// Add a snapshot to history
  void addSnapshot(GameSnapshot snapshot) {
    _snapshots.add(snapshot);

    // Trim history if it exceeds max size
    if (_snapshots.length > maxSnapshots) {
      _snapshots.removeAt(0);
    }
  }

  /// Get all snapshots
  List<GameSnapshot> get snapshots => List.unmodifiable(_snapshots);

  /// Get the most recent snapshot
  GameSnapshot? get latest => _snapshots.isEmpty ? null : _snapshots.last;

  /// Get a snapshot at a specific index
  GameSnapshot? getSnapshot(int index) {
    if (index < 0 || index >= _snapshots.length) {
      return null;
    }
    return _snapshots[index];
  }

  /// Get number of snapshots
  int get length => _snapshots.length;

  /// Clear all history
  void clear() {
    _snapshots.clear();
  }

  /// Get snapshots in a time range
  List<GameSnapshot> getSnapshotsInRange(DateTime start, DateTime end) {
    return _snapshots.where((snapshot) {
      return snapshot.timestamp.isAfter(start) &&
          snapshot.timestamp.isBefore(end);
    }).toList();
  }

  /// Get the first losing move (if any)
  GameSnapshot? getFirstLosingSnapshot() {
    for (final snapshot in _snapshots) {
      if (snapshot.isLost) {
        return snapshot;
      }
    }
    return null;
  }

  /// Get all winning snapshots
  List<GameSnapshot> getWinningSnapshots() {
    return _snapshots.where((s) => s.isWon).toList();
  }
}
