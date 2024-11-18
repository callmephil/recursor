import 'package:flutter/material.dart';
import 'package:recursor/game_settings.dart';
import 'package:recursor/widgets/game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ValueNotifier<GameSettings> _gameSize =
      ValueNotifier(GameSettings.x6x6);

  @override
  void dispose() {
    _gameSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Instructions',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Collect all the stars to win!',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Avoid the walls and boundaries!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.calendar_view_month_sharp),
                  onPressed: () {
                    showDialog<Widget>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Select Game Size'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: GameSettings.values.map((size) {
                            return ListTile(
                              title: Text('${size.rows}x${size.columns}'),
                              onTap: () {
                                _gameSize.value = size;
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(growable: false),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: _gameSize,
            builder: (_, value, child) {
              return Game(
                numStars: value.stars,
                numWalls: value.walls,
                size: (
                  rows: value.rows,
                  columns: value.columns,
                  squareSize: 36,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
