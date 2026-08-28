# Portfolio Fase 4 — Visual Identity Design

## Context

Fase 3 (Fundação) is complete and live at victor-welter.github.io: routing, adaptive
shell, theme scaffolding (`AppTheme.light`/`AppTheme.dark`, `ThemeController`,
`ThemeScope`), and CI/CD are all in place. `AppTheme` currently uses a single
placeholder seed color (`0xFF2563EB`) explicitly marked in Task 3's code comment
for this phase to replace. All nine pages are still `PlaceholderSection` widgets
showing `PLACEHOLDER: ...` text — Fase 4 does not touch page content or add real
copy; that's Fase 5 (Conteúdo).

**Goal of this phase:** replace the placeholder theme with a real, deliberate
visual identity — colors, typography, shape — and fix the tablet-width navigation
bug the Fase 3 final review found (nav items overflow/become unreachable between
~600-1024px). Nothing about routing, breakpoints structure, CI/CD, or page content
changes in this phase.

## Visual Direction

**Dark-mode-first, developer/IDE-inspired** — specifically the GitHub Dark / VS
Code Dark family of aesthetics: a dark blue-gray base (not pure black), one
electric-blue accent, a readable sans-serif body with a monospace font reserved
for technical/code-like elements. Rounded corners throughout (not the sharper
terminal-window look) — reads as approachable/modern rather than austere.

**Dark is the real identity. Light is a plain, secondary fallback**, not a mirror
of dark with inverted colors — it intentionally desaturates away from the brand
blue into near-monochrome (grays/black/white), on the reasoning that the site's
primary identity is dark and light mode exists for accessibility/preference, not
to carry equal visual weight.

No extra "developer motifs" (blinking cursor, syntax-highlight-style multicolor
text, scanline/grid textures) in this phase — color, type, and shape already
carry the identity. Revisit motifs later, if at all, once Fase 5 gives us real
content to design around.

## Color System

**Important implementation note:** dark and light must be built as two distinct,
explicitly-specified `ColorScheme`s (via the `ColorScheme.dark(...)` /
`ColorScheme.light(...)` base constructors with the overrides below) — **not**
`ColorScheme.fromSeed()` for both from one seed. `fromSeed` would still tint
light mode with the blue hue via Material 3's tonal palette generation, which
contradicts the "light is neutral, not a blue mirror" decision above.

### Dark theme (primary identity)

| Role | Value | Used for |
|---|---|---|
| Background | `#0D1117` | Scaffold background |
| Surface | `#161B22` | AppBar, cards, elevated surfaces |
| Outline / divider | `#30363D` | Borders, dividers, unselected chip outlines |
| Text — primary | `#E6EDF3` | Headings, primary body text |
| Text — secondary | `#8B949E` | Secondary/muted text, unselected nav labels |
| Accent (primary) | `#4D8DFF` | Active nav label, buttons, links, selected states |
| On-accent | `#0D1117` | Text/icons drawn on top of the accent color |

### Light theme (secondary/neutral)

| Role | Value | Used for |
|---|---|---|
| Background | `#FFFFFF` | Scaffold background |
| Surface | `#FAFAFA` | AppBar, cards |
| Outline / divider | `#E5E5E5` | Borders, dividers |
| Text — primary | `#2B2B2B` | Headings, primary body text |
| Text — secondary | `#6B6B6B` | Secondary/muted text |
| Accent (primary) | `#2B2B2B` (dark gray, **not blue**) | Active nav label, buttons, links, selected states |
| On-accent | `#FFFFFF` | Text/icons drawn on top of the accent color |

Both schemes stay Material 3 (`useMaterial3: true`, matching Fase 3).

## Typography

Loaded via the `google_fonts` package (new dependency this phase — standard,
well-maintained, integrates with Flutter's normal asset pipeline for release web
builds, no separate bundling step needed).

- **Space Grotesk** — `headlineLarge`/`headlineMedium`/`headlineSmall` and
  `titleLarge` in the `TextTheme` (page titles, the "Victor Welter" wordmark in
  the app bar).
- **Inter** — everything else in the `TextTheme`: `bodyLarge`/`bodyMedium`/
  `bodySmall`, `labelLarge`/`labelMedium`/`labelSmall` (nav labels, buttons,
  body copy).
- **JetBrains Mono** — not part of the global `TextTheme`. Exposed as a static
  getter `AppTheme.monoTextStyle` (same pattern as the existing `AppTheme.light`/
  `AppTheme.dark` getters) for technical/code-like UI elements. Nothing in the
  current codebase consumes this yet (skill tags/chips don't exist until
  Fase 5/6 content) — this phase just needs the style available and documented
  as the convention for whoever builds those widgets later.

## Shape

`8px` corner radius as the standard, applied via `CardTheme`,
`ElevatedButtonTheme`/`FilledButtonTheme`, and `InputDecorationTheme` overrides
in `ThemeData`. Full-pill radius (`999px`/`StadiumBorder`) is the intended
convention for chip/tag-style elements once they exist (Fase 5/6) — not built now
since there's no chip UI in the codebase yet, but should be documented in
`app_theme.dart` so it's followed consistently later.

Applies identically in light and dark.

## Tablet Navigation Fix

**The bug (from the Fase 3 final review):** `AppShell` only branches on
`isMobile` (drawer) vs. not (horizontal bar). At tablet widths (~600-1024px),
the horizontal bar's 8 nav items + title don't fit — the title truncates and
the last items become unreachable, with a `Flexible`+`SingleChildScrollView`
patch from Fase 3 that stops the crash but doesn't provide any visible
scroll affordance.

**The fix:** at `isTablet` width specifically, show only **"Home" inline plus a
"Mais ▾" overflow menu** (a `PopupMenuButton` — the standard Material widget for
a simple triggered item list, no custom anchor/trigger logic needed) containing
the other seven destinations (Sobre, Experiência, Formação, Skills, Projetos,
Currículo, Contato). This guarantees the inline content always fits — no
width-measuring logic, no curation bikeshedding — at the cost of one extra tap
to reach any page other than Home while at tablet width.

- `isMobile` (≤599px): unchanged — drawer.
- `isTablet` (600–1024px): **new** — "Home" inline + "Mais" overflow menu.
- `isDesktop` (>1024px): unchanged — all 8 items inline.

Given this exact bug previously slipped through because Fase 3's tests only
covered 400px and 1300px, the implementation must include test coverage across
the tablet band (not just one width) — this is a callback to a lesson already
paid for once on this project; don't pay for it twice.

## Scope

**Changes:**
- `pubspec.yaml` — add `google_fonts` dependency.
- `lib/core/theme/app_theme.dart` — rebuilt with the two explicit `ColorScheme`s
  above, the `google_fonts`-backed `TextTheme`, the mono text style/convention,
  and the shared `8px`/pill shape theme.
- `lib/core/widgets/app_shell.dart` — tablet-width overflow menu.

**Explicitly out of scope for this phase:**
- Page content (`lib/features/*`) — stays `PLACEHOLDER:`, that's Fase 5.
- Routing, breakpoints values, CI/CD — untouched, that's Fase 3's territory and
  it's done.
- Chip/tag components, skill lists, project cards — don't exist yet; this phase
  only establishes the style convention (mono font, pill shape) they'll use.
- Extra visual motifs (cursor blink, scanlines, syntax-highlight accents) —
  explicitly deferred, not part of this phase.
