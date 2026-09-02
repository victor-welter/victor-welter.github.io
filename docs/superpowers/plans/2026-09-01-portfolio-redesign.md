# Portfolio Fase 9 (Redesign Visual) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every page of the portfolio real visual composition (cards, a hero photo, a brand-navy accent from the new VW logo, a mailto-based contact form) instead of Fase 5's bare-text pages, while keeping the Fase 4 color/type tokens and the tested adaptive nav structure intact.

**Architecture:** New shared widgets (`SectionCard`, `BrandChevronMark`/`BrandChevronDivider`, `HeroPhoto`) added to `lib/core/widgets/`, consumed by every page's existing `StatelessWidget` build methods. One new pure function (`buildMailtoUri`) replaces "submit to a server that doesn't exist" with a `mailto:` link. Two new theme tokens (`tertiary` brand-navy color, `heroDisplayStyle`) extend `AppTheme` without touching its existing tokens.

**Tech Stack:** Flutter/Dart only — no new pubspec dependencies (icons come from Material's built-in `Icons`, no new package). Image processing for the icon/photo assets uses a one-off scratch Node script (Jimp), run outside the repo, that is never committed or added as a project dependency.

Full context and rationale: `docs/superpowers/specs/2026-09-01-portfolio-redesign-design.md`.

## Global Constraints

- Every git commit must be authored solely as the repository owner. Never add a `Co-Authored-By` line or any AI/tool-attribution trailer to a commit message.
- CI and local verification both use Flutter `3.47.2` — run `flutter`/`dart` commands via `C:\fci\flutter\bin\flutter.bat` (or the equivalent on the executor's machine), not whatever `flutter` resolves to on PATH, which may be a different local dev SDK.
- Formação and Currículo pages are **out of scope** — do not modify `lib/features/education/education_page.dart` or `lib/features/resume/resume_page.dart` in this plan.
- Do not add any new pubspec dependency. `Icons.*` (Flutter/Material, already available) covers every icon needed.
- Do not add Jimp (or any image library) to `pubspec.yaml`, `tool/smoke_test/package.json`, or any other committed manifest — the asset-generation script in Task 3 runs from a scratch/temp directory outside the repo and is not part of the codebase.
- Existing widget tests' text assertions (`find.text(...)`, `find.textContaining(...)`) must keep passing unchanged — every task that touches a page must re-run that page's existing test file and confirm it's still green before adding new assertions.
- This phase's final task pushes to `main`, which triggers a real deploy. Do not push without explicit user confirmation immediately before doing so — same production-action gate Fase 3/4/5/8 used for their deploys.

---

### Task 1: Add the brand-navy token and hero display style to `AppTheme`

**Files:**
- Modify: `lib/core/theme/app_theme.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `ColorScheme.tertiary` = brand navy `#14368B` in both `AppTheme.dark` and `AppTheme.light`. `AppTheme.heroDisplayStyle` (a `TextStyle` getter, uncolored — callers apply color via `.copyWith(color: ...)`, matching the existing `AppTheme.monoTextStyle` convention). Consumed by Task 4 (`HeroPhoto`), Task 5 (Home hero), and every task using `colorScheme.tertiary` for gradients (Tasks 2, 5, 8, 9).

- [ ] **Step 1: Add the `_brandNavy` constant and wire it into both color schemes**

In `lib/core/theme/app_theme.dart`, add this constant right after `_darkError` (line 21):

```dart
  // New in Fase 9: the exact navy from the VW logo mark, used for
  // gradients/depth (hero ring, card header strips, the chevron motif) —
  // never for plain text or button fills, which stay on _darkAccent /
  // _lightAccent.
  static const Color _brandNavy = Color(0xFF14368B);
```

In `dark` (the `ColorScheme.dark(...)` call), add two fields:

```dart
    const colorScheme = ColorScheme.dark(
      primary: _darkAccent,
      onPrimary: _darkOnAccent,
      secondary: _darkAccent,
      onSecondary: _darkOnAccent,
      tertiary: _brandNavy,
      onTertiary: _darkTextPrimary,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      onSurfaceVariant: _darkTextSecondary,
      outline: _darkOutline,
      error: _darkError,
      onError: _darkOnAccent,
    );
```

In `light` (the `ColorScheme.light(...)` call), add:

```dart
    const colorScheme = ColorScheme.light(
      primary: _lightAccent,
      onPrimary: _lightOnAccent,
      secondary: _lightAccent,
      onSecondary: _lightOnAccent,
      tertiary: _brandNavy,
      onTertiary: Colors.white,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      onSurfaceVariant: _lightTextPrimary,
      outline: _lightOutline,
      error: _lightError,
      onError: _lightOnAccent,
    );
```

- [ ] **Step 2: Add `heroDisplayStyle`**

Add this getter right after `monoTextStyle` at the end of the class:

```dart

  /// Large display style for the Home hero's name — bigger and bolder than
  /// [TextTheme.headlineLarge] so the hero reads as a thesis statement, per
  /// the Fase 9 redesign. Uncolored, like [monoTextStyle] — callers apply
  /// color via `.copyWith(color: ...)`.
  static TextStyle get heroDisplayStyle => GoogleFonts.spaceGrotesk(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    height: 1.05,
  );
```

- [ ] **Step 3: Verify existing tests still pass**

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues, all existing tests green (this change only adds fields/a getter — no existing token's value changed).

- [ ] **Step 4: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "$(cat <<'EOF'
Add brand-navy tertiary color and hero display style to AppTheme

Introduces the exact navy (#14368B) from the new VW logo as
ColorScheme.tertiary in both themes, and a larger heroDisplayStyle
for the Home hero — both additive, no existing token changes.
EOF
)"
```

---

### Task 2: Add `SectionCard`, `BrandChevronMark`, and `BrandChevronDivider`

**Files:**
- Create: `lib/core/widgets/section_card.dart`
- Create: `lib/core/widgets/brand_chevron_mark.dart`
- Create: `lib/core/widgets/brand_chevron_divider.dart`
- Test: `test/core/widgets/section_card_test.dart`

**Interfaces:**
- Consumes: `Theme.of(context).colorScheme` (`surface`, `outline`, `tertiary`, `primary` — all exist after Task 1).
- Produces: `SectionCard({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(20)})`, `BrandChevronMark({double strokeWidth = 3})`, `BrandChevronDivider()` (no parameters). Consumed by Tasks 4–10.

- [ ] **Step 1: Write `SectionCard`'s test first**

Create `test/core/widgets/section_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/section_card.dart';

void main() {
  testWidgets('renders its child inside a bordered container', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SectionCard(child: Text('conteúdo'))),
      ),
    );

    expect(find.text('conteúdo'), findsOneWidget);
    expect(find.byType(SectionCard), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(SectionCard),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
    expect(decoration.borderRadius, BorderRadius.circular(12));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `C:\fci\flutter\bin\flutter.bat test test/core/widgets/section_card_test.dart`
Expected: FAIL — `section_card.dart` doesn't exist yet.

- [ ] **Step 3: Implement `SectionCard`**

Create `lib/core/widgets/section_card.dart`:

```dart
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
```

- [ ] **Step 4: Run the test to confirm it passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/core/widgets/section_card_test.dart`
Expected: PASS.

- [ ] **Step 5: Implement `BrandChevronMark`**

Create `lib/core/widgets/brand_chevron_mark.dart`:

```dart
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
```

- [ ] **Step 6: Implement `BrandChevronDivider`**

Create `lib/core/widgets/brand_chevron_divider.dart`:

```dart
import 'package:flutter/material.dart';

import 'brand_chevron_mark.dart';

/// A section-break divider reusing [BrandChevronMark] in place of a
/// generic [Divider] — see
/// docs/superpowers/specs/2026-09-01-portfolio-redesign-design.md.
class BrandChevronDivider extends StatelessWidget {
  const BrandChevronDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(width: 32, height: 16, child: BrandChevronMark()),
      ),
    );
  }
}
```

- [ ] **Step 7: Run `flutter analyze` and the full suite**

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues, all tests green (new + existing).

- [ ] **Step 8: Commit**

```bash
git add lib/core/widgets/section_card.dart lib/core/widgets/brand_chevron_mark.dart lib/core/widgets/brand_chevron_divider.dart test/core/widgets/section_card_test.dart
git commit -m "$(cat <<'EOF'
Add SectionCard, BrandChevronMark, and BrandChevronDivider

Shared widgets for the Fase 9 redesign: SectionCard is the consistent
bordered/shadowed container every section-level block will use;
BrandChevronMark/Divider reuse the VW logo's own chevron shape as the
redesign's one repeated signature motif instead of a generic Divider.
EOF
)"
```

---

### Task 3: Process the brand/photo assets and register them

**Files:**
- Create: `web/favicon.png` (overwrite), `web/icons/Icon-192.png` (overwrite), `web/icons/Icon-512.png` (overwrite), `web/icons/Icon-maskable-192.png` (overwrite), `web/icons/Icon-maskable-512.png` (overwrite)
- Create: `assets/branding/vw-logo.png`
- Create: `assets/images/foto-victor-welter.jpg`
- Modify: `pubspec.yaml`
- Delete: `VW LOGO (2).png`, `VW LOGO (3).png`, `VW LOGO (4).png`, `VW LOGO (5).png`, `foto_minha.jpeg` (repo root)

**Interfaces:**
- Consumes: nothing (source files are the 5 loose images already in the repo root).
- Produces: `assets/images/foto-victor-welter.jpg` (consumed by Task 4's `HeroPhoto`), a `pubspec.yaml` `flutter: assets:` section registering `assets/images/` (consumed by Task 4), and the 5 regenerated icon files (no code consumes these directly — they're static web assets already referenced by `web/index.html`/`web/manifest.json`, unchanged).

This task's image processing runs in a scratch directory using a one-off
`jimp` install — **do not** add `jimp` to any file inside the repo.

- [ ] **Step 1: Set up the scratch image tool**

Run (from anywhere outside the repo, e.g. a temp dir):

```bash
mkdir -p /tmp/vw-icon-tool && cd /tmp/vw-icon-tool
npm init -y
npm install jimp@0.22.12
```

(On Windows, use whatever temp directory your shell provides — the exact
path doesn't matter, it's discarded at the end of this task.)

- [ ] **Step 2: Write and run the crop/generate script**

Create `/tmp/vw-icon-tool/generate.js` (adjust the two path constants at the
top to point at your actual repo checkout):

```js
'use strict';
const Jimp = require('jimp');
const path = require('path');

const REPO = 'C:/Users/Victor/Documents/git/victor-welter.github.io';
const SOURCE_LOGO = path.join(REPO, 'VW LOGO (4).png');

// Exact bounding box of the "VW" mark within the 500x500 source,
// excluding the "SOFTWARE" wordmark below it (measured 2026-09-01 by
// scanning the source PNG's alpha channel row-by-row: the mark occupies
// rows 190-310, the wordmark starts at row 315, so this crop cannot
// include any part of it).
const CROP = { x: 150, y: 190, w: 200, h: 121 };

async function buildTransparentMaster() {
  const source = await Jimp.read(SOURCE_LOGO);
  const mark = source.clone().crop(CROP.x, CROP.y, CROP.w, CROP.h);

  // Scale the mark up so its width is 320px, preserving aspect ratio,
  // then center it on a 512x512 transparent canvas.
  const scale = 320 / CROP.w;
  const markW = 320;
  const markH = Math.round(CROP.h * scale);
  mark.resize(markW, markH);

  const master = new Jimp(512, 512, 0x00000000);
  master.composite(
    mark,
    Math.round((512 - markW) / 2),
    Math.round((512 - markH) / 2),
  );
  return master;
}

async function buildMaskableMaster() {
  const source = await Jimp.read(SOURCE_LOGO);
  const mark = source.clone().crop(CROP.x, CROP.y, CROP.w, CROP.h);

  // Smaller (280px wide) and on a solid white plate, so the mark stays
  // inside the ~80% "safe zone" maskable icons require once the OS
  // crops the square canvas to a circle/squircle.
  const scale = 280 / CROP.w;
  const markW = 280;
  const markH = Math.round(CROP.h * scale);
  mark.resize(markW, markH);

  const plate = new Jimp(512, 512, 0xffffffff);
  plate.composite(
    mark,
    Math.round((512 - markW) / 2),
    Math.round((512 - markH) / 2),
  );
  return plate;
}

(async () => {
  const master = await buildTransparentMaster();
  await master.clone().writeAsync(path.join(REPO, 'web/icons/Icon-512.png'));
  await master
    .clone()
    .resize(192, 192)
    .writeAsync(path.join(REPO, 'web/icons/Icon-192.png'));
  await master
    .clone()
    .resize(64, 64)
    .writeAsync(path.join(REPO, 'web/favicon.png'));
  await master
    .clone()
    .writeAsync(path.join(REPO, 'assets/branding/vw-logo.png'));

  const maskable = await buildMaskableMaster();
  await maskable
    .clone()
    .writeAsync(path.join(REPO, 'web/icons/Icon-maskable-512.png'));
  await maskable
    .clone()
    .resize(192, 192)
    .writeAsync(path.join(REPO, 'web/icons/Icon-maskable-192.png'));

  console.log('done');
})();
```

Before running it, create the destination directory:

```bash
mkdir -p "C:/Users/Victor/Documents/git/victor-welter.github.io/assets/branding"
mkdir -p "C:/Users/Victor/Documents/git/victor-welter.github.io/assets/images"
```

Run:

```bash
node /tmp/vw-icon-tool/generate.js
```

Expected: prints `done`, and the 5 destination files under `web/` now
exist with new content, plus `assets/branding/vw-logo.png` is created.

- [ ] **Step 3: Visually verify the generated icons**

Open (or use the Read tool on) `web/favicon.png`, `web/icons/Icon-192.png`,
and `web/icons/Icon-maskable-192.png`. Confirm: the first two show the
navy "VW" mark on a transparent background with no "SOFTWARE" text and no
visible cropping artifacts; the maskable one shows the same mark on a
solid white square, comfortably inside the center (not touching the
edges).

- [ ] **Step 4: Move and rename the photo**

`foto_minha.jpeg` is untracked (confirmed via `git status --short` showing
`?? foto_minha.jpeg`), so `git mv` doesn't apply here — it only works on
files git already tracks. Use a plain move, then stage the new path:

```bash
cd "C:/Users/Victor/Documents/git/victor-welter.github.io"
mv foto_minha.jpeg assets/images/foto-victor-welter.jpg
git add assets/images/foto-victor-welter.jpg
```

- [ ] **Step 5: Register `assets/images/` in `pubspec.yaml`**

In `pubspec.yaml`, change:

```yaml
flutter:
  uses-material-design: true
```

to:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

- [ ] **Step 6: Remove the 3 unused logo variants from the repo root**

All 4 `VW LOGO (*).png` files are untracked (confirmed via
`git status --short` — every one shows as `??`), so a plain `rm` is
correct for all of them; there's nothing for git to un-track:

```bash
cd "C:/Users/Victor/Documents/git/victor-welter.github.io"
rm "VW LOGO (2).png" "VW LOGO (3).png" "VW LOGO (4).png" "VW LOGO (5).png"
```

- [ ] **Step 7: Gitignore the local agent-tooling directories while you're
      cleaning up the root**

`git status --short` also currently shows `.claude/`, `.agents/`, and
`skills-lock.json` as untracked — local Claude Code/agent-skill tooling
state (worktree bookkeeping, an installed skill's symlink, its lockfile),
analogous to `.vscode/` (already gitignored below the "IntelliJ related"
section). Add these three lines to `.gitignore`, right after the existing
`.vscode/` line:

```gitignore
.claude/
.agents/
skills-lock.json
```

- [ ] **Step 8: Verify `flutter pub get` picks up the new asset registration**

Run: `C:\fci\flutter\bin\flutter.bat pub get`
Expected: completes with no errors.

- [ ] **Step 9: Commit**

```bash
git add web/favicon.png web/icons/Icon-192.png web/icons/Icon-512.png web/icons/Icon-maskable-192.png web/icons/Icon-maskable-512.png assets/branding/vw-logo.png assets/images/foto-victor-welter.jpg pubspec.yaml .gitignore
git commit -m "$(cat <<'EOF'
Replace the default Flutter icons with the VW logo, add the hero photo

Crops the "VW" mark out of the supplied logo (dropping the "SOFTWARE"
wordmark, illegible at favicon sizes) into every icon size the site
already references — favicon, regular 192/512, and maskable 192/512
(mark on a solid white plate, sized to respect the maskable safe
zone). Registers assets/images/ in pubspec.yaml and adds the résumé
photo there for Task 4's HeroPhoto widget. The loose source files in
the repo root are removed now that they're processed into their real
destinations; the chosen source is kept at assets/branding/vw-logo.png.
Also gitignores .claude/, .agents/, and skills-lock.json — local
agent-tooling state noticed while cleaning up the root, same category
as the already-gitignored .vscode/.
EOF
)"
```

---

### Task 4: Add the `HeroPhoto` widget

**Files:**
- Create: `lib/core/widgets/hero_photo.dart`
- Test: `test/core/widgets/hero_photo_test.dart`

**Interfaces:**
- Consumes: `assets/images/foto-victor-welter.jpg` (Task 3), `colorScheme.primary`/`tertiary`/`surface`/`outline` (Task 1), `BrandChevronMark` (Task 2).
- Produces: `HeroPhoto({double size = 260})`. Consumed by Task 5 (Home hero).

- [ ] **Step 1: Write the test first**

Create `test/core/widgets/hero_photo_test.dart`:

```dart
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
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `C:\fci\flutter\bin\flutter.bat test test/core/widgets/hero_photo_test.dart`
Expected: FAIL — `hero_photo.dart` doesn't exist yet.

- [ ] **Step 3: Implement `HeroPhoto`**

Create `lib/core/widgets/hero_photo.dart`:

```dart
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
```

- [ ] **Step 4: Run the test to confirm it passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/core/widgets/hero_photo_test.dart`
Expected: PASS.

- [ ] **Step 5: Run `flutter analyze` and the full suite**

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues, all tests green.

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/hero_photo.dart test/core/widgets/hero_photo_test.dart
git commit -m "$(cat <<'EOF'
Add HeroPhoto: the Home hero's circular photo with a gradient ring

Frames assets/images/foto-victor-welter.jpg in a ClipOval inside an
accent-to-brand-navy gradient ring, with a small BrandChevronMark
badge — ready for Task 5 to place on the Home page.
EOF
)"
```

---

### Task 5: Restyle Home (the hero)

**Files:**
- Modify: `lib/features/home/home_page.dart`
- Modify: `test/features/home/home_page_test.dart`

**Interfaces:**
- Consumes: `HeroPhoto` (Task 4), `AppTheme.heroDisplayStyle` (Task 1), `context.isMobile` (existing `Breakpoints`).
- Produces: no public API change.

- [ ] **Step 1: Replace the full contents of `home_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hero_photo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Víctor Welter',
          style: AppTheme.heroDisplayStyle.copyWith(
            color: textTheme.headlineLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Engenheiro de Computação · Software · IA',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Engenheiro de Computação com experiência em desenvolvimento de '
          'software, integração de sistemas e melhoria de processos. Atuo '
          'com aplicações, APIs e bancos de dados, além de projetos e '
          'pesquisas em Inteligência Artificial e Visão Computacional.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => context.go('/projetos'),
              child: const Text('Ver Projetos'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/contato'),
              child: const Text('Entrar em Contato'),
            ),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(child: HeroPhoto(size: 200)),
                const SizedBox(height: 24),
                textColumn,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: textColumn),
                const SizedBox(width: 40),
                const HeroPhoto(),
              ],
            ),
    );
  }
}
```

- [ ] **Step 2: Run the existing test to confirm it still passes as-is**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/home/home_page_test.dart`
Expected: PASS — the 3 existing tests (name/tagline text, both button
navigations) don't depend on the Row/Column structure.

- [ ] **Step 3: Add a test asserting the hero photo is present**

In `test/features/home/home_page_test.dart`, add this import:

```dart
import 'package:portfolio/core/widgets/hero_photo.dart';
```

And add this test inside `main()`:

```dart
  testWidgets('shows the hero photo', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.byType(HeroPhoto), findsOneWidget);
  });
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/home/home_page_test.dart`
Expected: PASS (4 tests total).

- [ ] **Step 5: Run the whole suite and analyze**

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues; every test green.

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/home_page.dart test/features/home/home_page_test.dart
git commit -m "$(cat <<'EOF'
Restyle Home: hero layout with the circular photo

Text + HeroPhoto side by side (Row) on tablet/desktop, photo above
text (Column) on mobile. The hero name now uses AppTheme's larger
heroDisplayStyle instead of the shared headlineLarge every other
page's title also uses.
EOF
)"
```

---

### Task 6: Restyle Sobre

**Files:**
- Modify: `lib/features/about/about_page.dart`
- Modify: `test/features/about/about_page_test.dart`

**Interfaces:**
- Consumes: `SectionCard` (Task 2).
- Produces: no public API change.

- [ ] **Step 1: Replace the full contents of `about_page.dart`**

```dart
import 'package:flutter/material.dart';

import '../../core/widgets/section_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sobre', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Olá! Sou Víctor Vinícius Welter, Engenheiro de Computação e '
                  'Técnico em Informática, com experiência em desenvolvimento de '
                  'software, integração de sistemas e melhoria de processos. '
                  'Minha experiência envolve desenvolvimento de aplicações, APIs '
                  'e bancos de dados, além do contato com práticas de '
                  'arquitetura, Cloud Computing e DevOps.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Também desenvolvo projetos e pesquisas na área de '
                  'Inteligência Artificial e Visão Computacional, explorando '
                  'modelos de Deep Learning aplicados a problemas reais. Busco '
                  'constantemente aprimorar minhas habilidades e acompanhar '
                  'novas tecnologias. Priorizo a organização, qualidade e '
                  'excelência no que faço, além de valorizar a comunicação, o '
                  'trabalho em equipe e o aprendizado contínuo.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Três de Maio, Rio Grande do Sul, Brasil',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run the existing test to confirm it still passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/about/about_page_test.dart`
Expected: PASS — all 4 assertions check text content, unaffected by the
new wrapper.

- [ ] **Step 3: Add a test asserting the `SectionCard` wrapper**

Add this import to `test/features/about/about_page_test.dart`:

```dart
import 'package:portfolio/core/widgets/section_card.dart';
```

And add this test inside `main()`:

```dart
  testWidgets('wraps the bio in a SectionCard', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));

    expect(find.byType(SectionCard), findsOneWidget);
  });
```

- [ ] **Step 4: Run it to confirm it passes, then run the whole suite**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/about/about_page_test.dart`
Expected: PASS (2 tests total).

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues; every test green.

- [ ] **Step 5: Commit**

```bash
git add lib/features/about/about_page.dart test/features/about/about_page_test.dart
git commit -m "$(cat <<'EOF'
Restyle Sobre: bio inside a SectionCard

No content change — the bio text moves from bare Column children
into the shared SectionCard wrapper, matching every other page's new
visual system.
EOF
)"
```

---

### Task 7: Restyle Skills

**Files:**
- Modify: `lib/features/skills/skills_page.dart`
- Modify: `test/features/skills/skills_page_test.dart`

**Interfaces:**
- Consumes: `SectionCard` (Task 2), `context.isDesktop`/`isTablet` (existing `Breakpoints`).
- Produces: no public API change.

- [ ] **Step 1: Replace the full contents of `skills_page.dart`**

```dart
import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/tag_chip.dart';
import 'skills_data.dart';

const Map<String, IconData> _categoryIcons = {
  'Mobile': Icons.smartphone,
  'Backend & Dados': Icons.storage,
  'IA & Automação': Icons.auto_awesome,
  'Processos & Qualidade': Icons.rule,
  'Arquitetura & Cloud': Icons.cloud,
};

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final columns = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);
    const spacing = 16.0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skills', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) /
                    columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final category in skillCategories)
                      SizedBox(
                        width: cardWidth,
                        child: SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _categoryIcons[category.name] ??
                                        Icons.category,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      style: textTheme.titleLarge,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final skill in category.skills)
                                    TagChip(skill),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the existing test to confirm it still passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/skills/skills_page_test.dart`
Expected: PASS — category names and `TagChip`s are unaffected by the new
grid/card wrapper.

- [ ] **Step 3: Add a test asserting one `SectionCard` per category**

Add this import to `test/features/skills/skills_page_test.dart`:

```dart
import 'package:portfolio/core/widgets/section_card.dart';
```

And add this test inside `main()`:

```dart
  testWidgets('wraps each of the 5 categories in a SectionCard', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SkillsPage()));

    expect(find.byType(SectionCard), findsNWidgets(5));
  });
```

- [ ] **Step 4: Run it to confirm it passes, then run the whole suite**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/skills/skills_page_test.dart`
Expected: PASS (2 tests total).

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues; every test green.

- [ ] **Step 5: Commit**

```bash
git add lib/features/skills/skills_page.dart test/features/skills/skills_page_test.dart
git commit -m "$(cat <<'EOF'
Restyle Skills: category cards in a responsive grid

Each category becomes a SectionCard with a category icon, laid out
3-wide on desktop, 2-wide on tablet, 1-wide on mobile, replacing the
bare heading+Wrap list.
EOF
)"
```

---

### Task 8: Restyle Experiência

**Files:**
- Modify: `lib/features/experience/experience_page.dart`
- Modify: `test/features/experience/experience_page_test.dart`

**Interfaces:**
- Consumes: `SectionCard`, `BrandChevronDivider` (Task 2), `AppTheme.monoTextStyle` (existing).
- Produces: no public API change.

- [ ] **Step 1: Replace the full contents of `experience_page.dart`**

```dart
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_chevron_divider.dart';
import '../../core/widgets/section_card.dart';
import 'experience_data.dart';

class ExperiencePage extends StatelessWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = experienceEntries.where(
      (e) => e.tier == ExperienceTier.primary,
    );
    final previous = experienceEntries.where(
      (e) => e.tier == ExperienceTier.previous,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Experiência', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final entry in primary) _ExperienceCard(entry: entry),
            const BrandChevronDivider(),
            Text('Experiência anterior', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final entry in previous) _PreviousExperienceRow(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.entry});

  final ExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isCurrent = entry.period.contains('Presente');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        padding: EdgeInsets.zero,
        // IntrinsicHeight gives the Row a real height to stretch its
        // children to — without it, CrossAxisAlignment.stretch inside a
        // Row whose parent (ultimately a SingleChildScrollView) imposes no
        // height constraint would ask the accent-bar Container to be
        // infinitely tall and crash.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: isCurrent ? colorScheme.primary : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.role, style: textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.company} · ${entry.period}',
                        style: AppTheme.monoTextStyle.copyWith(
                          color: textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final bullet in entry.bullets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $bullet',
                            style: textTheme.bodyLarge,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviousExperienceRow extends StatelessWidget {
  const _PreviousExperienceRow({required this.entry});

  final ExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '${entry.role} — ${entry.company} (${entry.period})',
        style: textTheme.bodyMedium,
      ),
    );
  }
}
```

- [ ] **Step 2: Run the existing test to confirm it still passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/experience/experience_page_test.dart`
Expected: PASS — every assertion checks text content that's unchanged.

- [ ] **Step 3: Add a test asserting one `SectionCard` per primary role**

Add this import to `test/features/experience/experience_page_test.dart`:

```dart
import 'package:portfolio/core/widgets/section_card.dart';
```

And add this test inside `main()`:

```dart
  testWidgets('wraps each of the 3 primary roles in a SectionCard', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperiencePage()));

    expect(find.byType(SectionCard), findsNWidgets(3));
  });
```

- [ ] **Step 4: Run it to confirm it passes, then run the whole suite**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/experience/experience_page_test.dart`
Expected: PASS (2 tests total).

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues; every test green.

- [ ] **Step 5: Commit**

```bash
git add lib/features/experience/experience_page.dart test/features/experience/experience_page_test.dart
git commit -m "$(cat <<'EOF'
Restyle Experiência: role cards with a current-role accent bar

Each primary role becomes a SectionCard; the one with "Presente" in
its period gets a 4px accent-colored left bar — real information
(it's the current job), not decoration. Date ranges switch to
AppTheme.monoTextStyle, and a BrandChevronDivider replaces the plain
gap before "Experiência anterior".
EOF
)"
```

---

### Task 9: Restyle Projetos

**Files:**
- Modify: `lib/features/projects/projects_page.dart`
- Modify: `test/features/projects/projects_page_test.dart`

**Interfaces:**
- Consumes: `SectionCard` (Task 2).
- Produces: no public API change.

- [ ] **Step 1: Replace the full contents of `projects_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/section_card.dart';
import '../../core/widgets/tag_chip.dart';
import 'projects_data.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final featured = projectEntries.where(
      (p) => p.tier == ProjectTier.featured,
    );
    final secondary = projectEntries.where(
      (p) => p.tier == ProjectTier.secondary,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Projetos', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final project in featured) _ProjectCard(project: project),
            const SizedBox(height: 12),
            Text('Outros projetos', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final project in secondary)
              _SecondaryProjectRow(project: project),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(project.name, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(project.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tech in project.techStack) TagChip(tech),
                    ],
                  ),
                  if (project.links.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        for (final link in project.links)
                          TextButton(
                            onPressed: () => launchUrl(Uri.parse(link.url)),
                            child: Text(link.label),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryProjectRow extends StatelessWidget {
  const _SecondaryProjectRow({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: project.links.isEmpty
                ? null
                : () => launchUrl(Uri.parse(project.links.first.url)),
            child: Text(
              '${project.name} — ${project.description}',
              style: textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the existing tests to confirm they still pass**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/projects/projects_page_test.dart`
Expected: PASS — both existing tests check text/`TagChip`/`TextButton`
counts, all unaffected (`TextButton` count is still exactly 8: the
`_ProjectCard`/`_SecondaryProjectRow` restructuring doesn't add or remove
any `TextButton`, since the link-launching `TextButton`s are unchanged and
`_SecondaryProjectRow` still uses `InkWell`, not `TextButton`).

- [ ] **Step 3: Add a test asserting one `SectionCard` per project entry**

Add this import to `test/features/projects/projects_page_test.dart`:

```dart
import 'package:portfolio/core/widgets/section_card.dart';
```

And add this test inside `main()`:

```dart
  testWidgets(
    'wraps every project (4 featured + 3 secondary) in a SectionCard',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectsPage()));

      expect(find.byType(SectionCard), findsNWidgets(7));
    },
  );
```

- [ ] **Step 4: Run it to confirm it passes, then run the whole suite**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/projects/projects_page_test.dart`
Expected: PASS (3 tests total).

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues; every test green.

- [ ] **Step 5: Commit**

```bash
git add lib/features/projects/projects_page.dart test/features/projects/projects_page_test.dart
git commit -m "$(cat <<'EOF'
Restyle Projetos: gradient-strip cards for every entry

_ProjectCard moves from a bare Material Card to SectionCard with a
6px accent-to-brand-navy gradient strip on top — a visual anchor
point since there are no real project screenshots. Secondary rows
also become thin SectionCards instead of bare InkWell text rows.
EOF
)"
```

---

### Task 10: Restyle Contato — `mailto.dart` and the two-panel layout

**Files:**
- Create: `lib/features/contact/mailto.dart`
- Test: `test/features/contact/mailto_test.dart`
- Modify: `lib/features/contact/contact_page.dart`
- Modify: `test/features/contact/contact_page_test.dart`

**Interfaces:**
- Consumes: `SectionCard` (Task 2), `context.isMobile` (existing `Breakpoints`).
- Produces: `Uri buildMailtoUri({required String name, required String subject, required String message})`. Not consumed by any other task — only `ContactPage` and Task 11's smoke-test update use it (indirectly, via the running app).

- [ ] **Step 1: Write `mailto_test.dart` first**

Create `test/features/contact/mailto_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/contact/mailto.dart';

void main() {
  test('builds a mailto uri with a "De:" prefix and encoded fields', () {
    final uri = buildMailtoUri(
      name: 'Ana Souza',
      subject: 'Proposta de projeto',
      message: 'Olá, gostaria de conversar sobre uma vaga.',
    );

    expect(uri.scheme, 'mailto');
    expect(uri.path, 'victorwelter2003@gmail.com');
    expect(uri.queryParameters['subject'], 'Proposta de projeto');
    expect(
      uri.queryParameters['body'],
      'De: Ana Souza\n\nOlá, gostaria de conversar sobre uma vaga.',
    );
  });

  test('omits the "De:" prefix when name is empty', () {
    final uri = buildMailtoUri(
      name: '',
      subject: 'Oi',
      message: 'Mensagem sem nome.',
    );

    expect(uri.queryParameters['body'], 'Mensagem sem nome.');
  });

  test('omits subject/body query params entirely when both are empty', () {
    final uri = buildMailtoUri(name: '', subject: '', message: '');

    expect(uri.queryParameters.containsKey('subject'), isFalse);
    expect(uri.queryParameters.containsKey('body'), isFalse);
    expect(uri.toString(), 'mailto:victorwelter2003@gmail.com');
  });

  test('percent-encodes special characters in the subject', () {
    final uri = buildMailtoUri(
      name: '',
      subject: 'Olá & bem-vindo?',
      message: 'Linha 1\nLinha 2',
    );

    expect(uri.toString(), contains('subject=Ol%C3%A1'));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/contact/mailto_test.dart`
Expected: FAIL — `mailto.dart` doesn't exist yet.

- [ ] **Step 3: Implement `buildMailtoUri`**

Create `lib/features/contact/mailto.dart`:

```dart
/// Builds a `mailto:` [Uri] for the Contato page's message form. A pure
/// function — no `url_launcher` call here — so it's unit-testable without
/// any platform-channel mock. See
/// docs/superpowers/specs/2026-09-01-portfolio-redesign-design.md.
Uri buildMailtoUri({
  required String name,
  required String subject,
  required String message,
}) {
  final body = name.isEmpty
      ? message
      : (message.isEmpty ? 'De: $name' : 'De: $name\n\n$message');

  return Uri(
    scheme: 'mailto',
    path: 'victorwelter2003@gmail.com',
    queryParameters: {
      if (subject.isNotEmpty) 'subject': subject,
      if (body.isNotEmpty) 'body': body,
    },
  );
}
```

- [ ] **Step 4: Run the test to confirm it passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/contact/mailto_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Replace the full contents of `contact_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/widgets/section_card.dart';
import 'mailto.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final uri = buildMailtoUri(
      name: _nameController.text,
      subject: _subjectController.text,
      message: _messageController.text,
    );
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final formCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Envie uma mensagem', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Assunto'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Mensagem'),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _sendMessage, child: const Text('Enviar')),
        ],
      ),
    );

    final infoCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Informações de contato', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          _ContactLink(
            icon: Icons.email,
            label: 'victorwelter2003@gmail.com',
            onTap: () =>
                launchUrl(Uri.parse('mailto:victorwelter2003@gmail.com')),
          ),
          _ContactLink(
            icon: Icons.link,
            label: 'linkedin.com/in/victor-welter',
            onTap: () => launchUrl(
              Uri.parse('https://www.linkedin.com/in/victor-welter'),
            ),
          ),
          _ContactLink(
            icon: Icons.code,
            label: 'github.com/victor-welter',
            onTap: () =>
                launchUrl(Uri.parse('https://github.com/victor-welter')),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18),
              const SizedBox(width: 8),
              Text(
                'Três de Maio, Rio Grande do Sul, Brasil',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Contato', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            context.isMobile
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      formCard,
                      const SizedBox(height: 16),
                      infoCard,
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: formCard),
                        const SizedBox(width: 16),
                        Expanded(child: infoCard),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ContactLink extends StatelessWidget {
  const _ContactLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run the existing test to confirm it still passes**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/contact/contact_page_test.dart`
Expected: PASS — email/LinkedIn/GitHub/location text is still present
(now inside icon+label rows), unaffected by `ContactPage` becoming a
`StatefulWidget` (its public constructor is unchanged).

- [ ] **Step 7: Extend the test with the new form fields**

Replace the full contents of `test/features/contact/contact_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/contact/contact_page.dart';

void main() {
  testWidgets(
    'shows the message form fields, send button, and contact info',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ContactPage()));

      expect(find.widgetWithText(TextField, 'Nome'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Assunto'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Mensagem'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Enviar'), findsOneWidget);

      expect(find.text('victorwelter2003@gmail.com'), findsOneWidget);
      expect(find.text('linkedin.com/in/victor-welter'), findsOneWidget);
      expect(find.text('github.com/victor-welter'), findsOneWidget);
      expect(
        find.text('Três de Maio, Rio Grande do Sul, Brasil'),
        findsOneWidget,
      );
    },
  );
}
```

(This does not tap "Enviar" — this codebase never taps a `url_launcher`-
triggering button in a widget test, since `url_launcher` has no platform
channel available under `flutter test` and would throw
`MissingPluginException`. `resume_page_test.dart`/the existing
`contact_page_test.dart` already follow this convention; the real
"does it launch the right thing" verification for `buildMailtoUri`'s
output happens in Step 4's unit tests, and the end-to-end launch behavior
is verified for real in Task 11's smoke-test update.)

- [ ] **Step 8: Run it to confirm it passes, then run the whole suite**

Run: `C:\fci\flutter\bin\flutter.bat test test/features/contact/contact_page_test.dart`
Expected: PASS.

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues; every test green.

- [ ] **Step 9: Commit**

```bash
git add lib/features/contact/mailto.dart test/features/contact/mailto_test.dart lib/features/contact/contact_page.dart test/features/contact/contact_page_test.dart
git commit -m "$(cat <<'EOF'
Restyle Contato: two-panel layout with a mailto-based message form

Since the site is static (GitHub Pages, no backend), "Enviar" builds
a mailto: link via the new pure buildMailtoUri function (unit-tested
directly, no platform-channel mocking needed) instead of pretending
to submit to a server that doesn't exist. Info panel restyled with
icons; both panels are SectionCards, side by side on tablet/desktop
and stacked on mobile.
EOF
)"
```

---

### Task 11: Restyle the nav's active-state indicator

**Files:**
- Modify: `lib/core/widgets/app_shell.dart`
- Modify: `test/core/widgets/app_shell_test.dart`

**Interfaces:**
- Consumes: nothing new (uses existing `colorScheme.primary`).
- Produces: no public API change. The mobile drawer is intentionally left
  untouched — `ListTile(selected: ...)` already gives Material's built-in
  selected-state styling, which already satisfies the "visible active
  indicator" goal there.

- [ ] **Step 1: Replace the full contents of `app_shell.dart`**

To avoid any ambiguity about exactly which `TextButton` literals change,
replace the entire file rather than patching in place. This is the same
file with two call sites (the tablet "Home" button, the desktop `for`
loop) switched from a bare `TextButton` to the new `_NavBarItem`, and the
`_NavBarItem` class added at the end — every other line (imports,
`NavDestinationData`, the mobile branch, `_ThemeToggleButton`,
`_AppDrawer`) is unchanged from the current file:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/breakpoints.dart';
import '../theme/theme_controller.dart';
import '../theme/theme_scope.dart';

class NavDestinationData {
  const NavDestinationData({required this.label, required this.path});

  final String label;
  final String path;
}

const List<NavDestinationData> navDestinations = [
  NavDestinationData(label: 'Home', path: '/'),
  NavDestinationData(label: 'Sobre', path: '/sobre'),
  NavDestinationData(label: 'Experiência', path: '/experiencia'),
  NavDestinationData(label: 'Formação', path: '/formacao'),
  NavDestinationData(label: 'Skills', path: '/skills'),
  NavDestinationData(label: 'Projetos', path: '/projetos'),
  NavDestinationData(label: 'Currículo', path: '/curriculo'),
  NavDestinationData(label: 'Contato', path: '/contato'),
];

class AppShell extends StatelessWidget {
  const AppShell({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeToggle = _ThemeToggleButton(
      themeController: ThemeScope.of(context),
    );
    final colorScheme = Theme.of(context).colorScheme;

    // TextButton's Material 3 default foreground is always colorScheme.primary,
    // regardless of the TextTheme's own label color — so the active/inactive
    // distinction from the design spec must be set explicitly per button.
    Color navLabelColor(String path) =>
        currentPath == path ? colorScheme.primary : colorScheme.onSurfaceVariant;

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
            _NavBarItem(
              label: home.label,
              isActive: currentPath == home.path,
              color: navLabelColor(home.path),
              onTap: () => context.go(home.path),
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
                        color: navLabelColor(destination.path),
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
                    _NavBarItem(
                      label: destination.label,
                      isActive: currentPath == destination.path,
                      color: navLabelColor(destination.path),
                      onTap: () => context.go(destination.path),
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
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        // `mode` alone is ambiguous when it's `system`: resolve the mode the
        // visitor is actually seeing (accounting for the platform's current
        // brightness) so the icon and the tap target always agree with what
        // is on screen, including on the very first tap.
        final isDark =
            themeController.mode == ThemeMode.dark ||
            (themeController.mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: 'Alternar tema',
          onPressed: () => themeController.setMode(
            isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        );
      },
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          for (final destination in navDestinations)
            ListTile(
              title: Text(destination.label),
              selected: currentPath == destination.path,
              onTap: () {
                Navigator.of(context).pop();
                context.go(destination.path);
              },
            ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: color),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        AnimatedContainer(
          key: const Key('nav-active-indicator'),
          duration: const Duration(milliseconds: 150),
          height: 2,
          width: 20,
          margin: const EdgeInsets.only(top: 2),
          color: isActive ? color : Colors.transparent,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run the existing tests to confirm they still pass**

Run: `C:\fci\flutter\bin\flutter.bat test test/core/widgets/app_shell_test.dart`
Expected: PASS — every existing assertion looks for `TextButton` by text
and checks `style.foregroundColor`, both still present and unchanged;
wrapping the button in a `Column` alongside a new sibling doesn't affect
`find.widgetWithText(TextButton, ...)`.

- [ ] **Step 3: Add a test asserting the indicator's color**

Add this test inside `main()`, after the "desktop nav uses accent..."
test:

```dart
  testWidgets(
    'desktop nav shows a colored indicator under the active item only',
    (tester) async {
      await pumpShell(tester, const Size(1300, 800));

      final colorScheme = Theme.of(
        tester.element(find.byType(AppShell)),
      ).colorScheme;

      final indicators = tester.widgetList<AnimatedContainer>(
        find.byKey(const Key('nav-active-indicator')),
      );
      final activeCount = indicators
          .where((c) => c.color == colorScheme.primary)
          .length;
      final transparentCount = indicators
          .where((c) => c.color == Colors.transparent)
          .length;

      expect(activeCount, 1);
      expect(transparentCount, navDestinations.length - 1);
    },
  );
```

The key is set directly on the `_NavBarItem`'s `AnimatedContainer`
instance, so `find.byKey` returns that `AnimatedContainer` itself (not
some internal `Container` it builds) — `tester.widgetList<AnimatedContainer>`
is the correct type, and `.color` is a plain public field on it (same
constructor-parameter API as `Container`).

- [ ] **Step 4: Run it to confirm it passes, then run the whole suite**

Run: `C:\fci\flutter\bin\flutter.bat test test/core/widgets/app_shell_test.dart`
Expected: PASS.

Run: `C:\fci\flutter\bin\flutter.bat analyze && C:\fci\flutter\bin\flutter.bat test`
Expected: no analyzer issues; every test green.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/app_shell.dart test/core/widgets/app_shell_test.dart
git commit -m "$(cat <<'EOF'
Restyle nav: active-state indicator bar on tablet/desktop

Adds a small colored bar under the active destination on the
tablet "Home" button and every desktop nav item, on top of (not
replacing) the existing accent-color/bold-weight active styling.
The mobile drawer is untouched — ListTile's built-in selected state
already covers this there.
EOF
)"
```

---

### Task 12: Update the smoke test for the redesign

**Files:**
- Modify: `tool/smoke_test/smoke_test.js`

**Interfaces:**
- Consumes: the running app's rendered Contato form (Task 10).
- Produces: same CLI as before, with one more check.

- [ ] **Step 1: Add a Contato mailto check**

In `tool/smoke_test/smoke_test.js`, add this function after
`checkThemeToggle`:

```js
/**
 * The Contato "Enviar" button calls launchUrl on a mailto: Uri. Per the
 * Firefox investigation in Fase 8 (task-7-report.md), url_launcher_web
 * opens external links via a popup window rather than same-tab
 * navigation — this checks for that same popup, now carrying a mailto:
 * URL, instead of trying to detect an OS-level "open with mail client"
 * dialog headless Chromium has no shell to show anyway.
 */
async function checkContactMailto(page) {
  const popupPromise = page
    .waitForEvent('popup', { timeout: 10000 })
    .catch(() => null);
  await page.getByLabel('Nome', { exact: false }).fill('Visitante de Teste');
  await page
    .getByLabel('Assunto', { exact: false })
    .fill('Assunto de teste do smoke test');
  await page
    .getByLabel('Mensagem', { exact: false })
    .fill('Mensagem de teste do smoke test.');
  await page.getByText('Enviar', { exact: true }).click();
  const popup = await popupPromise;
  if (!popup) {
    throw new Error('no popup observed after clicking Enviar');
  }
  const url = popup.url();
  if (!url.startsWith('mailto:victorwelter2003@gmail.com')) {
    throw new Error(`contact mailto URL looks wrong: ${url}`);
  }
  await popup.close().catch(() => {});
}
```

Add the call site in `runChecks`, right after the theme-toggle check
block (after `console.log(\`[${browserName}] theme toggle: OK\`);`'s
`catch` block closes):

```js

  currentRoutePath = '/contato';
  try {
    await page.goto(baseUrl + '/contato', { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(3000);
    await enableSemantics(page);
    await checkContactMailto(page);
    console.log(`[${browserName}] contact mailto: OK`);
  } catch (err) {
    failures.push(`contact mailto check failed: ${err.message}`);
  }
```

- [ ] **Step 2: Build the app and run the smoke test locally**

Run (from the repo root):

```bash
C:\fci\flutter\bin\flutter.bat build web --release --source-maps
cp build/web/index.html build/web/404.html
cd tool/smoke_test
node smoke_test.js --dir ../../build/web --browser chromium
```

Expected: every check prints `OK`, including a new `contact mailto: OK`
line, ending with `All smoke checks passed.`

- [ ] **Step 3: If the popup pattern doesn't materialize, adapt based on
      what actually happens**

If Step 2 fails specifically on `checkContactMailto` with "no popup
observed" (not a crash, not a different route's failure), use the
superpowers:systematic-debugging skill: add a temporary
`page.on('console', msg => console.log('CONSOLE:', msg.text()))` and
`page.on('request', req => console.log('REQUEST:', req.url()))` listener
before the click to observe what Chromium actually does with the
`mailto:` navigation attempt in this exact pinned browser version, then
adjust `checkContactMailto` to assert on whatever real signal appears
(a console message about the unhandled scheme is the most likely
alternative, per Chromium's usual handling of unregistered protocol
navigations). Do not weaken the check to "no crash occurred" without
first observing what real signal is available — that would silently stop
verifying the one thing this check exists for.

- [ ] **Step 4: Commit**

```bash
git add tool/smoke_test/smoke_test.js
git commit -m "$(cat <<'EOF'
Add a Contato mailto check to the smoke test

Fills the message form and confirms clicking "Enviar" produces a
mailto: popup addressed to the right email, using the same
popup-based detection Task 7's Firefox investigation already
established for url_launcher_web's external-link behavior.
EOF
)"
```

---

### Task 13: Manual visual QA, push, and confirm the live CI gate

**Files:** none (verification and deploy only).

**Interfaces:** none.

- [ ] **Step 1: Screenshot all 3 breakpoints against the local build**

Run (from `tool/smoke_test/`, reusing the build from Task 12):

```bash
node -e "
const { chromium } = require('playwright');
const VIEWPORTS = [
  { name: 'mobile', width: 375, height: 900 },
  { name: 'tablet', width: 800, height: 1000 },
  { name: 'desktop', width: 1440, height: 1000 },
];
const ROUTES = ['/', '/sobre', '/skills', '/experiencia', '/projetos', '/contato'];
const { startServer } = require('./serve.js');
(async () => {
  const server = await startServer(require('path').resolve('../../build/web'), 0);
  const base = 'http://127.0.0.1:' + server.address().port;
  const browser = await chromium.launch();
  for (const vp of VIEWPORTS) {
    for (const route of ROUTES) {
      const page = await browser.newPage();
      await page.setViewportSize({ width: vp.width, height: vp.height });
      await page.goto(base + route, { waitUntil: 'load', timeout: 60000 });
      await page.waitForTimeout(2500);
      const name = route === '/' ? 'home' : route.replace(/\//g, '');
      await page.screenshot({ path: 'redesign-' + vp.name + '-' + name + '.png', fullPage: true });
      await page.close();
    }
  }
  await browser.close();
  server.close();
  console.log('done');
})();
"
```

- [ ] **Step 2: Review every screenshot**

Open all 18 PNGs. Confirm: no `RenderFlex overflow` visual artifacts, the
hero photo renders correctly at all 3 widths, every `SectionCard` shows
its border, the Contato panels stack correctly on mobile and sit
side-by-side on tablet/desktop, and the nav's active indicator is visible
under the current page on tablet/desktop. If anything looks wrong, use
superpowers:systematic-debugging on the affected page's file, following
that file's normal edit → `flutter test` → commit cycle, before
continuing.

- [ ] **Step 3: Confirm with the user before pushing**

This push deploys real changes to a live production site. Do not proceed
without explicit confirmation immediately before this step, per the
Global Constraints.

- [ ] **Step 4: Push**

```bash
git push origin main
```

- [ ] **Step 5: Watch the Actions run**

Confirm the `build` job (including the smoke-test gate, now covering the
Contato mailto check) passes, and `deploy` runs successfully afterward.

- [ ] **Step 6: Verify the live site**

Run (from `tool/smoke_test/`):

```bash
node smoke_test.js --url https://victor-welter.github.io --browser chromium
```

Expected: `All smoke checks passed.` Also spot-check the live site in a
real browser at mobile/tablet/desktop widths, the same way Step 2 checked
the local build.
