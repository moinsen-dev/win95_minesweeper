import 'package:flutter/material.dart';
import '../../multiverse/game_dimension.dart';
import '../../multiverse/dimension_config.dart';

/// Callback for when dimension shift animation completes
typedef AnimationCompleteCallback = void Function();

/// Stateful widget that orchestrates dimension shift animations
class DimensionShiftAnimation extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// The new dimension being switched to
  final GameDimension newDimension;

  /// Configuration for the new dimension
  final DimensionConfig newConfig;

  /// Whether animation is currently playing
  final bool isAnimating;

  /// Callback when animation completes
  final AnimationCompleteCallback? onAnimationComplete;

  const DimensionShiftAnimation({
    super.key,
    required this.child,
    required this.newDimension,
    required this.newConfig,
    this.isAnimating = false,
    this.onAnimationComplete,
  });

  @override
  State<DimensionShiftAnimation> createState() =>
      _DimensionShiftAnimationState();
}

class _DimensionShiftAnimationState extends State<DimensionShiftAnimation>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _shakeController;
  late AnimationController _glitchController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _shakeAnimation;
  late Animation<double> _glitchAnimation;
  late Animation<double> _fadeAnimation;

  // State
  bool _isAnimating = false;
  bool _showAnnouncement = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Shake animation: 200ms
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeAnimation = CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    );

    // Glitch animation: 300ms
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _glitchAnimation = CurvedAnimation(
      parent: _glitchController,
      curve: Curves.easeInOut,
    );

    // Fade animation: 400ms
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void didUpdateWidget(DimensionShiftAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start animation sequence when isAnimating changes to true
    if (widget.isAnimating && !oldWidget.isAnimating && !_isAnimating) {
      _playAnimationSequence();
    }
  }

  Future<void> _playAnimationSequence() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    try {
      // Step 1: Shake animation (200ms)
      await _shakeController.forward();
      await _shakeController.reverse();

      // Step 2: Glitch effect (300ms)
      await _glitchController.forward();

      // Step 3: Show announcement overlay
      setState(() {
        _showAnnouncement = true;
      });

      // Step 4: Fade transition (400ms)
      await _fadeController.forward();

      // Wait a brief moment for announcement to be visible
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Fade out announcement
      await _fadeController.reverse();

      // Hide announcement
      setState(() {
        _showAnnouncement = false;
      });

      // Reset animations
      await _glitchController.reverse();

    } finally {
      setState(() {
        _isAnimating = false;
      });

      // Notify completion
      widget.onAnimationComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main content with animations
        AnimatedBuilder(
          animation: Listenable.merge([
            _shakeController,
            _glitchController,
            _fadeController,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _shakeAnimation.value * 10 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1),
                _shakeAnimation.value * 10 * (DateTime.now().millisecond % 3 == 0 ? 1 : -1),
              ),
              child: GlitchEffect(
                intensity: _glitchAnimation.value,
                child: widget.child,
              ),
            );
          },
        ),

        // Dimension announcement overlay
        if (_showAnnouncement)
          DimensionAnnouncement(
            dimension: widget.newDimension,
            config: widget.newConfig,
            fadeAnimation: _fadeAnimation,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glitchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

/// Widget that creates a CRT glitch effect
class GlitchEffect extends StatelessWidget {
  final Widget child;
  final double intensity;

  const GlitchEffect({
    super.key,
    required this.child,
    this.intensity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (intensity <= 0.0) {
      return child;
    }

    return Stack(
      children: [
        // Original child
        child,

        // Glitch overlay
        if (intensity > 0.0)
          Positioned.fill(
            child: Opacity(
              opacity: intensity * 0.3,
              child: CustomPaint(
                painter: GlitchPainter(intensity: intensity),
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter for CRT glitch effect
class GlitchPainter extends CustomPainter {
  final double intensity;

  GlitchPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0.0) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.difference;

    // Draw horizontal scan lines
    for (double y = 0; y < size.height; y += 4) {
      if (DateTime.now().millisecond % 3 == 0) {
        paint.color = Colors.green.withOpacity(intensity * 0.2);
        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, 2),
          paint,
        );
      }
    }

    // Draw random glitch bars
    final random = DateTime.now().millisecond;
    for (int i = 0; i < (intensity * 5).toInt(); i++) {
      final barY = (random * (i + 1)) % size.height;
      final barHeight = 20.0 + (random % 30);

      paint.color = (i % 2 == 0 ? Colors.red : Colors.cyan)
          .withOpacity(intensity * 0.15);

      canvas.drawRect(
        Rect.fromLTWH(0, barY, size.width, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GlitchPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

/// Overlay that announces the new dimension
class DimensionAnnouncement extends StatelessWidget {
  final GameDimension dimension;
  final DimensionConfig config;
  final Animation<double> fadeAnimation;

  const DimensionAnnouncement({
    super.key,
    required this.dimension,
    required this.config,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dimension icon
                  Icon(
                    config.icon,
                    size: 80,
                    color: config.accentColor,
                  ),
                  const SizedBox(height: 24),

                  // Dimension name
                  Text(
                    config.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: config.accentColor,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Dimension tagline
                  Text(
                    config.tagline,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Retro "dimension shift" indicator
                  Text(
                    '>>> DIMENSION SHIFT <<<',
                    style: TextStyle(
                      fontSize: 14,
                      color: config.accentColor.withOpacity(0.7),
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
