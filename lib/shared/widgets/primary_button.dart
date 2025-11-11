import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = Icons.arrow_forward,
    this.backgroundColor,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final resolvedForeground = DesignTokens.colorContrastFor(resolvedBackground);
    final style = ElevatedButton.styleFrom(
      backgroundColor: resolvedBackground,
      foregroundColor: resolvedForeground,
      minimumSize: const Size.fromHeight(56),
      shape: const StadiumBorder(),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, color: resolvedForeground),
        label: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
