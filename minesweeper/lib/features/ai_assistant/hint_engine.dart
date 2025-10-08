import '../../ai/board_analyzer.dart';
import '../../ai/cell_probabilities.dart';
import '../../models/game_state.dart';
import 'assistant_personality.dart';

/// Types of hints that can be given
enum HintType {
  safeMove,
  definitelySafe,
  pattern,
  probability,
  encouragement,
  warning,
}

/// A hint from the AI assistant
class AssistantHint {
  /// Type of hint
  final HintType type;

  /// The hint message
  final String message;

  /// Position this hint refers to (if any)
  final Position? position;

  /// Confidence level (0.0 - 1.0)
  final double confidence;

  /// Additional positions (for patterns)
  final List<Position> additionalPositions;

  const AssistantHint({
    required this.type,
    required this.message,
    this.position,
    this.confidence = 1.0,
    this.additionalPositions = const [],
  });
}

/// Engine for generating contextual hints
class HintEngine {
  final BoardAnalyzer analyzer;
  final AssistantPersonality personality;

  HintEngine({
    required this.analyzer,
    required this.personality,
  });

  /// Generate a hint based on current board analysis
  AssistantHint? generateHint({
    required BoardAnalysisResult analysis,
    required GameState gameState,
    required AssistantPersonality personality,
  }) {
    // Game over states
    if (gameState == GameState.won) {
      return AssistantHint(
        type: HintType.encouragement,
        message: personality.victoryMessage,
        confidence: 1.0,
      );
    }

    if (gameState == GameState.lost) {
      return AssistantHint(
        type: HintType.encouragement,
        message: personality.lossMessage,
        confidence: 1.0,
      );
    }

    // Game not started yet
    if (gameState == GameState.ready) {
      return AssistantHint(
        type: HintType.encouragement,
        message: _getReadyMessage(personality),
        confidence: 1.0,
      );
    }

    // Look for safe moves first
    if (analysis.safeMoves.isNotEmpty) {
      final pos = analysis.safeMoves.first;
      return AssistantHint(
        type: HintType.definitelySafe,
        message: _getSafeMoveMessage(personality, pos),
        position: pos,
        confidence: 1.0,
      );
    }

    // Look for patterns
    if (analysis.patterns.isNotEmpty) {
      final pattern = analysis.patterns.first;
      return AssistantHint(
        type: HintType.pattern,
        message: _getPatternMessage(personality, pattern),
        position: pattern.cells.isNotEmpty ? pattern.cells.first : null,
        additionalPositions: pattern.cells,
        confidence: 0.9,
      );
    }

    // Suggest lowest probability move
    if (analysis.bestMove != null) {
      final pos = analysis.bestMove!;
      final prob = analysis.probabilities[pos];

      if (prob != null) {
        return AssistantHint(
          type: HintType.probability,
          message: _getProbabilityMessage(personality, pos, prob.probability),
          position: pos,
          confidence: 1.0 - prob.probability,
        );
      }
    }

    // No good hints available
    return AssistantHint(
      type: HintType.encouragement,
      message: _getNoHintMessage(personality),
      confidence: 0.5,
    );
  }

  String _getReadyMessage(AssistantPersonality personality) {
    switch (personality) {
      case AssistantPersonality.encouraging:
        return "Ready to start? Click any cell to begin your journey!";
      case AssistantPersonality.strategic:
        return "Initialize game state. First move recommended: corner or center.";
      case AssistantPersonality.humorous:
        return "It looks like you're about to play Minesweeper. Want some help? 😉";
      case AssistantPersonality.zen:
        return "The board awaits. Choose wisely, grasshopper.";
    }
  }

  String _getSafeMoveMessage(AssistantPersonality personality, Position pos) {
    final location = "row ${pos.row + 1}, column ${pos.col + 1}";

    switch (personality) {
      case AssistantPersonality.encouraging:
        return "${personality.hintPrefix} clicking $location - it's definitely safe! ✅";
      case AssistantPersonality.strategic:
        return "${personality.hintPrefix} $location is a confirmed safe cell. Execute.";
      case AssistantPersonality.humorous:
        return "${personality.hintPrefix} $location is safer than a pillow fort! 🛡️";
      case AssistantPersonality.zen:
        return "${personality.hintPrefix} $location holds no danger. Click with confidence.";
    }
  }

  String _getPatternMessage(AssistantPersonality personality, DetectedPattern pattern) {
    switch (personality) {
      case AssistantPersonality.encouraging:
        return "Great! I spotted a ${pattern.name}! ${pattern.description}";
      case AssistantPersonality.strategic:
        return "Pattern detected: ${pattern.name}. ${pattern.description}";
      case AssistantPersonality.humorous:
        return "Ooh, fancy! A ${pattern.name}! ${pattern.description} 🧐";
      case AssistantPersonality.zen:
        return "The pattern emerges: ${pattern.name}. ${pattern.description}";
    }
  }

  String _getProbabilityMessage(AssistantPersonality personality, Position pos, double probability) {
    final location = "row ${pos.row + 1}, column ${pos.col + 1}";
    final percentChance = ((1.0 - probability) * 100).toStringAsFixed(0);

    switch (personality) {
      case AssistantPersonality.encouraging:
        return "${personality.hintPrefix} $location - about $percentChance% safe!";
      case AssistantPersonality.strategic:
        return "Optimal move: $location. Success probability: $percentChance%.";
      case AssistantPersonality.humorous:
        return "$location has a $percentChance% chance of not exploding. Those are... odds! 🎲";
      case AssistantPersonality.zen:
        return "Consider $location. The universe suggests $percentChance% safety.";
    }
  }

  String _getNoHintMessage(AssistantPersonality personality) {
    switch (personality) {
      case AssistantPersonality.encouraging:
        return "This is tricky! Sometimes you just need to make your best guess. You can do it!";
      case AssistantPersonality.strategic:
        return "No definitive moves available. Recommend probabilistic approach.";
      case AssistantPersonality.humorous:
        return "Well, this is awkward. It's pure guesswork from here! 🤷";
      case AssistantPersonality.zen:
        return "Sometimes, clarity eludes us. Trust your intuition.";
    }
  }
}
