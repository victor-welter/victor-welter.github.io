import 'package:flutter/material.dart';

import 'brand_chevron_mark.dart';

/// The Home hero's circular photo: a gradient ring (accent → brand navy)
/// framing the image, with a small chevron badge — the Fase 9 redesign's
/// signature motif applied to the one place a photo appears. See
/// docs/superpowers/specs/2026-09-01-portfolio-redesign-design.md.
class HeroPhoto extends StatelessWidget {
  const HeroPhoto({this.size = 260, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: ClipOval(
              child: Image.asset(
                'assets/images/foto-victor-welter.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.02,
            right: size * 0.02,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline),
              ),
              child: const SizedBox(
                width: 14,
                height: 8,
                child: BrandChevronMark(strokeWidth: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
