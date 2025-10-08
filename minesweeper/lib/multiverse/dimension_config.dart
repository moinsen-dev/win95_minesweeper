import 'package:flutter/material.dart';
import 'game_dimension.dart';

/// Configuration for a game dimension including visual styling and behavior
class DimensionConfig {
  /// The dimension this config represents
  final GameDimension dimension;

  /// Display name shown to users
  final String name;

  /// Short description/tagline
  final String tagline;

  /// Accent color for UI elements in this dimension
  final Color accentColor;

  /// Icon representing this dimension
  final IconData icon;

  /// Whether this dimension preserves game state when switched away
  final bool preservesGameStateOnSwitch;

  /// Whether this dimension requires AI engine processing
  final bool requiresAIEngine;

  /// Whether this dimension is currently enabled (for phased rollout)
  final bool isEnabled;

  const DimensionConfig({
    required this.dimension,
    required this.name,
    required this.tagline,
    required this.accentColor,
    required this.icon,
    this.preservesGameStateOnSwitch = false,
    this.requiresAIEngine = false,
    this.isEnabled = true,
  });

  /// Creates a DimensionConfig with default values for a given dimension
  factory DimensionConfig.fromDimension(GameDimension dimension) {
    return DimensionConfig(
      dimension: dimension,
      name: dimension.displayName,
      tagline: dimension.tagline,
      accentColor: _getDefaultAccentColor(dimension),
      icon: _getDefaultIcon(dimension),
      preservesGameStateOnSwitch: _shouldPreserveState(dimension),
      requiresAIEngine: _requiresAI(dimension),
      isEnabled: _isEnabledByDefault(dimension),
    );
  }

  /// Returns default accent color for a dimension
  static Color _getDefaultAccentColor(GameDimension dimension) {
    switch (dimension) {
      case GameDimension.classic:
        return Colors.grey.shade700; // Win95 classic gray
      case GameDimension.aiAssistant:
        return Colors.blue.shade600; // Helpful blue
      case GameDimension.xrayVision:
        return Colors.green.shade600; // Matrix-style green
      case GameDimension.ghostPlayer:
        return Colors.purple.shade600; // Mysterious purple
      case GameDimension.timeMachine:
        return Colors.amber.shade600; // Time-travel gold
      case GameDimension.adaptiveDifficulty:
        return Colors.teal.shade600; // Balanced teal
      case GameDimension.patternSensei:
        return Colors.orange.shade600; // Teaching orange
      case GameDimension.voiceCommander:
        return Colors.red.shade600; // Command red
      case GameDimension.ghostRacing:
        return Colors.cyan.shade600; // Racing cyan
      case GameDimension.emotionalAI:
        return Colors.pink.shade600; // Empathetic pink
      case GameDimension.dreamBoards:
        return Colors.deepPurple.shade600; // Creative purple
    }
  }

  /// Returns default icon for a dimension
  static IconData _getDefaultIcon(GameDimension dimension) {
    switch (dimension) {
      case GameDimension.classic:
        return Icons.grid_on;
      case GameDimension.aiAssistant:
        return Icons.assistant;
      case GameDimension.xrayVision:
        return Icons.visibility;
      case GameDimension.ghostPlayer:
        return Icons.smart_toy;
      case GameDimension.timeMachine:
        return Icons.history;
      case GameDimension.adaptiveDifficulty:
        return Icons.trending_up;
      case GameDimension.patternSensei:
        return Icons.school;
      case GameDimension.voiceCommander:
        return Icons.mic;
      case GameDimension.ghostRacing:
        return Icons.speed;
      case GameDimension.emotionalAI:
        return Icons.favorite;
      case GameDimension.dreamBoards:
        return Icons.palette;
    }
  }

  /// Returns whether this dimension should preserve game state
  static bool _shouldPreserveState(GameDimension dimension) {
    switch (dimension) {
      case GameDimension.classic:
      case GameDimension.aiAssistant:
      case GameDimension.xrayVision:
      case GameDimension.patternSensei:
      case GameDimension.emotionalAI:
        return true; // These enhance current game
      case GameDimension.ghostPlayer:
      case GameDimension.timeMachine:
      case GameDimension.adaptiveDifficulty:
      case GameDimension.voiceCommander:
      case GameDimension.ghostRacing:
      case GameDimension.dreamBoards:
        return false; // These need fresh boards
    }
  }

  /// Returns whether this dimension requires AI processing
  static bool _requiresAI(GameDimension dimension) {
    switch (dimension) {
      case GameDimension.classic:
        return false;
      case GameDimension.aiAssistant:
      case GameDimension.xrayVision:
      case GameDimension.ghostPlayer:
      case GameDimension.timeMachine:
      case GameDimension.adaptiveDifficulty:
      case GameDimension.patternSensei:
      case GameDimension.emotionalAI:
      case GameDimension.dreamBoards:
        return true;
      case GameDimension.voiceCommander:
      case GameDimension.ghostRacing:
        return false; // Voice and racing don't need board AI
    }
  }

  /// Returns whether dimension is enabled by default (for phased rollout)
  static bool _isEnabledByDefault(GameDimension dimension) {
    switch (dimension) {
      case GameDimension.classic:
      case GameDimension.aiAssistant:
        return true; // MVP features
      default:
        return false; // Disabled until implemented
    }
  }

  DimensionConfig copyWith({
    GameDimension? dimension,
    String? name,
    String? tagline,
    Color? accentColor,
    IconData? icon,
    bool? preservesGameStateOnSwitch,
    bool? requiresAIEngine,
    bool? isEnabled,
  }) {
    return DimensionConfig(
      dimension: dimension ?? this.dimension,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      accentColor: accentColor ?? this.accentColor,
      icon: icon ?? this.icon,
      preservesGameStateOnSwitch:
          preservesGameStateOnSwitch ?? this.preservesGameStateOnSwitch,
      requiresAIEngine: requiresAIEngine ?? this.requiresAIEngine,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
