import 'package:flutter/material.dart';
import '../features/ai_assistant/ai_assistant_feature.dart';
import '../features/ai_assistant/assistant_personality.dart';
import '../features/ai_assistant/hint_engine.dart';
import 'win95_panel.dart';
import 'win95_button.dart';

/// UI panel for the AI Assistant
class AIAssistantPanel extends StatefulWidget {
  final AIAssistantFeature assistant;

  const AIAssistantPanel({
    super.key,
    required this.assistant,
  });

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  AssistantHint? _currentHint;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Debug: Check feature state
    debugPrint('AI Assistant Panel: Building UI');
    debugPrint('  - Feature active: ${widget.assistant.isActive}');
    debugPrint('  - Feature initialized: ${widget.assistant.isInitialized}');
    debugPrint('  - Hints enabled: ${widget.assistant.hintsEnabled}');

    return Win95Panel(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact header
          Row(
            children: [
              const Icon(Icons.assistant, size: 14, color: Color(0xFF000080)),
              const SizedBox(width: 4),
              Text(
                widget.assistant.isActive
                  ? (widget.assistant.hintsEnabled ? 'AI' : 'AI (Off)')
                  : 'AI (Inactive)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.assistant.isActive ? const Color(0xFF000080) : Colors.red,
                ),
              ),
              const Spacer(),
              // Hints toggle
              IconButton(
                icon: Icon(
                  widget.assistant.hintsEnabled
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
                  size: 14,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () {
                  setState(() {
                    widget.assistant.toggleHints();
                  });
                },
                tooltip: widget.assistant.hintsEnabled ? 'Disable' : 'Enable',
              ),
            ],
          ),

          const SizedBox(height: 3),

          // Personality selector
          _buildPersonalitySelector(),

          const SizedBox(height: 3),

          // Hint display area
          if (_currentHint != null)
            _buildHintDisplay(_currentHint!),

          if (_currentHint == null && !_isLoading)
            _buildPlaceholder(),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          const SizedBox(height: 3),

          // Get hint button
          SizedBox(
            height: 28,
            child: Win95Button(
              onPressed: widget.assistant.hintsEnabled
                  ? () {
                      debugPrint('Get Hint button tapped!');
                      _getHint();
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _isLoading ? 'Loading...' : 'Get Hint',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalitySelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black54),
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: AssistantPersonality.values.map((personality) {
          final isSelected = widget.assistant.personality == personality;
          return InkWell(
            onTap: () {
              setState(() {
                widget.assistant.personality = personality;
                _currentHint = null; // Clear current hint
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF000080) : Colors.grey.shade200,
                border: Border.all(color: Colors.black54),
              ),
              child: Text(
                personality.displayName,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHintDisplay(AssistantHint hint) {
    IconData icon;
    Color iconColor;

    switch (hint.type) {
      case HintType.definitelySafe:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case HintType.safeMove:
        icon = Icons.check_circle_outline;
        iconColor = Colors.green.shade700;
        break;
      case HintType.pattern:
        icon = Icons.auto_awesome;
        iconColor = Colors.blue;
        break;
      case HintType.probability:
        icon = Icons.bar_chart;
        iconColor = Colors.orange;
        break;
      case HintType.warning:
        icon = Icons.warning;
        iconColor = Colors.red;
        break;
      case HintType.encouragement:
        icon = Icons.star;
        iconColor = Colors.amber;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hint.message,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          if (hint.position != null) ...[
            const SizedBox(height: 4),
            Text(
              'Row ${hint.position!.row + 1}, Col ${hint.position!.col + 1}',
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black54,
                fontFamily: 'monospace',
              ),
            ),
          ],
          const SizedBox(height: 4),
          // Confidence bar
          Row(
            children: [
              const Text(
                'Confidence: ',
                style: TextStyle(fontSize: 9, color: Colors.black54),
              ),
              Expanded(
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: hint.confidence,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hint.confidence > 0.7
                          ? Colors.green
                          : hint.confidence > 0.4
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(hint.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    final greeting = widget.assistant.personality.greeting;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.assistant,
            size: 32,
            color: Colors.black26,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              greeting,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getHint() async {
    debugPrint('=== GET HINT BUTTON PRESSED ===');
    debugPrint('Feature active: ${widget.assistant.isActive}');
    debugPrint('Feature initialized: ${widget.assistant.isInitialized}');
    debugPrint('Hints enabled: ${widget.assistant.hintsEnabled}');

    if (!mounted) {
      debugPrint('Widget not mounted, aborting');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    debugPrint('Loading state set, calling getHint()...');

    try {
      final hint = await widget.assistant.getHint();

      debugPrint('getHint() returned: ${hint != null ? "hint" : "null"}');

      if (!mounted) {
        debugPrint('Widget unmounted after getHint');
        return;
      }

      setState(() {
        _currentHint = hint;
        _isLoading = false;
      });

      // Debug: Show if no hint was returned
      if (hint == null) {
        debugPrint('AI Assistant: No hint available - displaying placeholder');
      } else {
        debugPrint('AI Assistant: Hint displayed successfully');
      }
    } catch (e, stackTrace) {
      debugPrint('AI Assistant error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _currentHint = AssistantHint(
          type: HintType.encouragement,
          message: 'Oops! I encountered an error. Try again?',
          confidence: 0.5,
        );
        _isLoading = false;
      });
    }
  }
}
