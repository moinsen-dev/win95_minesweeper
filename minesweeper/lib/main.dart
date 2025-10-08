import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/multiverse_game_screen.dart';
import 'multiverse/multiverse_manager.dart';

void main() {
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MultiverseManager(),
      child: MaterialApp(
        title: 'Minesweeper Multiverse - Windows 95 Style',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF000080),
          scaffoldBackgroundColor: const Color(0xFFC0C0C0),
          fontFamily: 'MS Sans Serif',
        ),
        home: const MultiverseGameScreen(),
      ),
    );
  }
}
