/// Enum representing the 11 different game dimensions in the multiverse
enum GameDimension {
  /// Classic Win95 Minesweeper experience (default)
  classic,

  /// AI Assistant with Clippy-inspired helper
  aiAssistant,

  /// X-Ray Vision showing probability heatmap
  xrayVision,

  /// Ghost Player demonstrating optimal moves
  ghostPlayer,

  /// Time Machine exploring alternate realities
  timeMachine,

  /// Adaptive Difficulty that learns player skill
  adaptiveDifficulty,

  /// Pattern Sensei teaching advanced patterns
  patternSensei,

  /// Voice Commander for voice-controlled gameplay
  voiceCommander,

  /// Ghost Racing against AI opponents
  ghostRacing,

  /// Emotional AI detecting frustration
  emotionalAI,

  /// Dream Boards with AI-generated themed puzzles
  dreamBoards;

  /// Returns the display name for this dimension
  String get displayName {
    switch (this) {
      case GameDimension.classic:
        return 'Classic Mode';
      case GameDimension.aiAssistant:
        return 'AI Assistant';
      case GameDimension.xrayVision:
        return 'X-Ray Vision';
      case GameDimension.ghostPlayer:
        return 'Ghost Player';
      case GameDimension.timeMachine:
        return 'Time Machine';
      case GameDimension.adaptiveDifficulty:
        return 'Adaptive Difficulty';
      case GameDimension.patternSensei:
        return 'Pattern Sensei';
      case GameDimension.voiceCommander:
        return 'Voice Commander';
      case GameDimension.ghostRacing:
        return 'Ghost Racing';
      case GameDimension.emotionalAI:
        return 'Emotional AI';
      case GameDimension.dreamBoards:
        return 'Dream Boards';
    }
  }

  /// Returns a tagline description for this dimension
  String get tagline {
    switch (this) {
      case GameDimension.classic:
        return 'The original Win95 experience';
      case GameDimension.aiAssistant:
        return 'Get hints from your AI helper';
      case GameDimension.xrayVision:
        return 'See mine probabilities';
      case GameDimension.ghostPlayer:
        return 'Watch AI solve the board';
      case GameDimension.timeMachine:
        return 'Explore what-if scenarios';
      case GameDimension.adaptiveDifficulty:
        return 'Boards tailored to your skill';
      case GameDimension.patternSensei:
        return 'Learn advanced techniques';
      case GameDimension.voiceCommander:
        return 'Control with voice commands';
      case GameDimension.ghostRacing:
        return 'Race against AI opponents';
      case GameDimension.emotionalAI:
        return 'AI that understands frustration';
      case GameDimension.dreamBoards:
        return 'Artistic AI-generated puzzles';
    }
  }
}
