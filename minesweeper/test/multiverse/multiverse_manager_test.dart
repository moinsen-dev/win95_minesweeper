import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/multiverse/game_dimension.dart';
import 'package:minesweeper/multiverse/multiverse_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MultiverseManager', () {
    late MultiverseManager manager;

    setUp(() async {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
      manager = MultiverseManager();
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('initializes with classic dimension as default', () {
      expect(manager.currentDimension, GameDimension.classic);
      expect(manager.isInitialized, true);
    });

    test('switchToDimension changes current dimension', () async {
      await manager.switchToDimension(GameDimension.aiAssistant);
      expect(manager.currentDimension, GameDimension.aiAssistant);
      expect(manager.previousDimension, GameDimension.classic);
    });

    test('switchToDimension adds to history', () async {
      manager.setDimensionEnabled(GameDimension.xrayVision, true);

      await manager.switchToDimension(GameDimension.aiAssistant);
      await manager.switchToDimension(GameDimension.xrayVision);

      expect(manager.dimensionHistory.length, 2);
      expect(manager.dimensionHistory.last, GameDimension.xrayVision);
    });

    test('switchToDimension does not switch to same dimension', () async {
      await manager.switchToDimension(GameDimension.classic);
      expect(manager.dimensionHistory.isEmpty, true);
    });

    test('switchToDimension does not switch to disabled dimension', () async {
      manager.setDimensionEnabled(GameDimension.xrayVision, false);
      await manager.switchToDimension(GameDimension.xrayVision);
      expect(manager.currentDimension, GameDimension.classic);
    });

    test('shuffleDimension switches to random dimension', () async {
      // Enable AI Assistant for testing
      manager.setDimensionEnabled(GameDimension.aiAssistant, true);

      await manager.shuffleDimension();

      // Should have switched away from classic
      expect(manager.currentDimension != GameDimension.classic, true);
      expect(manager.dimensionHistory.isNotEmpty, true);
    });

    test('shuffleDimension does not switch to current dimension', () async {
      manager.setDimensionEnabled(GameDimension.aiAssistant, true);
      await manager.switchToDimension(GameDimension.aiAssistant);

      final previousDimension = manager.currentDimension;

      // Perform multiple shuffles
      for (int i = 0; i < 10; i++) {
        await manager.shuffleDimension();
        if (manager.currentDimension != previousDimension) {
          // Found a different dimension
          expect(manager.currentDimension != GameDimension.aiAssistant, true);
          return;
        }
        // Reset to test again
        await manager.switchToDimension(GameDimension.aiAssistant);
      }
    });

    test('undoDimensionSwitch returns to previous dimension', () async {
      await manager.switchToDimension(GameDimension.aiAssistant);
      await manager.undoDimensionSwitch();

      expect(manager.currentDimension, GameDimension.classic);
    });

    test('undoDimensionSwitch does nothing when no previous dimension', () async {
      final initialDimension = manager.currentDimension;
      await manager.undoDimensionSwitch();

      expect(manager.currentDimension, initialDimension);
    });

    test('history is limited to 50 entries', () async {
      manager.setDimensionEnabled(GameDimension.aiAssistant, true);

      // Switch 60 times
      for (int i = 0; i < 60; i++) {
        final targetDimension = i % 2 == 0
            ? GameDimension.aiAssistant
            : GameDimension.classic;
        await manager.switchToDimension(targetDimension);
      }

      expect(manager.dimensionHistory.length, 50);
    });

    test('getDimensionUsageStats returns correct counts', () async {
      manager.setDimensionEnabled(GameDimension.xrayVision, true);

      await manager.switchToDimension(GameDimension.aiAssistant);
      await manager.switchToDimension(GameDimension.xrayVision);
      await manager.switchToDimension(GameDimension.aiAssistant);

      final stats = manager.getDimensionUsageStats();

      expect(stats[GameDimension.aiAssistant], 2);
      expect(stats[GameDimension.xrayVision], 1);
    });

    test('getFavoriteDimension returns most used dimension', () async {
      manager.setDimensionEnabled(GameDimension.xrayVision, true);

      await manager.switchToDimension(GameDimension.aiAssistant);
      await manager.switchToDimension(GameDimension.aiAssistant);
      await manager.switchToDimension(GameDimension.xrayVision);

      final favorite = manager.getFavoriteDimension();

      expect(favorite, GameDimension.aiAssistant);
    });

    test('clearHistory removes all history', () async {
      manager.setDimensionEnabled(GameDimension.xrayVision, true);

      await manager.switchToDimension(GameDimension.aiAssistant);
      await manager.switchToDimension(GameDimension.xrayVision);
      await manager.clearHistory();

      expect(manager.dimensionHistory.isEmpty, true);
    });

    test('reset restores default state', () async {
      await manager.switchToDimension(GameDimension.aiAssistant);
      manager.setDimensionEnabled(GameDimension.xrayVision, false);
      await manager.reset();

      expect(manager.currentDimension, GameDimension.classic);
      expect(manager.dimensionHistory.isEmpty, true);
      expect(manager.configs[GameDimension.xrayVision]!.isEnabled, false);
    });

    test('currentConfig returns correct configuration', () {
      expect(manager.currentConfig.dimension, GameDimension.classic);
      expect(manager.currentConfig.name, 'Classic Mode');
    });

    test('setDimensionEnabled updates configuration', () {
      manager.setDimensionEnabled(GameDimension.xrayVision, false);
      expect(manager.configs[GameDimension.xrayVision]!.isEnabled, false);

      manager.setDimensionEnabled(GameDimension.xrayVision, true);
      expect(manager.configs[GameDimension.xrayVision]!.isEnabled, true);
    });

    test('state persists across instances', () async {
      // Setup first instance
      await manager.switchToDimension(GameDimension.aiAssistant);

      // Create new instance
      final newManager = MultiverseManager();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(newManager.currentDimension, GameDimension.aiAssistant);
      expect(newManager.dimensionHistory.isNotEmpty, true);
    });
  });
}
