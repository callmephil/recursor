enum GameSettings {
  x6x6(6, 6, 6, 3),
  x7x7(7, 7, 7, 6),
  x8x8(8, 8, 8, 7),
  x9x9(9, 9, 12, 16),
  x12x9(12, 9, 12, 20),
  ;

  const GameSettings(this.rows, this.columns, this.walls, this.stars);

  final int rows;
  final int columns;
  final int walls;
  final int stars;
}
