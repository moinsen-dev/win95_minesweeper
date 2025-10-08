import 'package:flutter/widgets.dart';
import 'game_context.dart';

/// Abstract interface for all game dimension features
///
/// Each dimension can compose one or more features that follow this lifecycle:
/// initialize -> activate -> (running) -> deactivate -> dispose
abstract class GameFeature {
  /// Unique identifier for this feature
  String get id;

  /// Human-readable name
  String get name;

  /// Description of what this feature does
  String get description;

  /// Whether this feature is currently active
  bool get isActive;

  /// Whether this feature has been initialized
  bool get isInitialized;

  /// Initialize the feature with game context
  ///
  /// This is called once when the feature is first created.
  /// Heavy initialization should be done here (loading models, etc.)
  Future<void> initialize(GameContext context);

  /// Activate the feature
  ///
  /// Called when the dimension containing this feature is switched to.
  /// Should set up event listeners, start background tasks, etc.
  Future<void> activate();

  /// Deactivate the feature
  ///
  /// Called when switching away from this dimension.
  /// Should clean up listeners, pause tasks, etc.
  Future<void> deactivate();

  /// Build UI components for this feature (if any)
  ///
  /// Returns null if this feature has no UI
  Widget? buildUI(BuildContext context);

  /// Dispose of all resources
  ///
  /// Called when the feature is being permanently removed.
  /// Should clean up all resources, subscriptions, etc.
  void dispose();

  /// Called when game state changes (optional hook)
  void onGameStateChanged() {}

  /// Called when user makes a move (optional hook)
  void onMove(int row, int col) {}

  /// Called when game resets (optional hook)
  void onGameReset() {}
}

/// Base class for implementing game features
abstract class BaseGameFeature implements GameFeature {
  @override
  bool isActive = false;

  @override
  bool isInitialized = false;

  GameContext? _context;

  /// Access to game context
  GameContext get context {
    if (_context == null) {
      throw StateError('Feature not initialized. Call initialize() first.');
    }
    return _context!;
  }

  @override
  Future<void> initialize(GameContext context) async {
    if (isInitialized) {
      return;
    }

    _context = context;
    await onInitialize();
    isInitialized = true;
  }

  @override
  Future<void> activate() async {
    if (!isInitialized) {
      throw StateError('Feature must be initialized before activation');
    }

    if (isActive) {
      return;
    }

    await onActivate();
    isActive = true;
  }

  @override
  Future<void> deactivate() async {
    if (!isActive) {
      return;
    }

    await onDeactivate();
    isActive = false;
  }

  @override
  void dispose() {
    if (isActive) {
      // Manually deactivate without async
      onDeactivate();
      isActive = false;
    }

    onDispose();
    _context = null;
    isInitialized = false;
  }

  /// Override this for custom initialization logic
  Future<void> onInitialize() async {}

  /// Override this for custom activation logic
  Future<void> onActivate() async {}

  /// Override this for custom deactivation logic
  Future<void> onDeactivate() async {}

  /// Override this for custom disposal logic
  void onDispose() {}

  @override
  Widget? buildUI(BuildContext context) => null;

  @override
  void onGameStateChanged() {}

  @override
  void onMove(int row, int col) {}

  @override
  void onGameReset() {}
}
