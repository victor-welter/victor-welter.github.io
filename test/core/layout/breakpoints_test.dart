import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/layout/breakpoints.dart';

void main() {
  Future<void> pumpAtWidth(WidgetTester tester, double width) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Builder(
          builder: (context) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                'mobile:${context.isMobile} '
                'tablet:${context.isTablet} '
                'desktop:${context.isDesktop}',
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('classifies a narrow width as mobile', (tester) async {
    await pumpAtWidth(tester, 400);
    expect(find.text('mobile:true tablet:false desktop:false'), findsOneWidget);
  });

  testWidgets('classifies a mid width as tablet', (tester) async {
    await pumpAtWidth(tester, 800);
    expect(find.text('mobile:false tablet:true desktop:false'), findsOneWidget);
  });

  testWidgets('classifies a wide width as desktop', (tester) async {
    await pumpAtWidth(tester, 1300);
    expect(find.text('mobile:false tablet:false desktop:true'), findsOneWidget);
  });
}
