import 'package:flutter/material.dart';

class CalloutTag extends StatefulWidget {
  const CalloutTag({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<CalloutTag> createState() => _CalloutTagState();
}

class _CalloutTagState extends State<CalloutTag> {
  bool _highlighted = false;

  void _setHighlight(bool value) {
    if (_highlighted == value) return;
    setState(() => _highlighted = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.primary;
    final background = _highlighted
        ? theme.colorScheme.primary.withOpacity(0.22)
        : theme.colorScheme.surface.withOpacity(0.9);
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => _setHighlight(true),
      onLongPressEnd: (_) => _setHighlight(false),
      onLongPressCancel: () => _setHighlight(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.6),
          boxShadow: _highlighted
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: borderColor),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: borderColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
