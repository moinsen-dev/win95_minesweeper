import 'package:flutter/material.dart';
import '../game/minesweeper_game.dart';
import '../models/difficulty.dart';
import '../widgets/game_header.dart';
import '../widgets/game_board.dart';
import '../widgets/win95_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MinesweeperGame _game;

  @override
  void initState() {
    super.initState();
    _game = MinesweeperGame();
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC0C0C0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000080),
        title: const Row(
          children: [
            Icon(Icons.flag, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Minesweeper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
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
      body: Center(
        child: SingleChildScrollView(
          child: Win95Panel(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListenableBuilder(
                  listenable: _game,
                  builder: (context, _) => GameHeader(game: _game),
                ),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: _game,
                  builder: (context, _) => GameBoard(game: _game),
                ),
              ],
            ),
          ),
        ),
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
