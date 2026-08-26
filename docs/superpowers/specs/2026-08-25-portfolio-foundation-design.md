# Portfolio Foundation — Design

Status: Approved by user on 2026-08-25. Ready for implementation planning.

## Context

`victor-welter.github.io` currently contains only the compiled output of a `flutter build web` run from November 2023 (2 commits total, no `pubspec.yaml`, no `lib/`, no CI/CD). The original Dart source is unrecoverable — see the Phase 1 audit findings summarized below. The owner (Victor Welter, a Flutter developer) wants to rebuild this as a professional interactive résumé, keeping Flutter Web as the stack, and has approved a phased process: Audit (done) → Recovery (done, folded into this doc) → **Foundation (this spec)** → Design → Content → Projects → Deployment → QA.

This spec covers only the **Foundation** phase: a working, navigable, responsive, deployable skeleton with placeholder content. Visual identity, real content, and project cards are explicitly out of scope (see Non-goals).

### Audit findings that shape this design
- Recovered: app title string `"Víctor Welter"`, a single named route `"/home"` (confirms the site used Flutter's default Hash URL Strategy), a PT-BR humorous fallback screen tied to `assets/images/no-server.svg`, and a local visit-counter easter egg (`"contagem_acessos"`). None of this is reused as content — it only confirms the old app was simple, had no real backend, and never had its SEO metadata edited (`title: "victor_welter"`, `description: "A new Flutter project."` — the untouched `flutter create` default).
- Unrecoverable: all real Dart source, real bio/project copy, the `pubspec.yaml` dependency list, any CI/CD (none ever existed).
- Confirmed decisions from user: **Path URL Strategy** (clean URLs like `/projetos`, not `/#/projetos`) using the standard GitHub Pages `404.html`-fallback technique; stay **100% Flutter Web** (no hybrid HTML/Jaspr shell); light **and** dark theme from the start; navigation is **separate routes per section** (not a single scrolling page); include a minimal GitHub Actions deploy pipeline in this phase so path-based routing can be validated on real GitHub Pages, not just locally.

## Goals

1. A new Flutter Web project with a clean, sustainable folder structure.
2. Working navigation between all planned sections as real, clean URLs (no `#`), surviving a hard refresh or direct link on GitHub Pages.
3. Light and dark theme, centrally defined, user-toggleable and persisted across visits.
4. A responsive app shell: top navigation on tablet/desktop, drawer (hamburger) on mobile — built as reusable structure now so Phase 4 (Design) only needs to swap visual tokens, not rebuild layout.
5. An automated GitHub Actions pipeline that builds and deploys to GitHub Pages on push to `main`, replacing the current manual "build web, commit binaries" workflow.
6. The repository stops tracking build output; `main` holds source only.
7. Minimal smoke tests proving the skeleton actually boots and routes.

## Non-goals (explicitly deferred)

- Final color palette, typography, spacing scale, motion language → Phase 4 (Design).
- Real bio/experience/education/skills copy → Phase 5 (Content). Placeholder pages use `PLACEHOLDER:`/`TODO:` markers only.
- Project cards content and layout details → Phase 6 (Projects).
- Full QA pass (cross-browser, accessibility audit, Lighthouse) → Phase 8 (QA).
- Any state management library, animation package, or font package — not justified yet at this phase's scope.

## Architecture

New Flutter project, package name `portfolio` (rename is cheap later if the user wants something else).

```
lib/
  app/                    # App entrypoint widget: MaterialApp.router, theme wiring, GoRouter config
  core/
    theme/                # ThemeData (light/dark), ThemeController (ChangeNotifier), persistence
    layout/               # Breakpoints constants + BuildContext extensions (isMobile/isTablet/isDesktop)
    widgets/              # AppShell (persistent nav + footer), reusable section wrapper widgets
  features/
    home/
    about/
    experience/
    education/
    skills/
    projects/
    resume/
    contact/
      <feature>_page.dart     # the route's screen
      <feature>_data.dart     # static placeholder data (const/final Dart values), PLACEHOLDER-marked
```

Each feature is presentation + static data only — no domain/data/repository layering, since content is static Dart, not fetched from any API at this stage. If a future phase adds a real dynamic data source (e.g., pulling pinned repos from the GitHub REST API for the Projects section), that feature can grow a thin data layer then; introducing it now would be speculative.

## Routing & URL strategy

- `go_router` (official Flutter-team-maintained package) with a single `ShellRoute` wrapping every top-level page in `AppShell`, so the nav bar/footer persist across navigation without rebuilding.
- Routes: `/`, `/sobre`, `/experiencia`, `/formacao`, `/skills`, `/projetos`, `/curriculo`, `/contato`, plus a catch-all 404 page (professional tone — no reuse of the old joke copy).
- `usePathUrlStrategy()` (from `flutter_web_plugins`) called in `main.dart` before `runApp`, removing the `#` from URLs.
- GitHub Pages fallback: the build step copies `build/web/index.html` to `build/web/404.html`. This is the standard, documented technique for path-based SPA routing on static hosts without server-side rewrite rules (used the same way by React Router/Vue Router projects on GitHub Pages) — not a hack specific to this project.
- `base href="/"` stays `/` since this is a user/org GitHub Pages site served at the domain root, not a project-pages subpath — no base-href complication.

## Theming

- `ThemeData` for light and dark defined centrally in `core/theme/`, built from a single neutral seed color for now (`ColorScheme.fromSeed`) — the actual palette is a Phase 4 decision.
- `ThemeController extends ChangeNotifier` exposes the current `ThemeMode` and a toggle method; no provider/riverpod — a single controller passed via `ListenableBuilder`/`InheritedNotifier` is enough for one piece of app-wide state.
- Persistence via `shared_preferences` (official Flutter Favorite plugin, actively maintained, works on web via `localStorage`). Justification per the project's dependency rule: hand-rolling `dart:html` `window.localStorage` access would work too, but `shared_preferences` gives a tested, documented, platform-agnostic API for a single stored value, at negligible size/maintenance cost — reasonable to take here instead of reinventing it.
- Default `ThemeMode` on first visit: `ThemeMode.system`.

## Responsiveness

- Breakpoint constants (e.g. `mobile < 600`, `tablet 600–1024`, `desktop > 1024`) plus `BuildContext` extensions (`context.isMobile`, `.isTablet`, `.isDesktop`) built on `MediaQuery.sizeOf` — no `responsive_framework` or similar package; plain Flutter is sufficient for this need.
- `AppShell` picks the nav pattern based on those breakpoints: a horizontal nav bar for tablet/desktop, a `Drawer` opened from a hamburger `IconButton` for mobile.

## CI/CD & repository hygiene

- New GitHub Actions workflow (`.github/workflows/deploy.yml`), triggered on push to `main`:
  1. Checkout, setup Flutter (stable channel, e.g. via `subosito/flutter-action`).
  2. `flutter pub get`
  3. `flutter analyze`
  4. `flutter test`
  5. `flutter build web --release`
  6. `cp build/web/index.html build/web/404.html`
  7. Deploy via the official `actions/deploy-pages` action (GitHub-maintained, no third-party action needed).
- **Manual step required from the user, outside this tool's reach**: in the repo's Settings → Pages, change the source from "Deploy from a branch" to "GitHub Actions". Nothing in this plan can flip that toggle via git.
- The repository stops tracking `flutter build web` output. The build artifacts currently committed at the repo root (`main.dart.js`, `canvaskit/`, `assets/`, `icons/`, `flutter_service_worker.js`, `manifest.json`, `version.json`, `favicon.png`, `.last_build_id`) will be removed from tracking once the pipeline is verified working, since GitHub Actions will build and publish them without ever committing them to `main`.

## Testing

- One smoke widget test: the app boots and the `/` route renders.
- One routing test: navigating to `/projetos` (and at least one other route) renders the expected placeholder page.
- Deeper test coverage (accessibility, visual regression, cross-browser) is Phase 8's job, not this phase's.

## Dependencies introduced in this phase

| Package | Why | Alternative considered |
|---|---|---|
| `go_router` | Official, declarative routing with path-strategy + shell/nested-route support out of the box | Hand-rolled `Router`/`RouterDelegate` — much more code for the same outcome, no real benefit here |
| `shared_preferences` | Official plugin to persist the theme choice across visits, web-compatible | Manual `dart:html` `localStorage` calls — works, but reinvents a solved, well-maintained wheel for one stored value |

No state management, animation, or font packages are introduced in this phase.

## Open questions / risks

- None blocking. The one manual action item (switching the GitHub Pages source to "GitHub Actions") is called out above and will be confirmed with the user again at implementation time, since it changes how the live site gets published.
