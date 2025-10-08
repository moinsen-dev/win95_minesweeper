import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/features/game_feature.dart';
import 'package:minesweeper/features/game_context.dart';
import 'package:minesweeper/features/feature_manager.dart';
import 'package:minesweeper/game/minesweeper_game.dart';
import 'package:minesweeper/models/difficulty.dart';
import 'package:minesweeper/multiverse/game_dimension.dart';

/// Mock feature for testing
class MockFeature extends BaseGameFeature {
  @override
  final String id;

  @override
  final String name;

  @override
  final String description;

  bool initializeCalled = false;
  bool activateCalled = false;
  bool deactivateCalled = false;
  bool disposeCalled = false;

  MockFeature({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  Future<void> onInitialize() async {
    initializeCalled = true;
  }

  @override
  Future<void> onActivate() async {
    activateCalled = true;
  }

  @override
  Future<void> onDeactivate() async {
    deactivateCalled = true;
  }

  @override
  void onDispose() {
    disposeCalled = true;
  }
}

void main() {
  group('GameFeature Lifecycle', () {
    late GameContext context;
    late MockFeature feature;

    setUp(() {
      final game = MinesweeperGame();
      context = GameContext(game: game);
      feature = MockFeature(
        id: 'test-feature',
        name: 'Test Feature',
        description: 'A test feature',
      );
    });

    test('feature starts uninitialized and inactive', () {
      expect(feature.isInitialized, false);
      expect(feature.isActive, false);
    });

    test('initialize sets up feature correctly', () async {
      await feature.initialize(context);

      expect(feature.isInitialized, true);
      expect(feature.initializeCalled, true);
      expect(feature.isActive, false);
    });

    test('initialize is idempotent', () async {
      await feature.initialize(context);
      await feature.initialize(context);

      expect(feature.isInitialized, true);
      expect(feature.initializeCalled, true);
    });

    test('activate requires initialization', () async {
      expect(
        () => feature.activate(),
        throwsA(isA<StateError>()),
      );
    });

    test('activate sets feature to active', () async {
      await feature.initialize(context);
      await feature.activate();

      expect(feature.isActive, true);
      expect(feature.activateCalled, true);
    });

    test('activate is idempotent', () async {
      await feature.initialize(context);
      await feature.activate();
      await feature.activate();

      expect(feature.isActive, true);
      expect(feature.activateCalled, true);
    });

    test('deactivate sets feature to inactive', () async {
      await feature.initialize(context);
      await feature.activate();
      await feature.deactivate();

      expect(feature.isActive, false);
      expect(feature.deactivateCalled, true);
    });

    test('deactivate is idempotent', () async {
      await feature.initialize(context);
      await feature.activate();
      await feature.deactivate();
      await feature.deactivate();

      expect(feature.isActive, false);
      expect(feature.deactivateCalled, true);
    });

    test('dispose cleans up feature', () async {
      await feature.initialize(context);
      await feature.activate();
      feature.dispose();

      expect(feature.disposeCalled, true);
      expect(feature.isInitialized, false);
      expect(feature.isActive, false);
    });

    test('full lifecycle works correctly', () async {
      // Initialize
      await feature.initialize(context);
      expect(feature.isInitialized, true);
      expect(feature.isActive, false);

      // Activate
      await feature.activate();
      expect(feature.isActive, true);

      // Deactivate
      await feature.deactivate();
      expect(feature.isActive, false);
      expect(feature.isInitialized, true);

      // Dispose
      feature.dispose();
      expect(feature.isInitialized, false);
    });
  });

  group('FeatureManager', () {
    late GameContext context;
    late FeatureManager manager;
    late MockFeature feature1;
    late MockFeature feature2;

    setUp(() {
      final game = MinesweeperGame();
      context = GameContext(game: game);
      manager = FeatureManager(context: context);

      feature1 = MockFeature(
        id: 'feature-1',
        name: 'Feature 1',
        description: 'First test feature',
      );

      feature2 = MockFeature(
        id: 'feature-2',
        name: 'Feature 2',
        description: 'Second test feature',
      );
    });

    tearDown(() {
      manager.dispose();
    });

    test('registers features for dimensions', () {
      manager.registerDimensionFeatures(
        GameDimension.aiAssistant,
        [feature1, feature2],
      );

      final features = manager.getFeaturesForDimension(GameDimension.aiAssistant);
      expect(features.length, 2);
      expect(features, contains(feature1));
      expect(features, contains(feature2));
    });

    test('activateDimension initializes and activates features', () async {
      manager.registerDimensionFeatures(
        GameDimension.aiAssistant,
        [feature1, feature2],
      );

      await manager.activateDimension(GameDimension.aiAssistant);

      expect(feature1.isInitialized, true);
      expect(feature1.isActive, true);
      expect(feature2.isInitialized, true);
      expect(feature2.isActive, true);
    });

    test('deactivateDimension deactivates features', () async {
      manager.registerDimensionFeatures(
        GameDimension.aiAssistant,
        [feature1, feature2],
      );

      await manager.activateDimension(GameDimension.aiAssistant);
      await manager.deactivateDimension(GameDimension.aiAssistant);

      expect(feature1.isActive, false);
      expect(feature2.isActive, false);
      // Features remain initialized
      expect(feature1.isInitialized, true);
      expect(feature2.isInitialized, true);
    });

    test('switchDimension handles transition correctly', () async {
      final feature3 = MockFeature(
        id: 'feature-3',
        name: 'Feature 3',
        description: 'Third test feature',
      );

      manager.registerDimensionFeatures(
        GameDimension.aiAssistant,
        [feature1],
      );
      manager.registerDimensionFeatures(
        GameDimension.xrayVision,
        [feature2, feature3],
      );

      // Activate first dimension
      await manager.activateDimension(GameDimension.aiAssistant);
      expect(feature1.isActive, true);

      // Switch to second dimension
      await manager.switchDimension(
        GameDimension.aiAssistant,
        GameDimension.xrayVision,
        preserveState: false,
      );

      expect(feature1.isActive, false);
      expect(feature2.isActive, true);
      expect(feature3.isActive, true);
    });

    test('activeFeatures returns currently active features', () async {
      manager.registerDimensionFeatures(
        GameDimension.aiAssistant,
        [feature1, feature2],
      );

      expect(manager.activeFeatures.length, 0);

      await manager.activateDimension(GameDimension.aiAssistant);

      expect(manager.activeFeatures.length, 2);
      expect(manager.activeFeatures, contains(feature1));
      expect(manager.activeFeatures, contains(feature2));
    });

    test('dispose cleans up all features', () async {
      manager.registerDimensionFeatures(
        GameDimension.aiAssistant,
        [feature1, feature2],
      );

      await manager.activateDimension(GameDimension.aiAssistant);
      manager.dispose();

      expect(feature1.disposeCalled, true);
      expect(feature2.disposeCalled, true);
      expect(manager.activeFeatures.length, 0);
      expect(manager.initializedFeatures.length, 0);
    });

    test('hasFeaturesForDimension returns correct value', () {
      expect(
        manager.hasFeaturesForDimension(GameDimension.classic),
        false,
      );

      manager.registerDimensionFeatures(
        GameDimension.classic,
        [feature1],
      );

      expect(
        manager.hasFeaturesForDimension(GameDimension.classic),
        true,
      );
    });

    test('totalFeatureCount returns correct count', () {
      expect(manager.totalFeatureCount, 0);

      manager.registerDimensionFeatures(
        GameDimension.aiAssistant,
        [feature1, feature2],
      );

      expect(manager.totalFeatureCount, 2);

      manager.registerDimensionFeatures(
        GameDimension.xrayVision,
        [feature1],
      );

      expect(manager.totalFeatureCount, 3);
    });
  });
}
