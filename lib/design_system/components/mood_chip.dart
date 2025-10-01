import 'package:flutter/material.dart';
import 'pressable_scale.dart';

/// Design system mood chip. Generic: caller supplies label/icon/baseColor.
class DsMoodChip extends StatelessWidget {
  const DsMoodChip({
    super.key,
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.selected,
    required this.onTap,
    this.width = 62,
  });

  final String label;
  final IconData icon;
  final Color baseColor;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? baseColor.withValues(alpha: .65)
              : baseColor.withValues(alpha: .25),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? scheme.onPrimary
                  : scheme.onSurface.withValues(alpha: .75),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? scheme.onPrimary
                          : scheme.onPrimary)
                    : scheme.onSurface.withValues(alpha: .8),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
