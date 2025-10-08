/// Different personalities for the AI assistant
enum AssistantPersonality {
  /// Supportive and encouraging
  encouraging,

  /// Tactical and strategic
  strategic,

  /// Light-hearted and funny
  humorous,

  /// Calm and meditative
  zen;

  String get displayName {
    switch (this) {
      case AssistantPersonality.encouraging:
        return 'Encouraging';
      case AssistantPersonality.strategic:
        return 'Strategic';
      case AssistantPersonality.humorous:
        return 'Humorous';
      case AssistantPersonality.zen:
        return 'Zen';
    }
  }

  String get description {
    switch (this) {
      case AssistantPersonality.encouraging:
        return 'Supportive and positive';
      case AssistantPersonality.strategic:
        return 'Tactical and analytical';
      case AssistantPersonality.humorous:
        return 'Fun and light-hearted';
      case AssistantPersonality.zen:
        return 'Calm and meditative';
    }
  }

  /// Get a greeting message for this personality
  String get greeting {
    switch (this) {
      case AssistantPersonality.encouraging:
        return "Hi there! I'm here to help you succeed! 🌟";
      case AssistantPersonality.strategic:
        return "Ready to analyze and strategize. Let's solve this methodically.";
      case AssistantPersonality.humorous:
        return "Hey! Let's have some fun defusing these digital bombs! 💣😄";
      case AssistantPersonality.zen:
        return "Welcome. Let us find clarity in the chaos... 🧘";
    }
  }

  /// Get a hint prefix for this personality
  String get hintPrefix {
    switch (this) {
      case AssistantPersonality.encouraging:
        return "You've got this! I suggest";
      case AssistantPersonality.strategic:
        return "Strategic analysis indicates";
      case AssistantPersonality.humorous:
        return "So, here's a wild idea:";
      case AssistantPersonality.zen:
        return "The path reveals itself:";
    }
  }

  /// Get a victory message
  String get victoryMessage {
    switch (this) {
      case AssistantPersonality.encouraging:
        return "Amazing work! You did it! I knew you could! 🎉";
      case AssistantPersonality.strategic:
        return "Victory achieved through superior tactics. Well played.";
      case AssistantPersonality.humorous:
        return "BOOM! Wait, no boom. That's good! You won! 🎊";
      case AssistantPersonality.zen:
        return "Balance has been achieved. Well done. ☯️";
    }
  }

  /// Get a loss message
  String get lossMessage {
    switch (this) {
      case AssistantPersonality.encouraging:
        return "That's okay! Every loss is a learning opportunity. Try again!";
      case AssistantPersonality.strategic:
        return "Analyzing failure points. Ready for tactical reassessment.";
      case AssistantPersonality.humorous:
        return "Well, at least it was a *spectacular* explosion! 💥 Again?";
      case AssistantPersonality.zen:
        return "Even in defeat, there is wisdom. Shall we try again?";
    }
  }
}
