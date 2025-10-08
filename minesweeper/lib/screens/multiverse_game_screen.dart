import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/minesweeper_game.dart';
import '../models/difficulty.dart';
import '../multiverse/multiverse_manager.dart';
import '../multiverse/game_dimension.dart';
import '../detectors/shake_detector.dart';
import '../features/feature_manager.dart';
import '../features/game_context.dart';
import '../features/ai_assistant/ai_assistant_feature.dart';
import '../widgets/game_header.dart';
import '../widgets/game_board.dart';
import '../widgets/win95_panel.dart';
import '../widgets/dimension_indicator.dart';
import '../widgets/shake_hint.dart';
import '../widgets/ai_assistant_panel.dart';
import '../widgets/animations/dimension_shift_animation.dart';

/// Main game screen with multiverse integration
class MultiverseGameScreen extends StatefulWidget {
  const MultiverseGameScreen({super.key});

  @override
  State<MultiverseGameScreen> createState() => _MultiverseGameScreenState();
}

class _MultiverseGameScreenState extends State<MultiverseGameScreen> with TickerProviderStateMixin {
  late MinesweeperGame _game;
  late GameContext _gameContext;
  late FeatureManager _featureManager;
  late ShakeDetectorManager _shakeDetector;

  bool _showShakeHint = false;
  bool _isAnimating = false;
  GameDimension _animatingToDimension = GameDimension.classic;

  @override
  void initState() {
    super.initState();
    _game = MinesweeperGame();
    _gameContext = GameContext(game: _game);
    _featureManager = FeatureManager(context: _gameContext);

    // Register features for dimensions
    _registerFeatures();

    // Initialize shake detector
    _shakeDetector = ShakeDetectorManager(
      onShake: _onShakeDetected,
    );

    // Check if we should show tutorial
    _checkShowTutorial();

    // Start shake detector if supported
    if (_shakeDetector.isSupported) {
      _shakeDetector.start();
    }

    // Activate initial dimension features (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activateInitialDimension();
    });
  }

  Future<void> _activateInitialDimension() async {
    final multiverseManager = context.read<MultiverseManager>();

    // Wait for MultiverseManager to finish initializing (loading from SharedPreferences)
    while (!multiverseManager.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final currentDimension = multiverseManager.currentDimension;

    debugPrint('Activating initial dimension: $currentDimension');

    await _featureManager.activateDimension(
      currentDimension,
      preserveState: false,
    );
  }

  void _registerFeatures() {
    // Register AI Assistant for Dimension 1
    final aiAssistant = AIAssistantFeature();
    _featureManager.registerDimensionFeatures(
      GameDimension.aiAssistant,
      [aiAssistant],
    );
  }

  Future<void> _checkShowTutorial() async {
    // For MVP, show tutorial on first launch
    // In production, this would check SharedPreferences
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _showShakeHint = true;
      });
    }
  }

  void _onShakeDetected() {
    final multiverseManager = context.read<MultiverseManager>();
    _switchToRandomDimension(multiverseManager);
  }

  Future<void> _switchToRandomDimension(MultiverseManager manager) async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Get current dimension before shuffle
    final oldDimension = manager.currentDimension;

    // Play animation
    await Future.delayed(const Duration(milliseconds: 900));

    // Shuffle to new dimension
    await manager.shuffleDimension();

    // Get the new dimension after shuffle
    final newDimension = manager.currentDimension;
    final newConfig = manager.configs[newDimension]!;

    debugPrint('Switched from $oldDimension to $newDimension');

    // Update features
    await _featureManager.switchDimension(
      oldDimension,
      newDimension,
      preserveState: newConfig.preservesGameStateOnSwitch,
    );

    setState(() {
      _isAnimating = false;
      _animatingToDimension = newDimension;
    });
  }

  Future<void> _switchToDimension(MultiverseManager manager, GameDimension dimension) async {
    if (_isAnimating || manager.currentDimension == dimension) return;

    setState(() {
      _isAnimating = true;
      _animatingToDimension = dimension;
    });

    // Play animation
    await Future.delayed(const Duration(milliseconds: 900));

    // Switch dimension
    final oldDimension = manager.currentDimension;
    await manager.switchToDimension(dimension);

    // Update features
    final newConfig = manager.configs[dimension]!;

    await _featureManager.switchDimension(
      oldDimension,
      dimension,
      preserveState: newConfig.preservesGameStateOnSwitch,
    );

    setState(() {
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _shakeDetector.dispose();
    _featureManager.dispose();
    _gameContext.dispose();
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiverseManager>(
      builder: (context, multiverseManager, child) {
        final currentConfig = multiverseManager.currentConfig;

        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            // Ctrl+Shift+D to shuffle dimensions
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.keyD &&
                HardwareKeyboard.instance.isControlPressed &&
                HardwareKeyboard.instance.isShiftPressed) {
              _switchToRandomDimension(multiverseManager);
            }
          },
          child: DimensionShiftAnimation(
            isAnimating: _isAnimating,
            newDimension: _animatingToDimension,
            newConfig: multiverseManager.configs[_animatingToDimension]!,
            onAnimationComplete: () {
              setState(() {
                _isAnimating = false;
              });
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFC0C0C0),
              appBar: AppBar(
                backgroundColor: const Color(0xFF000080),
                title: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Minesweeper',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Dimension indicator
                    DimensionIndicator(
                      config: currentConfig,
                      onTap: () => _showDimensionMenu(multiverseManager),
                    ),
                  ],
                ),
                actions: [
                  // Difficulty menu
                  PopupMenuButton<Difficulty>(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    color: const Color(0xFFC0C0C0),
                    onSelected: (difficulty) {
                      setState(() {
                        _game.setDifficulty(difficulty);
                      });
                    },
                    itemBuilder: (context) => [
                      _buildMenuItem(Difficulty.beginner, _game.difficulty),
                      _buildMenuItem(Difficulty.intermediate, _game.difficulty),
                      _buildMenuItem(Difficulty.expert, _game.difficulty),
                    ],
                  ),
                ],
              ),
              body: _buildBody(multiverseManager),
              floatingActionButton: _shakeDetector.isSupported
                  ? null
                  : FloatingActionButton(
                      onPressed: () => _switchToRandomDimension(multiverseManager),
                      tooltip: 'Switch Dimension (Ctrl+Shift+D)',
                      child: const Icon(Icons.shuffle),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(MultiverseManager manager) {
    return Stack(
      children: [
        // Main game area
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                // Game board panel
                Win95Panel(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListenableBuilder(
                        listenable: _game,
                        builder: (context, _) => GameHeader(game: _game),
                      ),
                      const SizedBox(height: 4),
                      ListenableBuilder(
                        listenable: _game,
                        builder: (context, _) => GameBoard(game: _game),
                      ),
                    ],
                  ),
                ),

                // AI Assistant panel (only in AI Assistant dimension)
                if (manager.currentDimension == GameDimension.aiAssistant)
                  _buildAIAssistantPanel(),
              ],
            ),
          ),
        ),

        // Shake hint tutorial overlay
        if (_showShakeHint)
          ShakeHint(
            onDismiss: () {
              setState(() {
                _showShakeHint = false;
              });
            },
            showKeyboardHint: !_shakeDetector.isSupported,
          ),
      ],
    );
  }

  Widget _buildAIAssistantPanel() {
    final features = _featureManager.getFeaturesForDimension(GameDimension.aiAssistant);
    if (features.isEmpty) return const SizedBox.shrink();

    final aiAssistant = features.first as AIAssistantFeature;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: AIAssistantPanel(assistant: aiAssistant),
    );
  }

  void _showDimensionMenu(MultiverseManager manager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Dimension'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: GameDimension.values.map((dimension) {
              final config = manager.configs[dimension]!;
              final isCurrent = manager.currentDimension == dimension;

              return ListTile(
                enabled: config.isEnabled,
                leading: Icon(
                  config.icon,
                  color: config.isEnabled ? config.accentColor : Colors.grey,
                ),
                title: Text(
                  config.name,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: config.isEnabled ? Colors.black : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  config.tagline,
                  style: TextStyle(
                    fontSize: 11,
                    color: config.isEnabled ? Colors.black54 : Colors.grey,
                  ),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: config.isEnabled
                    ? () {
                        Navigator.pop(context);
                        _switchToDimension(manager, dimension);
                      }
                    : null,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<Difficulty> _buildMenuItem(
    Difficulty difficulty,
    Difficulty currentDifficulty,
  ) {
    return PopupMenuItem<Difficulty>(
      value: difficulty,
      child: Row(
        children: [
          Icon(
            difficulty == currentDifficulty
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 16,
            color: Colors.black,
          ),
          const SizedBox(width: 8),
          Text(
            difficulty.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
