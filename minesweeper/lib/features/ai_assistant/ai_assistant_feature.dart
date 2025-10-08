import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../game_feature.dart';
import '../game_context.dart';
import '../../ai/advanced_board_analyzer.dart';
import '../../ai/cell_probabilities.dart';
import 'assistant_personality.dart';
import 'hint_engine.dart';

/// AI Assistant feature that provides hints and guidance
class AIAssistantFeature extends BaseGameFeature {
  @override
  final String id = 'ai-assistant';

  @override
  final String name = 'AI Assistant';

  @override
  final String description = 'Clippy-inspired helper with contextual hints';

  /// The board analyzer - using advanced CSP-based analyzer
  final AdvancedBoardAnalyzer _analyzer = AdvancedBoardAnalyzer();

  /// The hint engine
  late HintEngine _hintEngine;

  /// Current assistant personality
  AssistantPersonality _personality = AssistantPersonality.encouraging;

  /// Last analysis result
  BoardAnalysisResult? _lastAnalysis;

  /// Whether hints are currently enabled
  bool _hintsEnabled = true;

  /// Get current personality
  AssistantPersonality get personality => _personality;

  /// Set personality
  set personality(AssistantPersonality value) {
    _personality = value;
  }

  /// Whether hints are enabled
  bool get hintsEnabled => _hintsEnabled;

  /// Toggle hints
  void toggleHints() {
    _hintsEnabled = !_hintsEnabled;
  }

  @override
  Future<void> onInitialize() async {
    _hintEngine = HintEngine(
      analyzer: _analyzer,
      personality: _personality,
    );
  }

  @override
  Future<void> onActivate() async {
    // Listen to game events
    context.addGameStateListener(_onGameStateChanged);
    context.addMoveListener(_onMove);

    // Perform initial analysis
    await _analyzeBoard();
  }

  @override
  Future<void> onDeactivate() async {
    // Remove listeners
    context.removeGameStateListener(_onGameStateChanged);
    context.removeMoveListener(_onMove);

    // Clear analysis
    _lastAnalysis = null;
  }

  /// Analyze the current board
  Future<void> _analyzeBoard() async {
    if (!_hintsEnabled) return;

    try {
      _lastAnalysis = await _analyzer.analyze(
        context.board,
        context.gameState,
        context.mineCount,
        context.flagCount,
      );
    } catch (e, stackTrace) {
      // Log errors for debugging
      debugPrint('❌ Board analysis error: $e');
      debugPrint('Stack trace: $stackTrace');
      _lastAnalysis = null;
    }
  }

  /// Get a hint for the current board state
  Future<AssistantHint?> getHint() async {
    if (!_hintsEnabled) {
      debugPrint('AI Assistant: Hints are disabled');
      return null;
    }

    // Ensure we have analysis
    if (_lastAnalysis == null) {
      debugPrint('AI Assistant: No analysis available, analyzing board...');
      await _analyzeBoard();
    }

    if (_lastAnalysis == null) {
      debugPrint('AI Assistant: Analysis failed');
      return null;
    }

    debugPrint('AI Assistant: Generating hint with ${_lastAnalysis!.safeMoves.length} safe moves');

    final hint = _hintEngine.generateHint(
      analysis: _lastAnalysis!,
      gameState: context.gameState,
      personality: _personality,
    );

    if (hint != null) {
      debugPrint('AI Assistant: Generated hint: ${hint.message}');
    }

    return hint;
  }

  /// Get the best move suggestion
  Position? getBestMove() {
    return _lastAnalysis?.bestMove;
  }

  /// Get safe moves
  List<Position> getSafeMoves() {
    return _lastAnalysis?.safeMoves ?? [];
  }

  /// Get probability for a specific cell
  double? getCellProbability(int row, int col) {
    return _lastAnalysis?.probabilities[Position(row, col)]?.probability;
  }

  void _onGameStateChanged() {
    // Re-analyze when game state changes
    _analyzeBoard();
  }

  void _onMove(int row, int col) {
    // Re-analyze after each move
    _analyzeBoard();
  }

  @override
  void onGameReset() {
    _lastAnalysis = null;
  }
}
