enum Difficulty {
  beginner(rows: 8, cols: 8, mines: 10),
  intermediate(rows: 16, cols: 16, mines: 40),
  expert(rows: 16, cols: 30, mines: 99);

  final int rows;
  final int cols;
  final int mines;

  const Difficulty({
    required this.rows,
    required this.cols,
    required this.mines,
  });

  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.expert:
        return 'Expert';
    }
  }
}
