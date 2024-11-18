import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:recursor/widgets/box.dart';
import 'package:recursor/widgets/game_board.dart';
import 'package:recursor/widgets/shuttle.dart';

// ignore: prefer-match-file-name
enum Action {
  forward,
  rotateLeft,
  rotateRight,
}

class Game extends StatefulWidget {
  const Game({
    super.key,
    required this.numStars,
    required this.numWalls,
    required this.size,
  });

  final int numStars;
  final int numWalls;

  final BoardSize size;

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  int shuttleRow = 0;
  int shuttleColumn = 0;
  Direction shuttleDirection = Direction.right;
  List<Point<int>> stars = [];
  List<Point<int>> walls = [];
  bool gameWon = false;
  bool gameLost = false;
  bool gameStarted = false;
  List<Action> actionSequence = [];
  Set<int> executedActions = {};

  @override
  void initState() {
    super.initState();
    _placeStars();
    _placeWalls();
  }

  @override
  void didUpdateWidget(Game oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _resetGame();
    }
  }

  void _placeStars() {
    final random = Random();
    while (stars.length < widget.numStars) {
      final star = Point(
        random.nextInt(widget.size.rows),
        random.nextInt(widget.size.columns),
      );
      if (!stars.contains(star) &&
          !walls.contains(star) &&
          !(star.x == shuttleRow && star.y == shuttleColumn)) {
        stars.add(star);
      }
    }
  }

  void _placeWalls() {
    final random = Random();
    while (walls.length < widget.numWalls) {
      final wall = Point(
        random.nextInt(widget.size.rows),
        random.nextInt(widget.size.columns),
      );
      if (!walls.contains(wall) &&
          !stars.contains(wall) &&
          !(wall.x == shuttleRow && wall.y == shuttleColumn)) {
        walls.add(wall);
      }
    }
  }

  void addAction(Action action) {
    HapticFeedback.selectionClick();

    setState(() {
      actionSequence.add(action);
    });
  }

  void playActions() {
    HapticFeedback.selectionClick();
    setState(() {
      gameStarted = true;
      executedActions.clear();
    });
    if (actionSequence.isNotEmpty) {
      _executeActions(0);
    }
  }

  void _executeActions(int index) {
    if (index >= actionSequence.length || gameWon || gameLost) return;
    final action = actionSequence.elementAtOrNull(index);
    if (action != null) {
      moveShuttle(action);
    }
    setState(() {
      executedActions.add(index);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _executeActions(index + 1);
    });
  }

  void moveShuttle(Action action) {
    setState(() {
      var newRow = shuttleRow;
      var newColumn = shuttleColumn;

      switch (action) {
        case Action.forward:
          switch (shuttleDirection) {
            case Direction.up:
              newRow--;
            case Direction.down:
              newRow++;
            case Direction.left:
              newColumn--;
            case Direction.right:
              newColumn++;
          }
        case Action.rotateLeft:
          shuttleDirection = Direction.values.elementAtOrNull(
                (shuttleDirection.index - 1 + Direction.values.length) %
                    Direction.values.length,
              ) ??
              shuttleDirection;
        case Action.rotateRight:
          shuttleDirection = Direction.values.elementAtOrNull(
                (shuttleDirection.index + 1) % Direction.values.length,
              ) ??
              shuttleDirection;
      }

      // Check for collisions with walls or boundaries
      if (newRow < 0 ||
          newRow >= widget.size.rows ||
          newColumn < 0 ||
          newColumn >= widget.size.columns ||
          walls.contains(Point(newRow, newColumn))) {
        gameLost = true;
        _showEndDialog('You lost!', onReplay: () => setState(_resetGame));
      } else {
        shuttleRow = newRow;
        shuttleColumn = newColumn;

        // Check if the shuttle has collected any stars
        stars.removeWhere((star) {
          if (star.x == shuttleRow && star.y == shuttleColumn) {
            HapticFeedback.lightImpact();
            return true;
          }
          return false;
        });

        // Check if the game is won
        if (stars.isEmpty) {
          gameWon = true;
          Confetti.launch(
            context,
            options: const ConfettiOptions(
              particleCount: 100,
              spread: 70,
              y: 0.6,
            ),
          );
          _showEndDialog('You won!', onReplay: () => setState(_resetGame));
        }
      }
    });
  }

  void _showEndDialog(String message, {void Function()? onReplay}) {
    showDialog<Widget>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onReplay?.call();
              },
              child: const Text('Replay'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    shuttleRow = 0;
    shuttleColumn = 0;
    shuttleDirection = Direction.right;
    stars.clear();
    walls.clear();
    gameWon = false;
    gameLost = false;
    gameStarted = false;
    actionSequence.clear();
    executedActions.clear();
    _placeStars();
    _placeWalls();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: GameBoard(
            shuttleRow: shuttleRow,
            shuttleColumn: shuttleColumn,
            shuttleDirection: shuttleDirection,
            stars: stars,
            walls: walls,
            size: widget.size,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the action sequence
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: actionSequence.isEmpty
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // ignore: lines_longer_than_80_chars
                              '1. Add actions to create a sequence of moves for the shuttle.',
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              '2. Press Start to execute the sequence, good luck!',
                            ),
                          ],
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: actionSequence.asMap().entries.map((entry) {
                            final index = entry.key;
                            final action = entry.value;
                            return Box(
                              dimension: 24,
                              color: executedActions.contains(index)
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              child: Icon(
                                switch (action) {
                                  Action.forward => Icons.arrow_upward,
                                  Action.rotateLeft => Icons.rotate_left,
                                  Action.rotateRight => Icons.rotate_right,
                                },
                                size: 16,
                              ),
                            );
                          }).toList(growable: false),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Add controls to add actions to the sequence
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: Action.values.map((action) {
                        return IconButton(
                          icon: Icon(
                            switch (action) {
                              Action.forward => Icons.arrow_upward,
                              Action.rotateLeft => Icons.rotate_left,
                              Action.rotateRight => Icons.rotate_right,
                            },
                          ),
                          onPressed: () => addAction(action),
                        );
                      }).toList(growable: false),
                    ),
                    ElevatedButton(
                      onPressed: actionSequence.isEmpty
                          ? null
                          : gameStarted
                              ? _resetGame
                              : playActions,
                      child: Text(gameStarted ? 'Restart' : 'Start'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
