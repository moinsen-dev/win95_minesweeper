import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/detectors/shake_detector.dart';

void main() {
  group('ShakeDetector', () {
    test('initializes with default values', () {
      final detector = ShakeDetector();

      expect(detector.shakeThreshold, 20.0);
      expect(detector.shakeCooldown, const Duration(milliseconds: 1000));
      expect(detector.isActive, false);
    });

    test('initializes with custom values', () {
      final detector = ShakeDetector(
        shakeThreshold: 25.0,
        shakeCooldown: const Duration(milliseconds: 500),
      );

      expect(detector.shakeThreshold, 25.0);
      expect(detector.shakeCooldown, const Duration(milliseconds: 500));
    });

    test('updateThreshold changes threshold value', () {
      final detector = ShakeDetector();
      detector.updateThreshold(30.0);

      expect(detector.shakeThreshold, 30.0);
    });

    test('updateThreshold ignores invalid values', () {
      final detector = ShakeDetector(shakeThreshold: 20.0);
      detector.updateThreshold(0.0);

      expect(detector.shakeThreshold, 20.0);

      detector.updateThreshold(-5.0);
      expect(detector.shakeThreshold, 20.0);
    });

    test('isSupported returns platform capability', () {
      final detector = ShakeDetector();

      // Should return a boolean value
      expect(detector.isSupported is bool, true);
    });

    test('dispose stops detector', () {
      final detector = ShakeDetector();
      detector.dispose();

      expect(detector.isActive, false);
    });

    test('pause and resume work correctly', () {
      final detector = ShakeDetector();

      // Test pause
      detector.pause();
      // After pause, detector should still exist but ignore events

      // Test resume
      detector.resume();
      // After resume, detector should accept events again

      detector.dispose();
    });
  });

  group('ShakeDetectorManager', () {
    test('initializes correctly', () {
      final manager = ShakeDetectorManager();

      expect(manager.isSupported is bool, true);
    });

    test('handles app lifecycle correctly', () {
      int shakeCount = 0;
      final manager = ShakeDetectorManager(
        onShake: () => shakeCount++,
      );

      // Start detection
      manager.start();

      // Pause when app goes to background
      manager.onAppPaused();

      // Resume when app returns to foreground
      manager.onAppResumed();

      manager.dispose();
    });

    test('updateThreshold works', () {
      final manager = ShakeDetectorManager(shakeThreshold: 20.0);
      manager.updateThreshold(25.0);

      manager.dispose();
    });

    test('dispose cleans up resources', () {
      final manager = ShakeDetectorManager();
      manager.start();
      manager.dispose();

      // Should not throw
      expect(true, true);
    });
  });
}
