import 'package:flutter/foundation.dart';
import 'game_feature.dart';
import 'game_context.dart';
import '../multiverse/game_dimension.dart';

/// Manages feature lifecycle and coordination
class FeatureManager {
  /// Game context shared across features
  final GameContext context;

  /// Map of dimension to its features
  final Map<GameDimension, List<GameFeature>> _dimensionFeatures = {};

  /// Currently active features
  final Set<GameFeature> _activeFeatures = {};

  /// Currently initialized features
  final Set<GameFeature> _initializedFeatures = {};

  FeatureManager({required this.context});

  /// Register features for a dimension
  void registerDimensionFeatures(
    GameDimension dimension,
    List<GameFeature> features,
  ) {
    _dimensionFeatures[dimension] = features;
  }

  /// Get features for a dimension
  List<GameFeature> getFeaturesForDimension(GameDimension dimension) {
    return _dimensionFeatures[dimension] ?? [];
  }

  /// Activate all features for a dimension
  Future<void> activateDimension(
    GameDimension dimension, {
    bool preserveState = false,
  }) async {
    final features = getFeaturesForDimension(dimension);

    if (features.isEmpty) {
      debugPrint('No features registered for dimension: $dimension');
      return;
    }

    // Save state if needed
    if (preserveState && !context.hasSavedState) {
      context.saveState();
    }

    // Initialize features if needed
    for (final feature in features) {
      if (!feature.isInitialized) {
        debugPrint('Initializing feature: ${feature.name}');
        await feature.initialize(context);
        _initializedFeatures.add(feature);
      }
    }

    // Activate features
    for (final feature in features) {
      if (!feature.isActive) {
        debugPrint('Activating feature: ${feature.name}');
        await feature.activate();
        _activeFeatures.add(feature);
      }
    }

    debugPrint('Activated ${features.length} features for $dimension');
  }

  /// Deactivate all features for a dimension
  Future<void> deactivateDimension(
    GameDimension dimension, {
    bool clearState = false,
  }) async {
    final features = getFeaturesForDimension(dimension);

    if (features.isEmpty) {
      return;
    }

    // Deactivate features
    for (final feature in features) {
      if (feature.isActive) {
        debugPrint('Deactivating feature: ${feature.name}');
        await feature.deactivate();
        _activeFeatures.remove(feature);
      }
    }

    // Clear saved state if requested
    if (clearState) {
      context.clearSavedState();
    }

    debugPrint('Deactivated ${features.length} features for $dimension');
  }

  /// Switch from one dimension to another
  Future<void> switchDimension(
    GameDimension fromDimension,
    GameDimension toDimension, {
    required bool preserveState,
  }) async {
    // Deactivate old dimension
    await deactivateDimension(fromDimension, clearState: !preserveState);

    // Activate new dimension
    await activateDimension(toDimension, preserveState: preserveState);

    // Restore state if needed
    if (preserveState && context.hasSavedState) {
      context.restoreState();
    }
  }

  /// Get all currently active features
  List<GameFeature> get activeFeatures => List.unmodifiable(_activeFeatures);

  /// Get all initialized features
  List<GameFeature> get initializedFeatures =>
      List.unmodifiable(_initializedFeatures);

  /// Notify all active features of a game state change
  void notifyGameStateChanged() {
    for (final feature in _activeFeatures) {
      feature.onGameStateChanged();
    }
    context.notifyGameStateChanged();
  }

  /// Notify all active features of a move
  void notifyMove(int row, int col) {
    for (final feature in _activeFeatures) {
      feature.onMove(row, col);
    }
    context.notifyMove(row, col);
  }

  /// Notify all active features of a reset
  void notifyGameReset() {
    for (final feature in _activeFeatures) {
      feature.onGameReset();
    }
    context.notifyReset();
  }

  /// Dispose of all features
  void dispose() {
    // Dispose all initialized features
    for (final feature in _initializedFeatures) {
      debugPrint('Disposing feature: ${feature.name}');
      feature.dispose();
    }

    _activeFeatures.clear();
    _initializedFeatures.clear();
    _dimensionFeatures.clear();
    context.dispose();
  }

  /// Get total number of registered features
  int get totalFeatureCount {
    return _dimensionFeatures.values.fold(0, (sum, features) => sum + features.length);
  }

  /// Check if a dimension has any registered features
  bool hasFeaturesForDimension(GameDimension dimension) {
    return _dimensionFeatures.containsKey(dimension) &&
        _dimensionFeatures[dimension]!.isNotEmpty;
  }
}
