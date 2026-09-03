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
            // Explicitly square. Without these, the Container sizes itself
            // to its Image child, and an Image under loose constraints lays
            // out at the asset's own aspect ratio (the photo is 960x1280
            // portrait) — BoxFit.cover only controls painting *inside* the
            // box, not the box's own size. That gave a ~186x248 box inside
            // the 260x260 Stack, so ClipOval clipped to an ellipse that
            // bulged past the circular gradient ring, and the badge below
            // drifted into the 62px of unused space in the Stack's corner.
            // Forced square, cover crops the portrait photo to fill it,
            // which is what "cover" is for.
            width: size,
            height: size,
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
          // Sits on the ring's lower-right edge: the circle's 45-degree point
          // is size * 0.1464 in from both the bottom and the right, and this
          // offset puts the badge's centre roughly there.
          Positioned(
            bottom: size * 0.10,
            right: size * 0.10,
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
