import 'package:flutter/material.dart';

/// The VW logo's chevron stroke, reusable at any size via [CustomPaint] —
/// the Fase 9 redesign's one deliberately bold, repeated signature element
/// (see docs/superpowers/specs/2026-09-01-portfolio-redesign-design.md).
/// Pure decoration, no logic worth a dedicated test beyond the pages that
/// already render it.
class BrandChevronMark extends StatelessWidget {
  const BrandChevronMark({this.strokeWidth = 3, super.key});

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _ChevronPainter(
        startColor: colorScheme.primary,
        endColor: colorScheme.tertiary,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({
    required this.startColor,
    required this.endColor,
    required this.strokeWidth,
  });

  final Color startColor;
  final Color endColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [startColor, endColor],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.startColor != startColor ||
      oldDelegate.endColor != endColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
