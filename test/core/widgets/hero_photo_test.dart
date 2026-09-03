import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/brand_chevron_mark.dart';
import 'package:portfolio/core/widgets/hero_photo.dart';

void main() {
  testWidgets('renders a circular photo with a gradient ring', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HeroPhoto())),
    );
    await tester.pump();

    expect(find.byType(HeroPhoto), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('respects a custom size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HeroPhoto(size: 120))),
    );
    await tester.pump();

    final sizedBox = tester.widget<SizedBox>(
      find
          .ancestor(
            of: find.byType(ClipOval),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(sizedBox.width, 120);
    expect(sizedBox.height, 120);
  });

  // The assertion above only reads back HeroPhoto's own `size` argument, so
  // it holds no matter what the photo inside actually measures. These two
  // check the geometry that argument is supposed to produce.
  //
  // The photo asset is 960x1280 (portrait). Left to size itself, an Image
  // under loose constraints lays out at that aspect ratio — BoxFit.cover
  // governs painting inside the box, not the box's own size — so the clipped
  // photo came out an ellipse taller than the circular ring drawn around it,
  // and the badge, positioned against the Stack rather than the ring, drifted
  // into the leftover corner space. Both are pure layout, so neither needs
  // the image bytes to decode.
  for (final size in const [260.0, 200.0, 120.0]) {
    testWidgets('clips the photo to a true circle at size $size', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: HeroPhoto(size: size))),
      );
      await tester.pump();

      final clip = tester.getSize(find.byType(ClipOval));
      expect(clip.width, clip.height, reason: 'an ellipse, not a circle');
      // The ring is a 6px gradient border on every side.
      expect(clip.width, size - 12);
    });

    testWidgets('keeps the chevron badge on the ring at size $size', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: HeroPhoto(size: size))),
      );
      await tester.pump();

      final ringCentre = tester.getCenter(find.byType(ClipOval));
      final badgeCentre = tester.getCenter(find.byType(BrandChevronMark));
      final distance = (badgeCentre - ringCentre).distance;
      final radius = size / 2;

      // On the ring's edge: inside the circle, but out in its lower-right
      // quadrant rather than buried near the middle.
      expect(
        distance,
        lessThanOrEqualTo(radius),
        reason: 'badge floats outside the ring',
      );
      expect(distance, greaterThan(radius * 0.5));
      expect(badgeCentre.dx, greaterThan(ringCentre.dx));
      expect(badgeCentre.dy, greaterThan(ringCentre.dy));
      // Roughly on the 45-degree diagonal, so it reads as anchored to the
      // ring rather than parked against one side.
      final angle = math.atan2(
        badgeCentre.dy - ringCentre.dy,
        badgeCentre.dx - ringCentre.dx,
      );
      expect(angle, closeTo(math.pi / 4, 0.4));
    });
  }
}
