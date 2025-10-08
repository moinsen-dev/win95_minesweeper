import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_dimension.dart';
import 'dimension_config.dart';

/// Manages the multiverse system, handling dimension switching and state
class MultiverseManager extends ChangeNotifier {
  /// Current active dimension
  GameDimension _currentDimension = GameDimension.classic;

  /// Previous dimension (for undo functionality)
  GameDimension? _previousDimension;

  /// History of dimension switches
  final List<GameDimension> _dimensionHistory = [];

  /// Configuration for all dimensions
  final Map<GameDimension, DimensionConfig> _configs = {};

  /// Random number generator for shuffle
  final Random _random = Random();

  /// SharedPreferences instance for persistence
  SharedPreferences? _prefs;

  /// Whether the manager has been initialized
  bool _isInitialized = false;

  MultiverseManager() {
    // Initialize configs for all dimensions
    for (final dimension in GameDimension.values) {
      _configs[dimension] = DimensionConfig.fromDimension(dimension);
    }
    _initialize();
  }

  /// Current active dimension
  GameDimension get currentDimension => _currentDimension;

  /// Previous dimension (if any)
  GameDimension? get previousDimension => _previousDimension;

  /// Current dimension's configuration
  DimensionConfig get currentConfig => _configs[_currentDimension]!;

  /// All dimension configs
  Map<GameDimension, DimensionConfig> get configs => Map.unmodifiable(_configs);

  /// Dimension switch history
  List<GameDimension> get dimensionHistory => List.unmodifiable(_dimensionHistory);

  /// Whether the manager is ready
  bool get isInitialized => _isInitialized;

  /// Initialize the manager by loading saved state
  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadState();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize MultiverseManager: $e');
      _isInitialized = true; // Continue with defaults
      notifyListeners();
    }
  }

  /// Load dimension state from persistent storage
  Future<void> _loadState() async {
    if (_prefs == null) return;

    // Load current dimension
    final dimensionIndex = _prefs!.getInt('current_dimension');
    if (dimensionIndex != null &&
        dimensionIndex >= 0 &&
        dimensionIndex < GameDimension.values.length) {
      _currentDimension = GameDimension.values[dimensionIndex];
    }

    // Load dimension history
    final historyIndices = _prefs!.getStringList('dimension_history');
    if (historyIndices != null) {
      _dimensionHistory.clear();
      for (final indexStr in historyIndices) {
        final index = int.tryParse(indexStr);
        if (index != null &&
            index >= 0 &&
            index < GameDimension.values.length) {
          _dimensionHistory.add(GameDimension.values[index]);
        }
      }
    }
  }

  /// Save dimension state to persistent storage
  Future<void> _saveState() async {
    if (_prefs == null) return;

    try {
      await _prefs!.setInt('current_dimension', _currentDimension.index);

      final historyIndices = _dimensionHistory
          .map((d) => d.index.toString())
          .toList();
      await _prefs!.setStringList('dimension_history', historyIndices);
    } catch (e) {
      debugPrint('Failed to save dimension state: $e');
    }
  }

  /// Switch to a specific dimension
  Future<void> switchToDimension(GameDimension dimension) async {
    if (_currentDimension == dimension) return;

    final config = _configs[dimension];
    if (config == null || !config.isEnabled) {
      debugPrint('Dimension $dimension is not enabled');
      return;
    }

    _previousDimension = _currentDimension;
    _currentDimension = dimension;

    // Add to history (limit to last 50)
    _dimensionHistory.add(dimension);
    if (_dimensionHistory.length > 50) {
      _dimensionHistory.removeAt(0);
    }

    await _saveState();
    notifyListeners();
  }

  /// Shuffle to a random dimension (excluding current)
  Future<void> shuffleDimension() async {
    final enabledDimensions = GameDimension.values
        .where((d) => _configs[d]!.isEnabled && d != _currentDimension)
        .toList();

    if (enabledDimensions.isEmpty) {
      debugPrint('No other enabled dimensions to shuffle to');
      return;
    }

    final randomDimension = enabledDimensions[_random.nextInt(enabledDimensions.length)];
    await switchToDimension(randomDimension);
  }

  /// Switch back to the previous dimension
  Future<void> undoDimensionSwitch() async {
    if (_previousDimension == null) {
      debugPrint('No previous dimension to switch to');
      return;
    }

    await switchToDimension(_previousDimension!);
  }

  /// Enable or disable a dimension (for phased rollout)
  void setDimensionEnabled(GameDimension dimension, bool enabled) {
    final config = _configs[dimension];
    if (config != null) {
      _configs[dimension] = config.copyWith(isEnabled: enabled);
      notifyListeners();
    }
  }

  /// Update configuration for a dimension
  void updateDimensionConfig(GameDimension dimension, DimensionConfig config) {
    _configs[dimension] = config;
    notifyListeners();
  }

  /// Get statistics about dimension usage
  Map<GameDimension, int> getDimensionUsageStats() {
    final stats = <GameDimension, int>{};

    for (final dimension in GameDimension.values) {
      stats[dimension] = 0;
    }

    for (final dimension in _dimensionHistory) {
      stats[dimension] = (stats[dimension] ?? 0) + 1;
    }

    return stats;
  }

  /// Get favorite dimension (most used)
  GameDimension? getFavoriteDimension() {
    final stats = getDimensionUsageStats();
    if (stats.isEmpty) return null;

    GameDimension? favorite;
    int maxCount = 0;

    stats.forEach((dimension, count) {
      if (count > maxCount) {
        maxCount = count;
        favorite = dimension;
      }
    });

    return favorite;
  }

  /// Clear dimension history
  Future<void> clearHistory() async {
    _dimensionHistory.clear();
    await _saveState();
    notifyListeners();
  }

  /// Reset to default state
  Future<void> reset() async {
    _currentDimension = GameDimension.classic;
    _previousDimension = null;
    _dimensionHistory.clear();

    // Reset all configs to defaults
    for (final dimension in GameDimension.values) {
      _configs[dimension] = DimensionConfig.fromDimension(dimension);
    }

    await _saveState();
    notifyListeners();
  }
}
