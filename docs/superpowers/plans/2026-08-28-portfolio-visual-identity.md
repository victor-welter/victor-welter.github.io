# Portfolio Fase 4 (Visual Identity) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the portfolio's placeholder theme with the approved dark-mode-first visual identity (colors, typography, shape) and fix the tablet-width navigation bug the Fase 3 final review found.

**Architecture:** `AppTheme` moves from one `ColorScheme.fromSeed()` shared by both brightnesses to two independently-specified `ColorScheme`s (`ColorScheme.dark(...)` / `ColorScheme.light(...)`), a shared `TextTheme` built from three `google_fonts` families, and a shared 8px corner-radius shape theme. `AppShell` gains a third, tablet-specific branch (600-1024px) that shows only "Home" inline plus a "Mais" `PopupMenuButton` for the other seven destinations, replacing the `Flexible`+`SingleChildScrollView` patch from Fase 3 at that width band (desktop keeps that patch as a defensive width guard, since 8 buttons can still be tight just above 1024px).

**Tech Stack:** Flutter (stable channel, web only — unchanged from Fase 3), + `google_fonts` (new this phase).

Full context and the approved design: `docs/superpowers/specs/2026-08-28-portfolio-visual-identity-design.md`.

## Global Constraints

- Dart identifiers, class names, and code comments are in English; every string the user sees is in Portuguese (pt-BR) — including the new "Mais" nav-overflow label.
- The only new dependency this phase is `google_fonts`. Do not add any other package.
- Use the exact hex color values from the design spec (reproduced in Task 1 below) — do not approximate or substitute similar-looking colors.
- Do not change `Breakpoints.mobileMax`/`Breakpoints.tabletMax` (599/1024, set in Fase 3) or any routing/CI/CD/page-content code — those are out of scope for this phase.
- Every git commit must be authored solely as the repository owner. Never add a `Co-Authored-By` line or any AI/tool-attribution trailer to a commit message.
- This phase ends with real code changes to a live, deployed site. Do not push to `main` without explicit user confirmation immediately before doing so — same production-action gate Fase 3 used for its deploys.

---

### Task 1: Rebuild AppTheme with the two-scheme color system, typography, and shape

**Files:**
- Modify: `pubspec.yaml` (add `google_fonts`)
- Modify: `lib/core/theme/app_theme.dart` (full rewrite)
- Modify: `test/core/theme/app_theme_test.dart` (keep the 3 existing tests, add new ones)

**Interfaces:**
- Consumes: nothing new.
- Produces: `AppTheme.light`/`AppTheme.dark` (unchanged signatures — `static ThemeData get`), plus a new `static TextStyle get monoTextStyle` on `AppTheme` for later tasks/phases that need the monospace font for technical UI (skill tags, etc. — not consumed by anything in this phase). No other task in this plan reads `monoTextStyle`.

- [ ] **Step 1: Add the google_fonts dependency**

Run:
```bash
flutter pub add google_fonts
```

- [ ] **Step 2: Write the expanded theme test**

Replace the full contents of `test/core/theme/app_theme_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/core/theme/app_theme.dart';

void main() {
  setUpAll(() {
    // Keep tests offline/deterministic — don't let google_fonts try to
    // fetch font binaries over the network during a test run. This only
    // affects this test file, not the real app.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('light theme uses light brightness', () {
    expect(AppTheme.light.brightness, Brightness.light);
  });

  test('dark theme uses dark brightness', () {
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('both themes opt into Material 3', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
  });

  test('dark theme uses the GitHub-dark-inspired background', () {
    expect(AppTheme.dark.scaffoldBackgroundColor, const Color(0xFF0D1117));
  });

  test('dark theme uses the electric-blue accent as its primary color', () {
    expect(AppTheme.dark.colorScheme.primary, const Color(0xFF4D8DFF));
  });

  test('light theme uses a plain white background', () {
    expect(AppTheme.light.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
  });

  test(
    'light theme uses a distinct, more restrained accent blue than dark',
    () {
      expect(AppTheme.light.colorScheme.primary, const Color(0xFF0969DA));
      expect(
        AppTheme.light.colorScheme.primary,
        isNot(equals(AppTheme.dark.colorScheme.primary)),
      );
    },
  );

  test('headings use Space Grotesk', () {
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

  test('body text uses Inter', () {
    expect(
      AppTheme.dark.textTheme.bodyMedium?.fontFamilyFallback,
      contains('Inter'),
    );
    expect(
      AppTheme.light.textTheme.bodyMedium?.fontFamilyFallback,
      contains('Inter'),
    );
  });

  test('monoTextStyle uses JetBrains Mono', () {
    expect(
      AppTheme.monoTextStyle.fontFamilyFallback,
      contains('JetBrainsMono'),
    );
  });

  test('cards and buttons share the same 8px corner radius', () {
    final darkCardShape = AppTheme.dark.cardTheme.shape as RoundedRectangleBorder?;
    final lightCardShape =
        AppTheme.light.cardTheme.shape as RoundedRectangleBorder?;

    expect(darkCardShape?.borderRadius, BorderRadius.circular(8));
    expect(lightCardShape?.borderRadius, BorderRadius.circular(8));
  });
}
```

- [ ] **Step 3: Run it to confirm the new assertions fail**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: the 3 original tests PASS (behavior they check hasn't changed conceptually), the new tests added in Step 2 FAIL — the old implementation's `ColorScheme.fromSeed(seedColor: 0xFF2563EB)` doesn't produce `primary == 0xFF4D8DFF`, `scaffoldBackgroundColor` isn't set at all yet, the `TextTheme` has no custom fonts, `monoTextStyle` doesn't exist (compile error), and there's no `cardTheme` override.

- [ ] **Step 4: Rewrite AppTheme**

Replace the full contents of `lib/core/theme/app_theme.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The portfolio's visual identity: two independently-specified color
/// schemes (dark is the primary identity, light is a deliberately
/// restrained/neutral secondary), a Space Grotesk/Inter/JetBrains Mono
/// typography system, and a shared rounded shape language.
///
/// See docs/superpowers/specs/2026-08-28-portfolio-visual-identity-design.md
class AppTheme {
  AppTheme._();

  // Dark theme colors — the primary identity (GitHub/VS Code dark inspired).
  static const Color _darkBackground = Color(0xFF0D1117);
  static const Color _darkSurface = Color(0xFF161B22);
  static const Color _darkOutline = Color(0xFF30363D);
  static const Color _darkTextPrimary = Color(0xFFE6EDF3);
  static const Color _darkTextSecondary = Color(0xFF8B949E);
  static const Color _darkAccent = Color(0xFF4D8DFF);
  static const Color _darkOnAccent = Color(0xFF0D1117);
  static const Color _darkError = Color(0xFFF85149);

  // Light theme colors — neutral/grayscale chrome; the accent is reserved
  // for interactive elements only (links, primary buttons, active/hover
  // states), not general decoration.
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFFAFAFA);
  static const Color _lightOutline = Color(0xFFE5E5E5);
  static const Color _lightTextPrimary = Color(0xFF2B2B2B);
  static const Color _lightTextSecondary = Color(0xFF6B6B6B);
  static const Color _lightAccent = Color(0xFF0969DA);
  static const Color _lightOnAccent = Color(0xFFFFFFFF);
  static const Color _lightError = Color(0xFFCF222E);

  // Standard corner radius for buttons/cards/inputs. Chip/tag-style widgets
  // introduced in a later phase (skill tags, etc.) should use a full-pill
  // radius (StadiumBorder) instead, per the Fase 4 design spec — there's no
  // chip UI in the codebase yet, so nothing to apply that to here.
  static const double _cornerRadius = 8;

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: _darkAccent,
      onPrimary: _darkOnAccent,
      secondary: _darkAccent,
      onSecondary: _darkOnAccent,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      outline: _darkOutline,
      error: _darkError,
      onError: _darkOnAccent,
    );
    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: _darkBackground,
      textPrimary: _darkTextPrimary,
      textSecondary: _darkTextSecondary,
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: _lightAccent,
      onPrimary: _lightOnAccent,
      secondary: _lightAccent,
      onSecondary: _lightOnAccent,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      outline: _lightOutline,
      error: _lightError,
      onError: _lightOnAccent,
    );
    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: _lightBackground,
      textPrimary: _lightTextPrimary,
      textSecondary: _lightTextSecondary,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final headlineStyle = GoogleFonts.spaceGrotesk(color: textPrimary);
    final bodyStyle = GoogleFonts.inter(color: textPrimary);
    final labelStyle = GoogleFonts.inter(color: textSecondary);

    final textTheme = TextTheme(
      headlineLarge: headlineStyle,
      headlineMedium: headlineStyle,
      headlineSmall: headlineStyle,
      titleLarge: headlineStyle,
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      bodySmall: bodyStyle,
      labelLarge: labelStyle,
      labelMedium: labelStyle,
      labelSmall: labelStyle,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cornerRadius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      cardTheme: CardTheme(color: colorScheme.surface, shape: shape),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: shape),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: shape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
      ),
    );
  }

  /// Monospace text style for technical/code-like UI elements (e.g. skill
  /// tags in a later phase). Not part of [TextTheme] — call sites opt in
  /// explicitly via `Theme.of(context)` is not applicable here; use
  /// `AppTheme.monoTextStyle` directly.
  static TextStyle get monoTextStyle => GoogleFonts.jetBrainsMono();
}
```

- [ ] **Step 5: Run it to confirm all tests pass**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS — 11 tests (3 original + 8 new).

- [ ] **Step 6: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test in the project green (this touches only `app_theme.dart`/its test, so nothing else should be affected).

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/theme/app_theme.dart test/core/theme/app_theme_test.dart
git commit -m "$(cat <<'EOF'
Replace the placeholder theme with the Fase 4 visual identity

Two independently-specified ColorSchemes (dark is the primary
GitHub/VS-Code-dark-inspired identity with an electric-blue accent;
light is a deliberately neutral/grayscale secondary with a more
restrained accent reserved for interactive elements only), a Space
Grotesk/Inter/JetBrains Mono type system via google_fonts, and a
shared 8px rounded shape — replacing the single ColorScheme.fromSeed
placeholder from Fase 3.
EOF
)"
```

---

### Task 2: Fix tablet-width navigation with a "Home + Mais" overflow menu

**Files:**
- Modify: `lib/core/widgets/app_shell.dart`
- Modify: `test/core/widgets/app_shell_test.dart`

**Interfaces:**
- Consumes: `navDestinations` (existing top-level const from Task 6, unchanged), `context.isTablet` (existing `ResponsiveContext` extension from Fase 3's Task 2, unchanged).
- Produces: no new public API — `AppShell`'s constructor and public shape are unchanged, only its internal `build()` branching changes.

- [ ] **Step 1: Update the existing tablet-width test and add coverage across the band**

Replace the full contents of `test/core/widgets/app_shell_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/core/theme/theme_scope.dart';
import 'package:portfolio/core/widgets/app_shell.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: ThemeScope(
          controller: ThemeController(preferences),
          child: const AppShell(currentPath: '/', child: SizedBox.shrink()),
        ),
      ),
    );
  }

  testWidgets('shows a hamburger drawer on mobile widths', (tester) async {
    await pumpShell(tester, const Size(400, 800));

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Sobre'), findsNothing);
  });

  testWidgets('shows a horizontal nav bar on desktop widths', (tester) async {
    await pumpShell(tester, const Size(1300, 800));

    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.widgetWithText(TextButton, 'Sobre'), findsOneWidget);
  });

  group('tablet widths (600-1024px) show Home + a "Mais" overflow menu', () {
    for (final width in <double>[650, 800, 950]) {
      testWidgets('at ${width.toInt()}px', (tester) async {
        await pumpShell(tester, Size(width, 800));

        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.menu), findsNothing);
        expect(find.widgetWithText(TextButton, 'Home'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Sobre'), findsNothing);
        expect(find.text('Mais'), findsOneWidget);

        await tester.tap(find.text('Mais'));
        await tester.pumpAndSettle();

        expect(find.text('Sobre'), findsOneWidget);
      });
    }
  });

  testWidgets('shows a theme toggle button on both layouts', (tester) async {
    await pumpShell(tester, const Size(400, 800));
    expect(find.byTooltip('Alternar tema'), findsOneWidget);

    await pumpShell(tester, const Size(1300, 800));
    expect(find.byTooltip('Alternar tema'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/core/widgets/app_shell_test.dart`
Expected: FAIL — the tablet-band tests fail because the current code still shows all 8 buttons inline (including "Sobre") at 650/800/950px, with no "Mais" text anywhere.

- [ ] **Step 3: Implement the tablet branch**

In `lib/core/widgets/app_shell.dart`, replace the `AppShell.build` method (currently lines 32-80) with:

```dart
  @override
  Widget build(BuildContext context) {
    final themeToggle = _ThemeToggleButton(
      themeController: ThemeScope.of(context),
    );

    if (context.isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Victor Welter'),
          actions: [themeToggle],
        ),
        drawer: _AppDrawer(currentPath: currentPath),
        body: child,
      );
    }

    if (context.isTablet) {
      final home = navDestinations.first;
      final overflowDestinations = navDestinations.skip(1);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Victor Welter'),
          actions: [
            TextButton(
              onPressed: () => context.go(home.path),
              child: Text(
                home.label,
                style: TextStyle(
                  fontWeight: currentPath == home.path
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Mais opções de navegação',
              onSelected: (path) => context.go(path),
              itemBuilder: (context) => [
                for (final destination in overflowDestinations)
                  PopupMenuItem<String>(
                    value: destination.path,
                    child: Text(
                      destination.label,
                      style: TextStyle(
                        fontWeight: currentPath == destination.path
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Mais'),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            themeToggle,
          ],
        ),
        body: child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Victor Welter'),
        actions: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final destination in navDestinations)
                    TextButton(
                      onPressed: () => context.go(destination.path),
                      child: Text(
                        destination.label,
                        style: TextStyle(
                          fontWeight: currentPath == destination.path
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          themeToggle,
        ],
      ),
      body: child,
    );
  }
```

Nothing else in the file changes — `NavDestinationData`, `navDestinations`,
`_ThemeToggleButton`, and `_AppDrawer` stay exactly as they are.

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/core/widgets/app_shell_test.dart`
Expected: PASS — 6 tests (2 original + 3 tablet-band + 1 theme-toggle).

- [ ] **Step 5: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test in the project green.

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/app_shell.dart test/core/widgets/app_shell_test.dart
git commit -m "$(cat <<'EOF'
Fix tablet-width nav with a Home + Mais overflow menu

Replaces the Flexible+SingleChildScrollView patch at 600-1024px
(which stopped the crash but left "Currículo"/"Contato" unreachable
with no scroll affordance, and the title truncating) with a
dedicated tablet branch: only Home stays inline, the other seven
destinations move into a "Mais" PopupMenuButton. Guarantees the
inline content always fits. Desktop keeps the scrollable row as a
defensive width guard; mobile is unchanged. Test coverage now spans
the tablet band (650/800/950px) instead of one arbitrary width.
EOF
)"
```

---

### Task 3: Final verification

**Files:** none (verification only).

- [ ] **Step 1: Static checks**

Run:
```bash
flutter analyze
flutter test
flutter build web --release
```
Expected: no analyzer issues, full test suite green, build succeeds.

- [ ] **Step 2: Real-browser visual check**

Static checks and widget tests don't execute in a real browser engine — Fase 3
shipped a blank page, a broken theme-toggle, and an unguarded persistence call
that all passed `flutter analyze`/`flutter test` and were only caught by
actually driving the built app with a headless browser. Do the same here.

Install Playwright in a scratch directory **outside the repo** (e.g. your
system temp directory — do not add it to `pubspec.yaml` or commit any of
this):

```bash
mkdir -p /tmp/portfolio-verify && cd /tmp/portfolio-verify
npm init -y
npm install playwright
npx playwright install chromium
```

Serve the release build from the repo's `build/web` directory (path from the
repo root):

```bash
cd build/web && python -m http.server 8766 --bind 127.0.0.1 &
```

In `/tmp/portfolio-verify`, create `verify.js`:

```javascript
const { chromium } = require('playwright');
const BASE = 'http://127.0.0.1:8766';

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const errors = [];
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
  page.on('pageerror', (e) => errors.push('pageerror: ' + e.message));

  // 1. Light theme (default) at desktop width.
  await page.setViewportSize({ width: 1300, height: 900 });
  await page.goto(BASE, { waitUntil: 'load', timeout: 60000 });
  await page.waitForTimeout(3000);
  await page.screenshot({ path: 'light-desktop.png' });
  console.log('[light desktop] errors so far:', errors.length);

  // 2. Toggle to dark theme, same width.
  await page.mouse.click(1280, 28); // theme toggle is the last AppBar action
  await page.waitForTimeout(1000);
  await page.screenshot({ path: 'dark-desktop.png' });
  console.log('[after toggle] errors so far:', errors.length);

  // 3. Tablet width (800px) — Home + Mais overflow menu.
  await page.setViewportSize({ width: 800, height: 900 });
  await page.reload({ waitUntil: 'load' });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: 'tablet-800.png' });

  // Click roughly where "Mais" sits (adjust after looking at the
  // screenshot if the exact position differs).
  await page.mouse.click(150, 28);
  await page.waitForTimeout(500);
  await page.screenshot({ path: 'tablet-800-menu-open.png' });

  console.log('Total console/page errors:', errors.length);
  errors.forEach((e) => console.log('  ' + e));

  await browser.close();
})();
```

Run it and inspect the screenshots:

```bash
node verify.js
```

Confirm, by looking at the screenshots and the printed error count:
1. `Total console/page errors: 0`.
2. `light-desktop.png` — white background, dark gray text and nav labels, no
   blue except possibly the active "Home" label or the theme-toggle icon.
3. `dark-desktop.png` — `#0D1117`-ish near-black background, the active nav
   label and/or toggle icon in electric blue.
4. `tablet-800.png` — only "Home" and a "Mais" control are visible in the
   nav bar; the title is not truncated.
5. `tablet-800-menu-open.png` — the other seven destinations (Sobre,
   Experiência, Formação, Skills, Projetos, Currículo, Contato) are visible
   in an opened menu. If the click coordinates in the script missed the
   "Mais" control, adjust the `page.mouse.click(150, 28)` coordinates based
   on where it actually renders in `tablet-800.png` and rerun.

Fix anything this step finds before proceeding — do not treat "the automated
suite is green" as sufficient on its own for this phase, given the project's
history. When done, stop the local server (`kill %1` or find/kill the
`http.server` process) — nothing from this step gets committed.

- [ ] **Step 3: Report status**

Fase 4 (Design) is done when Steps 1 and 2 both pass clean. Content (Fase 5)
and Projects (Fase 6) build on top of this theme without needing to touch
`app_theme.dart` or `app_shell.dart` again.
