# Portfolio Fase 9 (Redesign Visual) — Design Spec

## Context

The Fase 4 visual identity (color tokens, Space Grotesk/Inter/JetBrains Mono
type system, adaptive nav) shipped and is live, but Fase 5's content pass
never gave any page real visual composition: every page is a bare
top-aligned `Column` of headings and paragraphs, with no cards, imagery, or
depth. Screenshots of the live site (captured 2026-09-01, both themes)
confirm this: black-on-white (or light-gray-on-black) text, one accent
color used only for links/buttons, and roughly half of every page's
viewport left empty below the content.

Víctor supplied a real reference (rhuanbello.com, matching a set of
screenshots he shared) as the layout direction to work from: a hero with a
name/tagline and a large circular photo, a card-based grid for
skills/experience/projects, and a two-panel contact section. Per this
project's own frontend-design guidance, the goal is not to clone that
reference's palette or content, but to adapt its layout patterns to
Víctor's real profile (Computer Engineer — Flutter/mobile, backend APIs,
AI/Computer Vision, process improvement — not front-end/React) and his own
brand (the new VW logo, delivered in Fase 9's icon work), so the result
reads as authored for him rather than a re-skinned template.

Spec for the icon/favicon and photo-asset work referenced below:
this document supersedes the earlier "avatar only on Sobre" decision — the
photo now anchors the Home hero instead (see Decisions below).

## Decisions (confirmed with Víctor 2026-09-01)

1. **Accent stays on-brand:** the existing Fase 4 dark accent `#4D8DFF` is
   kept as-is (already validated, still used for buttons/links/active
   states). A new **brand navy** `#14368B` — the exact color of the new VW
   logo mark — is added as a second brand color, used for gradients, glows,
   and depth (not a replacement for the interactive accent).
2. **Contato has no backend.** The reference's message form is recreated
   visually, but "Enviar" builds a `mailto:` link (prefilled subject/body)
   and opens the visitor's email client via `url_launcher`, instead of
   pretending to submit to a server that doesn't exist.
3. **The photo is a large hero image on Home**, not a small Sobre-page
   avatar (supersedes the earlier decision from the icon/favicon
   conversation). Sobre stays text-only.
4. **The adaptive nav (drawer / Home+Mais / full bar) keeps its exact
   responsive structure from Fase 4** — it's already built and tested
   across breakpoints. Only its visual styling (active-state indicator,
   spacing) changes.

## Design tokens

### Color

`lib/core/theme/app_theme.dart` keeps every existing token unchanged and
adds one:

| Token | Hex | Role |
|---|---|---|
| `_darkBackground` (existing) | `#0D1117` | unchanged |
| `_darkSurface` (existing) | `#161B22` | unchanged |
| `_darkOutline` (existing) | `#30363D` | unchanged |
| `_darkAccent` (existing) | `#4D8DFF` | unchanged — primary interactive color |
| **`_brandNavy` (new)** | **`#14368B`** | new — exact VW logo navy. Mapped to `ColorScheme.tertiary` in both themes. Used for gradients (hero ring, card header strips) and the chevron motif, never for plain text/buttons. |

Light theme's existing restraint (grayscale chrome, `#0969DA` accent
reserved for interactive elements) is preserved deliberately — `tertiary`
is registered there too (same hex, it's a brand constant) but used only for
a subtle low-opacity shadow behind the hero photo, not a vivid glow, to
keep the light theme's considered neutrality.

### Signature element: the brand chevron

The VW mark's own geometric chevron (the overlapping angled strokes visible
in the new logo) becomes a small reusable decorative motif —
`BrandChevronDivider`, a `CustomPainter` drawing two short angled strokes in
`accent`→`tertiary` gradient. Used (a) between major sections on every page
instead of a generic `Divider`, and (b) as a small badge at the
bottom-right of the hero photo ring. This is the one deliberately bold,
repeated element; everything else stays restrained per the frontend-design
guidance ("spend your boldness in one place").

### Typography

No new typefaces. Space Grotesk (headings) / Inter (body) / JetBrains Mono
(tech tags — already used by `TagChip`, kept and leaned into further: job
date ranges in Experiência also switch to mono, since a date range is
data, not prose) stay exactly as Fase 4 defined them. The Home hero name
gets one new, larger display style (`textTheme.headlineLarge` sized up via
a dedicated `heroDisplayStyle` getter on `AppTheme`) so the hero reads as a
real thesis statement rather than the same size as every other page's
`headlineMedium` title.

## New shared widgets (`lib/core/widgets/`)

- **`SectionCard`** — `Container` with `surface` background, `outline`
  border, 12px radius, subtle `boxShadow` (dark theme only — light theme
  relies on the border, no shadow, matching its existing restraint).
  Replaces bare text blocks in Skills/Experiência and the ad hoc `Card` in
  Projetos, so every section-level block looks consistent.
- **`BrandChevronDivider`** — described above.
- **`HeroPhoto`** — circular photo with a gradient ring (`accent` →
  `tertiary`, painted via `Container` decoration) and the chevron badge,
  used once on Home.

## Per-page changes

### Home (hero)

```
Desktop/tablet (Row):                    Mobile (Column, centered):
+---------------------------+            +-------------------+
| Víctor Welter      ( photo)|            |     ( photo )     |
| tagline             ( ring )|           |   Víctor Welter   |
| bio paragraph               |           |      tagline      |
| [Ver Projetos] [Contato]    |           |    bio paragraph  |
+---------------------------+            | [Ver Projetos]     |
                                          | [Entrar em Contato]|
                                          +-------------------+
```

Switches on `context.isMobile` (existing `Breakpoints`/`ResponsiveContext`,
unchanged). Photo: `assets/images/foto-victor-welter.jpg` (new, registered
via a new `flutter: assets:` section in `pubspec.yaml` — the project has no
bundled Flutter assets yet; the résumé PDF is a raw static file under
`web/assets/`, which is a different, still-valid mechanism for a
downloadable document, not an in-app image).

### Sobre

No photo (decision #3). Bio paragraphs move into one `SectionCard`; no
other structural change.

### Skills

Each category becomes a `SectionCard` with a small `Icon` (one per
category, manually mapped — Mobile → `Icons.smartphone`, Backend & Dados →
`Icons.storage`, IA & Automação → `Icons.auto_awesome`, Processos &
Qualidade → `Icons.rule`, Arquitetura & Cloud → `Icons.cloud`) beside the
category name, laid out in a responsive grid: 3 columns desktop, 2 tablet,
1 mobile (via `Wrap`/`LayoutBuilder` sized off `Breakpoints`, no new
dependency).

### Experiência

Each role entry becomes a `SectionCard`. The current role (`Sicredi
Confiança`, "Presente") gets a 4px `accent`-colored left bar — real
information (it's the current job), not decoration. Date ranges render in
`AppTheme.monoTextStyle`.

### Projetos

`_ProjectCard` keeps using `Card` but gains a `SectionCard`-style border/
shadow and a short gradient header strip (`accent`→`tertiary`, 6px tall)
above the title, giving each card a visual anchor point since there are no
real project screenshots to show. Secondary project rows get slightly more
visual weight (a thin `SectionCard`-style container instead of a bare
`InkWell` text row) without becoming full cards.

### Contato

Two `SectionCard`s, `Row` on desktop/tablet, stacked on mobile:

- **Left — message card:** `TextField`s for Nome/Assunto/Mensagem, a
  `FilledButton` "Enviar" that calls `launchUrl(buildMailtoUri(name:
  ..., subject: ..., body: ...))`. `buildMailtoUri` is a **pure function**
  (`lib/features/contact/mailto.dart`) taking the three strings and
  returning a `Uri` — unit-tested directly (exact query-encoding assertions)
  without mocking `url_launcher` or any platform channel, matching how this
  codebase already leaves `launchUrl` itself unmocked/unverified in widget
  tests (resume/contact link taps are verified for real in the Playwright
  smoke test, not in `flutter test`).
- **Right — info card:** the existing email/LinkedIn/GitHub/location links,
  restyled as icon+label rows inside the card instead of bare blue text
  lines.

### Navigation (`AppShell`)

Structure unchanged (drawer on mobile, Home+"Mais" on tablet, full bar on
desktop — all already covered by `app_shell_test.dart`). Visual change
only: the active destination gets a small underline/pill indicator instead
of just bold+accent text, on both mobile drawer and desktop/tablet bar.

## Icon/favicon and photo asset work (rolled into this phase)

Carried over from the earlier icon/photo conversation, now executed as
part of Fase 9 since the photo is needed for the hero:

- Crop `VW LOGO (4).png`'s mark (drop the "SOFTWARE" wordmark) to produce
  `web/favicon.png`, `web/icons/Icon-192.png`, `Icon-512.png` (transparent
  background) and `Icon-maskable-192.png`/`512.png` (mark centered on a
  solid white plate, sized to respect the maskable safe zone).
  Source-of-truth copy kept at `assets/branding/vw-logo.png`.
- `foto_minha.jpeg` → `assets/images/foto-victor-welter.jpg`, registered in
  `pubspec.yaml`, used by `HeroPhoto` via `Image.asset` + `BoxFit.cover`
  (no manual cropping of the original needed — `ClipOval` + `BoxFit.cover`
  frames it).
- The 5 loose files in the repo root are removed once processed into their
  real destinations.

## Testing strategy

- Existing widget tests keep passing; each restyled page keeps the same
  text assertions (`find.text(...)`) since content doesn't change, only
  its container widgets.
- New tests: `buildMailtoUri` unit tests (exact `Uri` output for a few
  input combinations, including special characters needing encoding);
  `HeroPhoto`/`SectionCard` presence assertions (`find.byType`) in
  `home_page_test.dart`/the pages that use them; `BrandChevronDivider`
  needs no dedicated test (pure decoration, no logic).
- `tool/smoke_test/smoke_test.js` gets one addition: fill and submit the
  Contato form, and assert a `mailto:` navigation was attempted (Playwright
  can observe this without a real mail client via a `page.on('popup')`
  or a request-interception check — exact mechanism decided during
  implementation, since headless Chromium's handling of unregistered
  `mailto:` protocol needs to be verified against the real pinned Chromium
  build first, not assumed).
- Manual real-browser check of all 3 breakpoints (mobile/tablet/desktop)
  for the new hero and card grids, same as Fase 8's precedent.

## Out of scope (this phase)

- Formação, Currículo pages are not restyled beyond whatever
  `SectionCard`/typography changes apply globally — no bespoke redesign
  budgeted for them, since they're already simple and not called out by
  Víctor's brief.
- No footer is added (the reference has one; not requested).
- No animation/motion pass (frontend-design guidance: motion should serve
  the subject deliberately, not be added by default — not part of this
  brief; can be proposed as a future phase if wanted).
- `web/manifest.json`'s stale `"description": "A new Flutter project."` and
  the `deploy.yml` permissions-scoping nit (both pre-existing, unrelated
  deferred items noted in the Fase 8 QA report) are not touched here.
