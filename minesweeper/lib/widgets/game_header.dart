import 'dart:async';
import 'package:flutter/material.dart';
import '../game/minesweeper_game.dart';
import '../models/game_state.dart';
import 'seven_segment_display.dart';
import 'win95_button.dart';

class GameHeader extends StatefulWidget {
  final MinesweeperGame game;

  const GameHeader({
    super.key,
    required this.game,
  });

  @override
  State<GameHeader> createState() => _GameHeaderState();
}

class _GameHeaderState extends State<GameHeader> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    widget.game.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.game.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (widget.game.gameState != GameState.playing) {
      _timer?.cancel();
    } else if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      widget.game.incrementTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFC0C0C0),
        border: Border.all(color: const Color(0xFF808080), width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SevenSegmentDisplay(value: widget.game.minesRemaining),
          Win95Button(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            onPressed: widget.game.resetGame,
            child: _buildFaceIcon(),
          ),
          SevenSegmentDisplay(value: widget.game.elapsedSeconds),
        ],
      ),
    );
  }

  Widget _buildFaceIcon() {
    IconData icon;
    Color color;

    switch (widget.game.gameState) {
      case GameState.won:
        icon = Icons.sentiment_very_satisfied;
        color = const Color(0xFFFFD700); // Gold
        break;
      case GameState.lost:
        icon = Icons.sentiment_very_dissatisfied;
        color = const Color(0xFFFF0000); // Red
        break;
      case GameState.playing:
      case GameState.ready:
        icon = Icons.sentiment_satisfied;
        color = const Color(0xFFFFFF00); // Yellow
        break;
    }

    return Icon(icon, color: color, size: 28);
  }
}
