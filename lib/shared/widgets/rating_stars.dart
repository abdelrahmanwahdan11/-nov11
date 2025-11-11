import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index + 1 <= value;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        );
      }),
    );
  }
}
