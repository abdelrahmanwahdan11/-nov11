import 'package:flutter/material.dart';

class ChipFilter extends StatelessWidget {
  const ChipFilter({super.key, required this.label, required this.selected, this.onSelected});

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
    );
  }
}
