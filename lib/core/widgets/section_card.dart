import 'package:flutter/material.dart';

/// A bordered, softly-elevated container used for every section-level
/// block across the site (skills categories, experience entries, project
/// cards, contact panels) — the Fase 9 redesign's consistent visual system
/// replacing Fase 5's bare text blocks. `clipBehavior: Clip.antiAlias` lets
/// callers place flush-edge content (e.g. an accent bar or gradient strip)
/// as the first child and still get clean rounded corners.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: colorScheme.tertiary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
