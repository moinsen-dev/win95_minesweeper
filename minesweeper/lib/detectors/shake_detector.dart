import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Callback type for shake events
typedef ShakeCallback = void Function();

/// Detects shake gestures using accelerometer data
class ShakeDetector {
  /// Threshold for shake detection in m/s² (configurable)
  double shakeThreshold;

  /// Cooldown period between shake detections in milliseconds
  final Duration shakeCooldown;

  /// Callback to invoke when shake is detected
  final ShakeCallback? onShake;

  /// Stream subscription for accelerometer events
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  /// Timestamp of last shake detection
  DateTime? _lastShakeTime;

  /// Whether the detector is currently active
  bool _isActive = false;

  /// Whether shake detection is supported on this platform
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Whether the detector is currently listening
  bool get isActive => _isActive;

  ShakeDetector({
    this.shakeThreshold = 20.0,
    this.shakeCooldown = const Duration(milliseconds: 1000),
    this.onShake,
  });

  /// Start listening for shake events
  void start() {
    if (!isSupported) {
      debugPrint('Shake detection not supported on this platform');
      return;
    }

    if (_isActive) {
      debugPrint('ShakeDetector already active');
      return;
    }

    _isActive = true;
    _accelerometerSubscription = accelerometerEventStream().listen(
      _handleAccelerometerEvent,
      onError: (error) {
        debugPrint('Accelerometer error: $error');
        stop();
      },
    );

    debugPrint('ShakeDetector started (threshold: $shakeThreshold m/s²)');
  }

  /// Stop listening for shake events
  void stop() {
    if (!_isActive) return;

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isActive = false;

    debugPrint('ShakeDetector stopped');
  }

  /// Handle accelerometer event
  void _handleAccelerometerEvent(AccelerometerEvent event) {
    // Calculate total acceleration magnitude
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    // Compute acceleration magnitude minus gravity
    final double acceleration = (x * x + y * y + z * z).abs();

    // Check if acceleration exceeds threshold
    if (_shouldTriggerShake(acceleration)) {
      _lastShakeTime = DateTime.now();
      onShake?.call();
      debugPrint('Shake detected! (acceleration: ${acceleration.toStringAsFixed(2)} m/s²)');
    }
  }

  /// Determine if shake should be triggered based on acceleration and cooldown
  bool _shouldTriggerShake(double acceleration) {
    // Check threshold
    if (acceleration < shakeThreshold) {
      return false;
    }

    // Check cooldown period
    if (_lastShakeTime != null) {
      final timeSinceLastShake = DateTime.now().difference(_lastShakeTime!);
      if (timeSinceLastShake < shakeCooldown) {
        return false;
      }
    }

    return true;
  }

  /// Update shake threshold (for settings)
  void updateThreshold(double newThreshold) {
    if (newThreshold <= 0) {
      debugPrint('Invalid shake threshold: $newThreshold');
      return;
    }

    shakeThreshold = newThreshold;
    debugPrint('Shake threshold updated to: $shakeThreshold m/s²');
  }

  /// Dispose of resources
  void dispose() {
    stop();
  }

  /// Pause shake detection (keeps subscription alive but ignores events)
  void pause() {
    if (_isActive) {
      // Set last shake time to far future to ignore events
      _lastShakeTime = DateTime.now().add(const Duration(days: 365));
    }
  }

  /// Resume shake detection after pause
  void resume() {
    _lastShakeTime = null;
  }
}

/// Helper class to manage shake detection with lifecycle awareness
class ShakeDetectorManager {
  final ShakeDetector _detector;
  bool _isAppInForeground = true;

  ShakeDetectorManager({
    double shakeThreshold = 20.0,
    Duration shakeCooldown = const Duration(milliseconds: 1000),
    ShakeCallback? onShake,
  }) : _detector = ShakeDetector(
          shakeThreshold: shakeThreshold,
          shakeCooldown: shakeCooldown,
          onShake: onShake,
        );

  /// Whether shake detection is supported
  bool get isSupported => _detector.isSupported;

  /// Start shake detection
  void start() {
    if (_isAppInForeground) {
      _detector.start();
    }
  }

  /// Stop shake detection
  void stop() {
    _detector.stop();
  }

  /// Call when app enters foreground
  void onAppResumed() {
    _isAppInForeground = true;
    _detector.start();
  }

  /// Call when app enters background
  void onAppPaused() {
    _isAppInForeground = false;
    _detector.stop();
  }

  /// Update shake threshold
  void updateThreshold(double threshold) {
    _detector.updateThreshold(threshold);
  }

  /// Dispose of resources
  void dispose() {
    _detector.dispose();
  }
}
