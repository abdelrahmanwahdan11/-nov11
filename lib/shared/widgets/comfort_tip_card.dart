import 'package:flutter/material.dart';

class ComfortTipCard extends StatelessWidget {
  const ComfortTipCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTogglePin,
    required this.pinned,
    required this.accent,
  });

  final String title;
  final String description;
  final VoidCallback onTogglePin;
  final bool pinned;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withOpacity(0.1), surface),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: pinned ? accent : accent.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onTogglePin,
                icon: Icon(
                  pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: pinned ? accent : theme.iconTheme.color,
                ),
                tooltip: pinned
                    ? MaterialLocalizations.of(context).unpinButtonLabel
                    : MaterialLocalizations.of(context).pinButtonLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
