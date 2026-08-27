import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/core/theme/theme_scope.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exposes the provided controller to descendants', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController(preferences);
    late ThemeController captured;

    await tester.pumpWidget(
      ThemeScope(
        controller: controller,
        child: Builder(
          builder: (context) {
            captured = ThemeScope.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(captured, same(controller));
  });
}
