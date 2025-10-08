import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Tutorial overlay that explains shake mechanic on first launch
class ShakeHint extends StatefulWidget {
  final VoidCallback onDismiss;
  final bool showKeyboardHint;

  const ShakeHint({
    super.key,
    required this.onDismiss,
    this.showKeyboardHint = false,
  });

  @override
  State<ShakeHint> createState() => _ShakeHintState();
}

class _ShakeHintState extends State<ShakeHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _shakeAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _hintMessage {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'Press Ctrl+Shift+D to switch dimensions';
    }
    if (widget.showKeyboardHint) {
      return 'Shake your device or tap the button to switch dimensions';
    }
    return 'Shake your device to switch dimensions';
  }

  IconData get _hintIcon {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return Icons.keyboard;
    }
    return Icons.phone_android;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated phone/keyboard icon
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: Icon(
                            _hintIcon,
                            size: 80,
                            color: Colors.blueAccent,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Welcome to the Multiverse!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Hint message
                    Text(
                      _hintMessage,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Features list
                    _buildFeaturesList(),

                    const SizedBox(height: 32),

                    // Got it button
                    ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Got it!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onDismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore 11 Dimensions:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          _buildFeature('🎮 Classic Mode', 'Original Win95 experience'),
          _buildFeature('🤖 AI Assistant', 'Get hints from your helper'),
          _buildFeature('👁️ X-Ray Vision', 'See mine probabilities'),
          _buildFeature('👻 Ghost Player', 'Watch AI solve boards'),
          _buildFeature('⏰ Time Machine', 'Explore what-if scenarios'),
          const SizedBox(height: 8),
          const Text(
            '...and 6 more!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white60,
              fontFamily: 'monospace',
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Persistent hint badge that can be shown in the corner
class ShakeHintBadge extends StatelessWidget {
  final VoidCallback onTap;

  const ShakeHintBadge({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'Shake to switch',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
