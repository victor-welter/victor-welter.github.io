import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
