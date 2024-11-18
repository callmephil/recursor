import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recursor/widgets/box.dart';
import 'package:recursor/widgets/shuttle.dart';

typedef BoardSize = ({int rows, int columns, double squareSize});

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.shuttleRow,
    required this.shuttleColumn,
    required this.shuttleDirection,
    required this.stars,
    required this.walls,
    required this.size,
  });

  final int shuttleRow;
  final int shuttleColumn;
  final Direction shuttleDirection;
  final List<Point<int>> stars;
  final List<Point<int>> walls;

  final BoardSize size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < size.rows; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var j = 0; j < size.columns; j++)
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Box(
                      dimension: size.squareSize,
                      color: walls.contains(Point(i, j))
                          ? Colors.white
                          : Colors.blue,
                      child: i == shuttleRow && j == shuttleColumn
                          ? Shuttle(direction: shuttleDirection)
                          : stars.contains(Point(i, j))
                              ? const Icon(
                                  Icons.star_rounded,
                                  color: Colors.white,
                                )
                              : null,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
