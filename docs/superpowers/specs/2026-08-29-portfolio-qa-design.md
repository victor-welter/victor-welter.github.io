# Portfolio Fase 8 (QA) — Quality Assurance Design

## Context

Fases 3 (Fundação), 4 (Design), and 5 (Conteúdo) are complete and live at
victor-welter.github.io. Every page has real content, the visual identity is
final, and CI/CD deploys on push to `main`. Fase 6 (Projetos) never needed a
separate phase — the foundation spec's original scope for it ("project cards
content and layout details") was fully absorbed into Fase 5's Projetos task.
Fase 7 was folded into Fase 3 earlier in the project. Fase 8 (QA) is the last
phase on the original roadmap, originally scoped in the Fase 3 spec as
"cross-browser, accessibility audit, Lighthouse."

**Why this phase matters beyond a generic QA checklist:** this project has
already shipped two bugs that were invisible to `flutter analyze` and
`flutter test` but broke the site for every real visitor — Fase 3's blank
page (a stale bootstrap API call) and Fase 4's nav-label color bug. Both were
only caught because someone happened to drive the built app with a real
headless browser during that phase's own ad-hoc verification. Nothing
_structural_ stops a future change from reintroducing either failure mode
silently. Fase 8's second half exists to close that gap permanently, not just
to produce one more one-time report.

## Goal

1. Run a real cross-browser + accessibility audit against the live site,
   fix what's reasonably fixable.
2. Run Lighthouse, fix actionable findings, and explicitly document the
   score ceiling that this project's architecture (pure Flutter Web,
   CanvasKit renderer) already accepted back in Fase 1 — as a recorded
   trade-off, not a bug to chase.
3. Fix the one already-known content bug carried over from Fase 3/4: the
   404 page renders outside `AppShell` and has no nav.
4. Add a permanent, lightweight browser-based smoke test to the CI deploy
   pipeline, so a future blank-page- or broken-deep-link-class bug fails the
   build instead of reaching production unnoticed.

## Non-goals

Explicitly out of scope for this phase, by decision:

- WCAG color-contrast audit, keyboard-navigation audit, or an automated
  axe-core scan. The accessibility check in this phase is scoped to one
  specific, already-known gap: whether Flutter's semantics tree correctly
  exposes each page's real content to assistive tech at all (see
  Accessibility Audit below), not a general WCAG conformance pass.
- `web/manifest.json`'s leftover default `"description"` field and scoping
  `deploy.yml`'s `pages`/`id-token` permissions to just the deploy job —
  both real, both deferred, but kept out of this phase's scope on purpose.
- Chasing Lighthouse SEO/Accessibility scores past what CanvasKit rendering
  allows. Flutter Web paints text as canvas pixels, not crawlable/inspectable
  DOM, by design — Fase 1's Auditoria already chose this trade-off knowingly
  ("traffic comes from direct links, not organic search"). This phase
  documents the resulting ceiling; it does not attempt to re-architect the
  renderer to chase a higher score.
- A full E2E suite covering every interaction on every page. The smoke gate
  below is deliberately narrow — it exists to catch "the site is silently
  broken," not to replace `flutter test`'s widget-level coverage.
- BarberApp and the Bee Visit Tracking & Counting repo's public/private
  status — both still blocked on information only Víctor can provide,
  unrelated to QA.

## Architecture: one tool, two uses

Rather than writing a throwaway script for the one-time audit and a
separate one for the permanent CI gate, this phase builds a single Node/
Playwright tool, checked into the repo, that both use:

**`tool/smoke_test/`** (new directory):
- `package.json` and a committed `package-lock.json` — pins `playwright` as
  the only dependency, so CI can use `npm ci` for a fast, deterministic
  install.
- `serve.js` — a small static file server that replays GitHub Pages' real
  `index.html` → `404.html` SPA-fallback behavior (serves the matching file
  with a genuine HTTP 404 status for any unmatched path, 200 for real
  files) — the same technique proven correct against the live site during
  Fase 5's Task 11 verification.
- `smoke_test.js` — takes `--dir <build/web path>` (or `--url <base>` to
  target an already-deployed site directly, used for the one-time live
  audit) and `--browser chromium|firefox|webkit` (default `chromium`).
  For each of the 8 routes (`/`, `/sobre`, `/experiencia`, `/formacao`,
  `/skills`, `/projetos`, `/curriculo`, `/contato`):
  - Navigates with a real path URL (never a `#/...` hash fragment — Path
    URL Strategy means hash fragments are inert, a lesson learned the hard
    way during Fase 5's own verification).
  - Dispatches a synthetic click on Flutter's `flt-semantics-placeholder`
    node to enable the accessibility tree (Flutter's CanvasKit renderer
    paints to canvas and does not expose real text/buttons to Playwright's
    `getByText` or automated assistive-tech queries otherwise).
  - Asserts the page's known real content string is present (doubles as
    the accessibility check: if semantics don't expose it, the assertion
    fails the same way whether the cause is a rendering bug or a semantics
    gap).
  - Records any unexpected `console` (`type() === 'error'`) or `pageerror`
    event. The known, accepted GitHub Pages "deep link returns HTTP 404
    status" console message is filtered out by matching the specific
    "Failed to load resource: 404" text tied to the top-level document
    request — any other console error fails the run.
  - On the `/curriculo` route, confirms the résumé PDF link resolves and
    is servable (via a `download` event listener, not a popup wait —
    Chromium intercepts direct PDF navigation as a download rather than a
    viewable tab, confirmed during Fase 5).
  - Confirms the theme toggle button switches the rendered background
    color.
  - On any failure, saves a screenshot to `smoke-failures/<route>.png`.
  - Exits non-zero if any check failed.

This tool is the only new committed artifact from this phase besides the
`NotFoundPage` fix and the `deploy.yml` change.

## The one-time audit (run manually this phase)

1. **Cross-browser (Chromium, Firefox, WebKit):** run
   `node smoke_test.js --url https://victor-welter.github.io --browser <engine>`
   for each of the three engines against the live production site. Fix any
   engine-specific rendering or console-error finding.
2. **Responsive/nav manual pass:** at mobile (<600px), tablet (600–1024px),
   and desktop (>1024px) widths, manually drive the nav (drawer, "Mais"
   overflow menu, full bar respectively — the three distinct nav
   renderings `AppShell` has by breakpoint) and confirm every destination
   is reachable and correctly highlights as active in each mode.
3. **Accessibility (semantics-tree correctness only):** already covered by
   the smoke tool's per-page assertions above, run across all three
   engines. No separate contrast/keyboard/axe-core pass.
4. **Lighthouse:** `npx lighthouse https://victor-welter.github.io --output
   json,html` (repeat for at least one deep-linked route, to capture
   whether the 404-status quirk affects Lighthouse's own crawl). Record
   Performance/Accessibility/Best-Practices/SEO scores. Fix anything
   actionable that doesn't require changing the rendering architecture.
   Document the SEO/Accessibility ceiling explicitly in the final report
   (see Deliverable below) so it reads as a known, accepted trade-off.

## Code fix: 404 page has no nav

`lib/app/router.dart`'s `GoRouter` sets `errorBuilder: (context, state) =>
const NotFoundPage()` outside the `ShellRoute`, so a mistyped or broken link
strands the visitor with no way back to the nav. Fix:

```dart
errorBuilder: (context, state) => AppShell(
  currentPath: state.uri.path,
  child: const NotFoundPage(),
),
```

`AppShell` is a plain widget (`currentPath`, `child`) with no dependency on
being reached through the route tree, so this is a safe, minimal change.
Existing `NotFoundPage` content and its "Voltar para a Home" button are
unchanged.

## CI change: permanent smoke gate

Add to `.github/workflows/deploy.yml`'s existing `build` job, after
`flutter build web --release` / the `404.html` copy and before
`upload-pages-artifact`:

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
- run: npm ci
  working-directory: tool/smoke_test
- run: npx playwright install --with-deps chromium
  working-directory: tool/smoke_test
- run: node smoke_test.js --dir ../../build/web --browser chromium
  working-directory: tool/smoke_test
- if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: smoke-test-failures
    path: tool/smoke_test/smoke-failures/
```

Chromium only in CI (the 3-engine sweep is this phase's one-time manual
audit, not a per-deploy cost). A failure here fails the `build` job; since
`deploy` already has `needs: build`, the deploy is blocked automatically —
no new gating logic required elsewhere in the workflow.

## Deliverable

A short QA report at
`docs/superpowers/specs/2026-08-29-portfolio-qa-report.md` recording: the
cross-browser/accessibility findings and fixes, the Lighthouse scores with
the documented CanvasKit ceiling explanation, and confirmation the CI smoke
gate is live (e.g., a link to the first CI run that included it).

## Open Items

None — all scope decisions for this phase were resolved during
brainstorming. BarberApp and the Bee Visit Tracking & Counting repo's
public/private status remain open from Fase 5, unrelated to this phase's
scope.
