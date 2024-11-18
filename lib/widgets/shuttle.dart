import 'package:flutter/material.dart';

class Shuttle extends StatelessWidget {
  const Shuttle({super.key, required this.direction});

  final Direction direction;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: direction.index,
      child: const Icon(
        Icons.airplanemode_active_outlined,
        color: Colors.white,
      ),
    );
  }
}

enum Direction {
  up,
  right,
  down,
  left,
}
