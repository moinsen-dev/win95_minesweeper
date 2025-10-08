class Cell {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  bool isQuestionMarked;
  int neighborMines;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.isQuestionMarked = false,
    this.neighborMines = 0,
  });

  Cell copyWith({
    bool? isMine,
    bool? isRevealed,
    bool? isFlagged,
    bool? isQuestionMarked,
    int? neighborMines,
  }) {
    return Cell(
      row: row,
      col: col,
      isMine: isMine ?? this.isMine,
      isRevealed: isRevealed ?? this.isRevealed,
      isFlagged: isFlagged ?? this.isFlagged,
      isQuestionMarked: isQuestionMarked ?? this.isQuestionMarked,
      neighborMines: neighborMines ?? this.neighborMines,
    );
  }
}
