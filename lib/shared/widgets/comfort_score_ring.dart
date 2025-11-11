import 'package:flutter/material.dart';

class ComfortScoreRing extends StatelessWidget {
  const ComfortScoreRing({
    super.key,
    required this.score,
    required this.color,
    this.size = 180,
    this.subtitle,
  });

  final int score;
  final Color color;
  final double size;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = score.clamp(0, 100);
    return SizedBox(
      height: size,
      width: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: clamped / 100),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: size,
                width: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: size * 0.08,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$clamped',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
