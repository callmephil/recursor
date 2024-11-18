import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  const Box({
    super.key,
    this.dimension = 36,
    required this.color,
    this.child,
  });

  final double dimension;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
        color: color,
      ),
      child: SizedBox.square(
        dimension: dimension,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Center(child: child),
        ),
      ),
    );
  }
}
