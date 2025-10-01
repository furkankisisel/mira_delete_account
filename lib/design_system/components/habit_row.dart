import 'package:flutter/material.dart';
import 'pressable_scale.dart';

class DsHabitRow extends StatelessWidget {
  const DsHabitRow({
    super.key,
    required this.label,
    required this.done,
    required this.onChanged,
  });

  final String label;
  final bool done;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: PressableScale(
        onTap: onChanged,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: .55),
                  width: 1.2,
                ),
                color: done ? const Color(0xFF90B6C9) : null,
              ),
              child: done
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: t.bodyMedium?.copyWith(
                  fontWeight: done ? FontWeight.w600 : FontWeight.w500,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: scheme.onSurface.withValues(alpha: .4),
                ),
              ),
            ),
            if (done)
              Icon(
                Icons.check,
                size: 20,
                color: scheme.onSurface.withValues(alpha: .6),
              ),
          ],
        ),
      ),
    );
  }
}
