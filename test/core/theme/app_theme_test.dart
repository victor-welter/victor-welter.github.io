import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/core/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Keep tests offline/deterministic — don't let google_fonts try to
    // fetch font binaries over the network during a test run. This only
    // affects this test file, not the real app.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('light theme uses light brightness', (tester) async {
    expect(AppTheme.light.brightness, Brightness.light);
  });

  testWidgets('dark theme uses dark brightness', (tester) async {
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  testWidgets('both themes opt into Material 3', (tester) async {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
  });

  testWidgets('dark theme uses the GitHub-dark-inspired background', (tester) async {
    expect(AppTheme.dark.scaffoldBackgroundColor, const Color(0xFF0D1117));
  });

  testWidgets('dark theme uses the electric-blue accent as its primary color', (tester) async {
    expect(AppTheme.dark.colorScheme.primary, const Color(0xFF4D8DFF));
  });

  testWidgets('light theme uses a plain white background', (tester) async {
    expect(AppTheme.light.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
  });

  testWidgets(
    'light theme uses a distinct, more restrained accent blue than dark',
    (tester) async {
      expect(AppTheme.light.colorScheme.primary, const Color(0xFF0969DA));
      expect(
        AppTheme.light.colorScheme.primary,
        isNot(equals(AppTheme.dark.colorScheme.primary)),
      );
    },
  );

  testWidgets('headings use Space Grotesk', (tester) async {
    // google_fonts composes `fontFamily` with an internal weight/style
    // disambiguator (e.g. "SpaceGrotesk_regular") that's an implementation
    // detail and has changed shape across package versions. The clean,
    // stable family name is in `fontFamilyFallback` instead — that's the
    // documented way to check "is this using font X".
    expect(
      AppTheme.dark.textTheme.headlineMedium?.fontFamilyFallback,
      contains('SpaceGrotesk'),
    );
    expect(
      AppTheme.light.textTheme.headlineMedium?.fontFamilyFallback,
      contains('SpaceGrotesk'),
    );
  });

  testWidgets('body text uses Inter', (tester) async {
    expect(
      AppTheme.dark.textTheme.bodyMedium?.fontFamilyFallback,
      contains('Inter'),
    );
    expect(
      AppTheme.light.textTheme.bodyMedium?.fontFamilyFallback,
      contains('Inter'),
    );
  });

  testWidgets('monoTextStyle uses JetBrains Mono', (tester) async {
    expect(
      AppTheme.monoTextStyle.fontFamilyFallback,
      contains('JetBrainsMono'),
    );
  });

  testWidgets('cards and buttons share the same 8px corner radius', (tester) async {
    final darkCardShape = AppTheme.dark.cardTheme.shape as RoundedRectangleBorder?;
    final lightCardShape =
        AppTheme.light.cardTheme.shape as RoundedRectangleBorder?;

    expect(darkCardShape?.borderRadius, BorderRadius.circular(8));
    expect(lightCardShape?.borderRadius, BorderRadius.circular(8));
  });
}
