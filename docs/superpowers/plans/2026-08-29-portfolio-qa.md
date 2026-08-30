# Portfolio Fase 8 (QA) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Run a real cross-browser + accessibility + Lighthouse audit of the live site, fix what's found (including the already-known 404-page-has-no-nav bug), and add a permanent headless-browser smoke test to the CI deploy pipeline so a future blank-page/nav-color-class bug can't reach production unnoticed again.

**Architecture:** One Node/Playwright tool at `tool/smoke_test/` serves both the one-time manual audit and the permanent CI gate. It has two files: `serve.js` (a static server that replays GitHub Pages' `index.html`→`404.html` SPA-fallback behavior) and `smoke_test.js` (drives a real browser through all 8 routes, checking rendered content, console errors, the theme toggle, and the résumé PDF download). It accepts `--dir <path>` (serve a local build) or `--url <base>` (hit an already-deployed site directly) and `--browser chromium|firefox|webkit`.

**Tech Stack:** Node.js + `playwright` (new, isolated in `tool/smoke_test/`, does not touch `pubspec.yaml`). Flutter/Dart unchanged except for one router fix.

Full context and rationale: `docs/superpowers/specs/2026-08-29-portfolio-qa-design.md`.

## Global Constraints

- Node tool code (`tool/smoke_test/*.js`) uses English identifiers/comments, same convention as the Dart codebase. Any Portuguese strings in it are copied verbatim from the app's own real content — never invented.
- Non-goals (do not do these in this phase): WCAG color-contrast audit, keyboard-navigation audit, automated axe-core scan, fixing `web/manifest.json`'s default description, scoping `deploy.yml`'s `pages`/`id-token` permissions, or attempting to raise Lighthouse SEO/Accessibility scores past what CanvasKit rendering allows — that ceiling gets documented as an accepted trade-off, not chased.
- CI is pinned to Flutter `3.47.2` (`deploy.yml`, see commit `8df680b`). Verify `flutter build web --release` locally before relying on its output for any smoke-test task.
- `tool/smoke_test/` pins `playwright` as its only dependency. Commit its `package-lock.json`.
- Every git commit must be authored solely as the repository owner. Never add a `Co-Authored-By` line or any AI/tool-attribution trailer to a commit message.
- This phase's final task pushes to `main`, which triggers a real deploy. Do not push without explicit user confirmation immediately before doing so — same production-action gate Fase 3/4/5 used for their deploys.
- Do not touch `AppTheme`, routing structure, breakpoints, page content, or `pubspec.yaml` dependencies — the one exception is the single-line `NotFoundPage`/`errorBuilder` fix in Task 5, which is explicitly in scope.

---

### Task 1: Scaffold the smoke-test tool

**Files:**
- Create: `tool/smoke_test/package.json`
- Create: `tool/smoke_test/.gitignore`
- Create (generated): `tool/smoke_test/package-lock.json`

**Interfaces:**
- Consumes: nothing.
- Produces: an npm project at `tool/smoke_test/` with `playwright` installed. Consumed by every later task in this plan.

- [ ] **Step 1: Create the directory and package.json**

Create `tool/smoke_test/package.json`:

```json
{
  "name": "portfolio-smoke-test",
  "version": "1.0.0",
  "private": true,
  "description": "Headless-browser smoke test for victor-welter.github.io — verifies every route renders real content, has no unexpected console errors, and the theme toggle/résumé download work.",
  "scripts": {
    "test": "node smoke_test.js"
  },
  "dependencies": {
    "playwright": "^1.48.0"
  }
}
```

- [ ] **Step 2: Add a .gitignore for this tool**

Create `tool/smoke_test/.gitignore`:

```
node_modules/
smoke-failures/
```

- [ ] **Step 3: Install dependencies**

Run (from `tool/smoke_test/`):
```bash
cd tool/smoke_test
npm install
```
Expected: `node_modules/` and `package-lock.json` are created, no errors.

- [ ] **Step 4: Install the Chromium browser for Playwright**

Run:
```bash
npx playwright install --with-deps chromium
```
Expected: completes without error (installs the Chromium binary Playwright drives).

- [ ] **Step 5: Commit**

```bash
git add tool/smoke_test/package.json tool/smoke_test/package-lock.json tool/smoke_test/.gitignore
git commit -m "$(cat <<'EOF'
Scaffold tool/smoke_test/, a Playwright smoke-test tool

First step of Fase 8 (QA): a small Node tool that will drive the
built site through a real browser to catch the "passes flutter test
but breaks in production" class of bug this project has already
shipped twice (Fase 3's blank page, Fase 4's nav color bug).
EOF
)"
```

---

### Task 2: Implement the SPA-fallback static server

**Files:**
- Create: `tool/smoke_test/serve.js`

**Interfaces:**
- Consumes: nothing.
- Produces: `startServer(rootDir: string, port: number): Promise<http.Server>` — resolves once listening; the returned server's `.address().port` gives the actual bound port (pass `port: 0` for an OS-assigned free port). Consumed by Task 3's `smoke_test.js`.

- [ ] **Step 1: Implement serve.js**

Create `tool/smoke_test/serve.js`:

```js
'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');

const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.pdf': 'application/pdf',
};

function serveFile(res, filePath, status) {
  const ext = path.extname(filePath);
  res.writeHead(status, {
    'Content-Type': MIME_TYPES[ext] || 'application/octet-stream',
  });
  fs.createReadStream(filePath).pipe(res);
}

/**
 * Replays GitHub Pages' index.html -> 404.html SPA-fallback behavior:
 * real files are served as-is (200); any other path is served the
 * directory's 404.html with a genuine HTTP 404 status, so a deep link
 * still gets real app content just like on the live site.
 */
function createSpaServer(rootDir) {
  return http.createServer((req, res) => {
    let urlPath = decodeURIComponent(req.url.split('?')[0]);
    if (urlPath === '/' || urlPath === '') urlPath = '/index.html';
    const filePath = path.join(rootDir, urlPath);

    fs.stat(filePath, (err, stat) => {
      if (!err && stat.isFile()) {
        serveFile(res, filePath, 200);
      } else {
        serveFile(res, path.join(rootDir, '404.html'), 404);
      }
    });
  });
}

function startServer(rootDir, port) {
  return new Promise((resolve, reject) => {
    const server = createSpaServer(rootDir);
    server.on('error', reject);
    server.listen(port, '127.0.0.1', () => resolve(server));
  });
}

module.exports = { createSpaServer, startServer };
```

- [ ] **Step 2: Build a real site and prepare its 404.html**

Run (from the repo root):
```bash
flutter build web --release
cp build/web/index.html build/web/404.html
```
Expected: `build/web/` now contains both `index.html` and `404.html` (identical content), matching what `deploy.yml` does in CI.

- [ ] **Step 3: Verify the server serves real files and falls back correctly**

Run (from `tool/smoke_test/`):
```bash
node -e "
const { startServer } = require('./serve.js');
const path = require('path');
const http = require('http');

(async () => {
  const server = await startServer(path.resolve('../../build/web'), 0);
  const port = server.address().port;

  const get = (p) => new Promise((resolve) => {
    http.get('http://127.0.0.1:' + port + p, (res) => resolve(res.statusCode));
  });

  console.log('root:', await get('/'));
  console.log('deep link /sobre:', await get('/sobre'));

  server.close();
})();
"
```
Expected output:
```
root: 200
deep link /sobre: 404
```
(The `404` for `/sobre` is correct and expected — it matches real GitHub Pages behavior for the fallback trick, not a bug.)

- [ ] **Step 4: Commit**

```bash
git add tool/smoke_test/serve.js
git commit -m "$(cat <<'EOF'
Add the SPA-fallback static server used by the smoke test

Replays GitHub Pages' index.html -> 404.html deep-link fallback
locally (real content, genuine HTTP 404 status) so the smoke test
can verify deep links the same way they actually behave in
production, not against a plain static server that would 404
every non-root route with no content at all.
EOF
)"
```

---

### Task 3: Implement the core smoke_test.js (page content + console errors)

**Files:**
- Create: `tool/smoke_test/smoke_test.js`

**Interfaces:**
- Consumes: `startServer` (Task 2, `tool/smoke_test/serve.js`).
- Produces: a CLI — `node smoke_test.js --dir <path> --browser <name>` or `node smoke_test.js --url <base> --browser <name>`. Exits `0` on success, `1` with a printed failure list otherwise. Task 4 extends this same file; Task 6 (CI) and Task 7 (live audit) both invoke it as-is.

- [ ] **Step 1: Implement the core script**

Create `tool/smoke_test/smoke_test.js`:

```js
#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { chromium, firefox, webkit } = require('playwright');
const { startServer } = require('./serve');

const ENGINES = { chromium, firefox, webkit };

const ROUTES = [
  { path: '/', expectText: 'Víctor Welter' },
  { path: '/sobre', expectText: 'Víctor Vinícius Welter' },
  { path: '/experiencia', expectText: 'Experiência anterior' },
  { path: '/formacao', expectText: 'Bacharelado, Engenharia de Computação' },
  { path: '/skills', expectText: 'Arquitetura & Cloud' },
  { path: '/projetos', expectText: 'Bee Visit Tracking & Counting' },
  { path: '/curriculo', expectText: 'Ver Currículo (PDF)' },
  { path: '/contato', expectText: 'victorwelter2003@gmail.com' },
];

function parseArgs(argv) {
  const args = { browser: 'chromium', dir: null, url: null };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--dir') args.dir = argv[++i];
    else if (argv[i] === '--url') args.url = argv[++i];
    else if (argv[i] === '--browser') args.browser = argv[++i];
  }
  if (!args.dir && !args.url) {
    throw new Error('Must pass --dir <build/web path> or --url <base url>');
  }
  if (!ENGINES[args.browser]) {
    throw new Error(
      `Unknown --browser "${args.browser}". Use chromium, firefox, or webkit.`
    );
  }
  return args;
}

/**
 * Flutter's CanvasKit renderer paints everything to a <canvas> — it does
 * not expose real text/buttons to Playwright's getByText/getByRole (or to
 * any assistive tech) until the accessibility/semantics tree is turned on.
 * Clicking this placeholder node is how a real screen-reader user would
 * trigger it; a plain Playwright .click() fails because the node is a 1x1
 * off-screen element, so we dispatch the event directly instead.
 */
async function enableSemantics(page) {
  await page.evaluate(() => {
    const el = document.querySelector('flt-semantics-placeholder');
    if (el) el.dispatchEvent(new MouseEvent('click', { bubbles: true }));
  });
  await page.waitForTimeout(800);
}

function screenshotNameFor(routePath) {
  return routePath === '/' ? 'home' : routePath.replace(/\//g, '_');
}

async function runChecks(baseUrl, browserName) {
  const browser = await ENGINES[browserName].launch();
  const context = await browser.newContext({ acceptDownloads: true });
  const page = await context.newPage();
  await page.setViewportSize({ width: 1300, height: 900 });

  const failures = [];
  let currentRoutePath = null;

  page.on('response', (res) => {
    if (
      res.status() === 404 &&
      currentRoutePath &&
      res.url() === baseUrl + currentRoutePath
    ) {
      // Expected: GitHub Pages' index.html -> 404.html SPA-fallback trick
      // serves real content for deep links with a genuine HTTP 404 status.
      return;
    }
    if (!res.ok()) {
      failures.push(
        `[${currentRoutePath}] unexpected HTTP ${res.status()} for ${res.url()}`
      );
    }
  });

  page.on('console', (msg) => {
    if (msg.type() !== 'error') return;
    const isExpectedDocument404Echo =
      currentRoutePath &&
      currentRoutePath !== '/' &&
      msg.text().includes('404');
    if (isExpectedDocument404Echo) return;
    failures.push(`[${currentRoutePath}] console error: ${msg.text()}`);
  });

  page.on('pageerror', (err) => {
    failures.push(`[${currentRoutePath}] pageerror: ${err.message}`);
  });

  let first = true;
  for (const route of ROUTES) {
    currentRoutePath = route.path;
    await page.goto(baseUrl + route.path, { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(first ? 5000 : 3000);
    first = false;
    await enableSemantics(page);

    const found = await page.getByText(route.expectText, { exact: false }).count();
    if (found === 0) {
      failures.push(
        `[${route.path}] expected text not found: "${route.expectText}"`
      );
      const screenshotDir = path.join(__dirname, 'smoke-failures');
      fs.mkdirSync(screenshotDir, { recursive: true });
      await page.screenshot({
        path: path.join(screenshotDir, `${screenshotNameFor(route.path)}.png`),
      });
    } else {
      console.log(`[${browserName}] ${route.path}: OK`);
    }
  }

  await browser.close();
  return failures;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  let baseUrl = args.url;
  let server = null;

  if (args.dir) {
    server = await startServer(path.resolve(args.dir), 0);
    baseUrl = `http://127.0.0.1:${server.address().port}`;
  }

  console.log(`Running smoke test against ${baseUrl} with ${args.browser}`);
  const failures = await runChecks(baseUrl, args.browser);

  if (server) server.close();

  if (failures.length > 0) {
    console.error('\nSMOKE TEST FAILED:');
    failures.forEach((f) => console.error('  - ' + f));
    process.exit(1);
  }

  console.log('\nAll smoke checks passed.');
}

main().catch((err) => {
  console.error('Smoke test crashed:', err);
  process.exit(1);
});
```

- [ ] **Step 2: Run it against the local build**

Run (from `tool/smoke_test/`, reusing the `build/web` from Task 2 Step 2):
```bash
node smoke_test.js --dir ../../build/web --browser chromium
```
Expected: each of the 8 routes prints `OK`, ending with `All smoke checks passed.` and exit code `0`.

- [ ] **Step 3: Verify it actually fails on a real problem**

Temporarily point it at an empty directory to confirm the tool reports failure correctly rather than silently passing:
```bash
mkdir -p /tmp/empty-site && cp ../../build/web/404.html /tmp/empty-site/404.html
node smoke_test.js --dir /tmp/empty-site --browser chromium
```
Expected: exits non-zero, prints `SMOKE TEST FAILED:` with entries for every route (since `/tmp/empty-site` has no `index.html`, every route falls back to the same 404 content, which won't contain any of the expected text). Clean up: `rm -rf /tmp/empty-site`.

- [ ] **Step 4: Commit**

```bash
git add tool/smoke_test/smoke_test.js
git commit -m "$(cat <<'EOF'
Add core smoke_test.js: content + console-error checks

Drives a real browser through all 8 routes with the accessibility
tree enabled (the CanvasKit lesson from Fase 5), using real path
URLs (the Path-URL-Strategy lesson from the same phase), and fails
on any unexpected console/page error or missing content.
EOF
)"
```

---

### Task 4: Add the résumé-download and theme-toggle checks

**Files:**
- Modify: `tool/smoke_test/smoke_test.js`

**Interfaces:**
- Consumes: same as Task 3.
- Produces: same CLI, now also checking the `/curriculo` PDF download and the theme toggle. Not consumed by any later task's code, only invoked.

- [ ] **Step 1: Replace the full contents of smoke_test.js**

Replace the full contents of `tool/smoke_test/smoke_test.js`:

```js
#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { chromium, firefox, webkit } = require('playwright');
const { startServer } = require('./serve');

const ENGINES = { chromium, firefox, webkit };

const ROUTES = [
  { path: '/', expectText: 'Víctor Welter' },
  { path: '/sobre', expectText: 'Víctor Vinícius Welter' },
  { path: '/experiencia', expectText: 'Experiência anterior' },
  { path: '/formacao', expectText: 'Bacharelado, Engenharia de Computação' },
  { path: '/skills', expectText: 'Arquitetura & Cloud' },
  { path: '/projetos', expectText: 'Bee Visit Tracking & Counting' },
  { path: '/curriculo', expectText: 'Ver Currículo (PDF)' },
  { path: '/contato', expectText: 'victorwelter2003@gmail.com' },
];

function parseArgs(argv) {
  const args = { browser: 'chromium', dir: null, url: null };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--dir') args.dir = argv[++i];
    else if (argv[i] === '--url') args.url = argv[++i];
    else if (argv[i] === '--browser') args.browser = argv[++i];
  }
  if (!args.dir && !args.url) {
    throw new Error('Must pass --dir <build/web path> or --url <base url>');
  }
  if (!ENGINES[args.browser]) {
    throw new Error(
      `Unknown --browser "${args.browser}". Use chromium, firefox, or webkit.`
    );
  }
  return args;
}

/**
 * Flutter's CanvasKit renderer paints everything to a <canvas> — it does
 * not expose real text/buttons to Playwright's getByText/getByRole (or to
 * any assistive tech) until the accessibility/semantics tree is turned on.
 * Clicking this placeholder node is how a real screen-reader user would
 * trigger it; a plain Playwright .click() fails because the node is a 1x1
 * off-screen element, so we dispatch the event directly instead.
 */
async function enableSemantics(page) {
  await page.evaluate(() => {
    const el = document.querySelector('flt-semantics-placeholder');
    if (el) el.dispatchEvent(new MouseEvent('click', { bubbles: true }));
  });
  await page.waitForTimeout(800);
}

function screenshotNameFor(routePath) {
  return routePath === '/' ? 'home' : routePath.replace(/\//g, '_');
}

/**
 * Headless Chromium (and the other engines) intercept direct navigation to
 * a PDF URL as a download rather than opening a viewable tab, so we listen
 * for the download event instead of a popup — confirmed during Fase 5.
 */
async function checkResumeDownload(page) {
  const downloadPromise = page.waitForEvent('download', { timeout: 10000 });
  await page.getByText('Ver Currículo (PDF)', { exact: false }).click();
  const download = await downloadPromise;
  const url = download.url();
  if (!url.endsWith('assets/documents/curriculo-victor-welter.pdf')) {
    throw new Error(`résumé download URL looks wrong: ${url}`);
  }
}

/**
 * The toggle button's icon and the theme it applies are both canvas-painted,
 * so there is no DOM property to diff — a before/after screenshot comparison
 * is the reliable signal (confirmed empirically against the live site).
 */
async function checkThemeToggle(page) {
  const before = await page.screenshot();
  const toggle = page.getByRole('button', { name: 'Alternar tema' });
  if ((await toggle.count()) === 0) {
    throw new Error('theme toggle button not found in the semantics tree');
  }
  await toggle.click();
  await page.waitForTimeout(800);
  const after = await page.screenshot();
  if (Buffer.compare(before, after) === 0) {
    throw new Error('clicking the theme toggle produced no visible change');
  }
}

async function runChecks(baseUrl, browserName) {
  const browser = await ENGINES[browserName].launch();
  const context = await browser.newContext({ acceptDownloads: true });
  const page = await context.newPage();
  await page.setViewportSize({ width: 1300, height: 900 });

  const failures = [];
  let currentRoutePath = null;

  page.on('response', (res) => {
    if (
      res.status() === 404 &&
      currentRoutePath &&
      res.url() === baseUrl + currentRoutePath
    ) {
      // Expected: GitHub Pages' index.html -> 404.html SPA-fallback trick
      // serves real content for deep links with a genuine HTTP 404 status.
      return;
    }
    if (!res.ok()) {
      failures.push(
        `[${currentRoutePath}] unexpected HTTP ${res.status()} for ${res.url()}`
      );
    }
  });

  page.on('console', (msg) => {
    if (msg.type() !== 'error') return;
    const isExpectedDocument404Echo =
      currentRoutePath &&
      currentRoutePath !== '/' &&
      msg.text().includes('404');
    if (isExpectedDocument404Echo) return;
    failures.push(`[${currentRoutePath}] console error: ${msg.text()}`);
  });

  page.on('pageerror', (err) => {
    failures.push(`[${currentRoutePath}] pageerror: ${err.message}`);
  });

  let first = true;
  for (const route of ROUTES) {
    currentRoutePath = route.path;
    await page.goto(baseUrl + route.path, { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(first ? 5000 : 3000);
    first = false;
    await enableSemantics(page);

    const found = await page.getByText(route.expectText, { exact: false }).count();
    if (found === 0) {
      failures.push(
        `[${route.path}] expected text not found: "${route.expectText}"`
      );
      const screenshotDir = path.join(__dirname, 'smoke-failures');
      fs.mkdirSync(screenshotDir, { recursive: true });
      await page.screenshot({
        path: path.join(screenshotDir, `${screenshotNameFor(route.path)}.png`),
      });
    } else {
      console.log(`[${browserName}] ${route.path}: OK`);
    }
  }

  currentRoutePath = '/curriculo';
  try {
    await page.goto(baseUrl + '/curriculo', { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(3000);
    await enableSemantics(page);
    await checkResumeDownload(page);
    console.log(`[${browserName}] résumé PDF download: OK`);
  } catch (err) {
    failures.push(`résumé PDF download check failed: ${err.message}`);
  }

  currentRoutePath = '/';
  try {
    await page.goto(baseUrl + '/', { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(3000);
    await enableSemantics(page);
    await checkThemeToggle(page);
    console.log(`[${browserName}] theme toggle: OK`);
  } catch (err) {
    failures.push(`theme toggle check failed: ${err.message}`);
  }

  await browser.close();
  return failures;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  let baseUrl = args.url;
  let server = null;

  if (args.dir) {
    server = await startServer(path.resolve(args.dir), 0);
    baseUrl = `http://127.0.0.1:${server.address().port}`;
  }

  console.log(`Running smoke test against ${baseUrl} with ${args.browser}`);
  const failures = await runChecks(baseUrl, args.browser);

  if (server) server.close();

  if (failures.length > 0) {
    console.error('\nSMOKE TEST FAILED:');
    failures.forEach((f) => console.error('  - ' + f));
    process.exit(1);
  }

  console.log('\nAll smoke checks passed.');
}

main().catch((err) => {
  console.error('Smoke test crashed:', err);
  process.exit(1);
});
```

- [ ] **Step 2: Run it against the local build**

Run (from `tool/smoke_test/`):
```bash
node smoke_test.js --dir ../../build/web --browser chromium
```
Expected: all 8 routes `OK`, plus `résumé PDF download: OK` and `theme toggle: OK`, ending with `All smoke checks passed.`

- [ ] **Step 3: Commit**

```bash
git add tool/smoke_test/smoke_test.js
git commit -m "$(cat <<'EOF'
Add résumé-download and theme-toggle checks to the smoke test

Completes the smoke tool's checklist: the PDF link resolves to the
correct asset (via a download-event listener, since headless
browsers intercept direct PDF navigation as a download rather than
a viewable tab), and the theme toggle visibly changes the rendered
page (via a before/after screenshot diff, since both the icon and
the applied theme are canvas-painted with no DOM property to read).
EOF
)"
```

---

### Task 5: Fix the 404 page rendering outside AppShell

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `test/app/router_test.dart`

**Interfaces:**
- Consumes: `AppShell` (existing, `lib/core/widgets/app_shell.dart`).
- Produces: no public API change.

- [ ] **Step 1: Extend the failing test**

In `test/app/router_test.dart`, replace the `'shows the not-found page for an unknown route'` test:

```dart
  testWidgets(
    'shows the not-found page for an unknown route, with the nav still available',
    (tester) async {
      final app = await buildApp();
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      app.router.go('/rota-que-nao-existe');
      await tester.pumpAndSettle();

      expect(find.text('Página não encontrada'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    },
  );
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/app/router_test.dart`
Expected: FAIL — `find.text('Home')` finds nothing, since `NotFoundPage` currently renders outside `AppShell`.

- [ ] **Step 3: Fix the router**

Replace the full contents of `lib/app/router.dart`:

```dart
import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/about/about_page.dart';
import '../features/contact/contact_page.dart';
import '../features/education/education_page.dart';
import '../features/experience/experience_page.dart';
import '../features/home/home_page.dart';
import '../features/not_found/not_found_page.dart';
import '../features/projects/projects_page.dart';
import '../features/resume/resume_page.dart';
import '../features/skills/skills_page.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => AppShell(
      currentPath: state.uri.path,
      child: const NotFoundPage(),
    ),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/sobre',
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(
            path: '/experiencia',
            builder: (context, state) => const ExperiencePage(),
          ),
          GoRoute(
            path: '/formacao',
            builder: (context, state) => const EducationPage(),
          ),
          GoRoute(
            path: '/skills',
            builder: (context, state) => const SkillsPage(),
          ),
          GoRoute(
            path: '/projetos',
            builder: (context, state) => const ProjectsPage(),
          ),
          GoRoute(
            path: '/curriculo',
            builder: (context, state) => const ResumePage(),
          ),
          GoRoute(
            path: '/contato',
            builder: (context, state) => const ContactPage(),
          ),
        ],
      ),
    ],
  );
}
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/app/router_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 6: Commit**

```bash
git add lib/app/router.dart test/app/router_test.dart
git commit -m "$(cat <<'EOF'
Fix 404 page rendering outside AppShell

GoRouter's errorBuilder rendered NotFoundPage completely outside the
ShellRoute, so a broken or mistyped link stranded the visitor with
no nav bar back to the rest of the site. AppShell is a plain widget
(currentPath, child) with no dependency on being reached through the
route tree, so wrapping it directly in the errorBuilder is a safe,
minimal fix.
EOF
)"
```

---

### Task 6: Wire the smoke test into the CI deploy pipeline

**Files:**
- Modify: `.github/workflows/deploy.yml`

**Interfaces:**
- Consumes: `tool/smoke_test/smoke_test.js` (Task 4).
- Produces: no public API change — a CI-only change.

- [ ] **Step 1: Add the smoke-test steps to the build job**

Replace the full contents of `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: 3.47.2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build web --release
      - run: cp build/web/index.html build/web/404.html
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
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 2: Validate the new steps locally, from the exact working directory CI will use**

Run (from the repo root):
```bash
flutter build web --release
cp build/web/index.html build/web/404.html
cd tool/smoke_test
npm ci
npx playwright install --with-deps chromium
node smoke_test.js --dir ../../build/web --browser chromium
```
Expected: same as Task 4 Step 2 — all checks `OK`, ending with `All smoke checks passed.` This confirms the relative path (`../../build/web`) and `working-directory` settings used in the YAML are correct before they run inside GitHub Actions.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy.yml
git commit -m "$(cat <<'EOF'
Add a permanent smoke-test gate to the deploy pipeline

Runs tool/smoke_test against the freshly built site (Chromium only,
for CI speed — the 3-engine sweep is this phase's one-time manual
audit, not a per-deploy cost) after the build and before the Pages
artifact upload. A failure here fails the build job, which blocks
the deploy job since it already `needs: build` — no new gating logic
required. On failure, screenshots are uploaded as a workflow
artifact so a future debugging session doesn't have to redo Fase 3's
from-scratch investigation into a blank-page-style bug.
EOF
)"
```

---

### Task 7: Run the one-time cross-browser audit against the live site

**Files:** none (audit only — any findings get fixed in follow-up commits using the normal TDD cycle for the affected file, then this task's own commit records the audit itself).

**Interfaces:** none.

- [ ] **Step 1: Install Firefox and WebKit for Playwright**

Run (from `tool/smoke_test/`):
```bash
npx playwright install firefox webkit
```

- [ ] **Step 2: Run the smoke test against the live site, all three engines**

Run:
```bash
node smoke_test.js --url https://victor-welter.github.io --browser chromium
node smoke_test.js --url https://victor-welter.github.io --browser firefox
node smoke_test.js --url https://victor-welter.github.io --browser webkit
```
Expected: `All smoke checks passed.` for all three.

- [ ] **Step 3: If any engine reports a failure, investigate and fix it**

Use the superpowers:systematic-debugging skill: reproduce the specific failure with that engine, inspect the screenshot in `tool/smoke_test/smoke-failures/`, find the root cause in the affected Dart file, fix it, then re-run that engine's command from Step 2 to confirm before moving on. Commit the fix on its own, in the normal style for whatever file it touches (e.g., a widget file gets `flutter test` run before committing).

- [ ] **Step 4: Record the audit result**

If all three engines passed clean with no fixes needed, commit a short note (no fixes to bundle a message with otherwise):

```bash
git commit --allow-empty -m "$(cat <<'EOF'
Fase 8 QA: cross-browser audit (Chromium, Firefox, WebKit) — clean

Ran tool/smoke_test against https://victor-welter.github.io with
all three Playwright-supported engines. No failures found.
EOF
)"
```

If fixes were needed, skip this empty commit — Step 3's fix commits already document what was found and changed.

---

### Task 8: Manual responsive/nav breakpoint check

**Files:** none (manual visual audit only).

**Interfaces:** none.

- [ ] **Step 1: Screenshot the live site at all three breakpoints**

Run (from `tool/smoke_test/`), against the live site:
```bash
node -e "
const { chromium } = require('playwright');
const BASE = 'https://victor-welter.github.io';
const VIEWPORTS = [
  { name: 'mobile', width: 375, height: 800 },
  { name: 'tablet', width: 800, height: 900 },
  { name: 'desktop', width: 1300, height: 900 },
];

(async () => {
  const browser = await chromium.launch();
  for (const vp of VIEWPORTS) {
    const page = await browser.newPage();
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.goto(BASE + '/', { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(4000);
    await page.screenshot({ path: 'breakpoint-' + vp.name + '.png', fullPage: true });
    await page.close();
  }
  await browser.close();
  console.log('Screenshots saved: breakpoint-mobile.png, breakpoint-tablet.png, breakpoint-desktop.png');
})();
"
```

- [ ] **Step 2: Visually confirm each nav rendering**

Open the three PNGs and confirm:
- `breakpoint-mobile.png`: shows an app bar with a hamburger/drawer icon, not a full nav bar.
- `breakpoint-tablet.png`: shows "Home" plus a "Mais" dropdown, not all 8 destinations spelled out.
- `breakpoint-desktop.png`: shows all 8 destination labels in a single horizontal bar, with "Home" visually distinguished as active (accent color, bold).

- [ ] **Step 3: Manually open the drawer (mobile) and the Mais menu (tablet) in a real browser window**

Using a real browser (not headless), open https://victor-welter.github.io at a narrow window width, open the hamburger drawer, and confirm all 8 destinations are listed and tapping one navigates correctly. Repeat at tablet width with the "Mais" dropdown.

- [ ] **Step 4: If anything looks wrong, fix it**

Use superpowers:systematic-debugging on the affected widget (`lib/core/widgets/app_shell.dart`), following the normal edit → `flutter test` → commit cycle for that file.

- [ ] **Step 5: Record the audit result**

If nothing needed fixing:
```bash
git commit --allow-empty -m "$(cat <<'EOF'
Fase 8 QA: manual responsive/nav breakpoint check — clean

Verified mobile (drawer), tablet (Home + Mais overflow), and desktop
(full bar) nav renderings against the live site. All three list
every destination, highlight the active one, and navigate correctly.
EOF
)"
```

---

### Task 9: Run Lighthouse against the live site

**Files:** none (audit only).

**Interfaces:** none.

- [ ] **Step 1: Run Lighthouse against the home page**

Run (from `tool/smoke_test/`, or any directory — `npx` fetches Lighthouse on demand):
```bash
npx lighthouse https://victor-welter.github.io --output json,html --output-path=./lighthouse-home --chrome-flags="--headless"
```
Expected: `lighthouse-home.report.html` and `lighthouse-home.report.json` are created with Performance/Accessibility/Best-Practices/SEO scores.

- [ ] **Step 2: Run Lighthouse against a deep-linked route**

Run:
```bash
npx lighthouse https://victor-welter.github.io/projetos --output json,html --output-path=./lighthouse-projetos --chrome-flags="--headless"
```
Note whether the route's HTTP 404 status (the known GitHub Pages SPA-fallback quirk) affects Lighthouse's ability to audit it at all, or just its score — record whichever happens for the QA report.

- [ ] **Step 3: Review and fix actionable findings**

Open both HTML reports. Fix anything actionable that does **not** require changing the rendering architecture (e.g., a missing meta tag, a caching header suggestion GitHub Pages actually supports, an image that could be compressed). Do not attempt to fix low SEO/Accessibility scores caused by CanvasKit painting text to canvas instead of DOM — that is this project's accepted architectural trade-off from Fase 1, not a bug.

- [ ] **Step 4: Keep the JSON reports for the QA report task**

Leave `lighthouse-home.report.json` and `lighthouse-projetos.report.json` in place (in `tool/smoke_test/`, already `.gitignore`d via no rule needed since they're outside the repo's tracked scope — confirm with `git status` that they show as untracked, not partially staged) — Task 10 reads the scores out of them.

---

### Task 10: Write the QA report

**Files:**
- Create: `docs/superpowers/specs/2026-08-29-portfolio-qa-report.md`

**Interfaces:** none.

- [ ] **Step 1: Write the report**

Create `docs/superpowers/specs/2026-08-29-portfolio-qa-report.md`, filling in every bracketed placeholder below with the real results from Tasks 7–9 (do not leave any bracket in the committed file):

```markdown
# Portfolio Fase 8 (QA) — Report

Spec: `docs/superpowers/specs/2026-08-29-portfolio-qa-design.md`.

## Cross-browser audit (Task 7)

- Chromium: [PASS / fixed <describe>]
- Firefox: [PASS / fixed <describe>]
- WebKit: [PASS / fixed <describe>]

## Responsive/nav breakpoint check (Task 8)

- Mobile (drawer): [PASS / fixed <describe>]
- Tablet (Home + Mais overflow): [PASS / fixed <describe>]
- Desktop (full bar): [PASS / fixed <describe>]

## Lighthouse (Task 9)

Home page (`/`):
- Performance: [score]
- Accessibility: [score]
- Best Practices: [score]
- SEO: [score]

`/projetos` (deep link):
- Performance: [score]
- Accessibility: [score]
- Best Practices: [score]
- SEO: [score]
- Effect of the HTTP 404 status on the audit: [describe]

**Accepted ceiling, not a bug:** this project's Fase 1 Auditoria knowingly
chose pure Flutter Web with the CanvasKit renderer, which paints all text
and interactive content to a `<canvas>` element rather than real DOM —
Lighthouse's SEO and part of its Accessibility scoring specifically reward
crawlable/inspectable DOM content, which this architecture does not
produce by design. The scores above reflect that trade-off, not an
oversight; fixing them would mean replacing the rendering architecture,
which is out of scope for this phase (and was already an accepted
trade-off given this portfolio's traffic comes from direct links, not
organic search).

## Fixes made this phase

- 404 page now renders inside `AppShell` (Task 5) — a broken/mistyped
  link no longer strands the visitor without nav.
- [any other fixes from Tasks 7–9]

## Permanent CI smoke gate

`tool/smoke_test/` is now wired into `.github/workflows/deploy.yml`,
running on every push to `main` and failing the build (blocking deploy)
if any route fails to render, throws a console error, or the theme
toggle/résumé download breaks. First CI run that included it:
[link to the GitHub Actions run, filled in during Task 11].

## Still open (unrelated to this phase)

- BarberApp: needs real project details from Víctor before it can be
  added to Projetos.
- Bee Visit Tracking & Counting: `projects_data.dart`'s `links: []` stays
  empty unless/until that repo is made public.
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/specs/2026-08-29-portfolio-qa-report.md
git commit -m "$(cat <<'EOF'
Add the Fase 8 QA report

Records the cross-browser, responsive/nav, and Lighthouse audit
results, the fixes made, and documents the CanvasKit SEO/Accessibility
ceiling as an accepted architectural trade-off from Fase 1, not an
oversight.
EOF
)"
```

---

### Task 11: Push and confirm the live CI gate

**Files:**
- Modify: `docs/superpowers/specs/2026-08-29-portfolio-qa-report.md` (fill in the CI run link)

**Interfaces:** none.

- [ ] **Step 1: Confirm with the user before pushing**

This push deploys real changes (including the CI pipeline itself) to a live production site and workflow. Do not proceed without explicit confirmation immediately before this step, per the Global Constraints.

- [ ] **Step 2: Push**

```bash
git push origin main
```

- [ ] **Step 3: Watch the Actions run**

Confirm the `build` job's new smoke-test steps actually execute and pass in the real GitHub Actions environment (not just locally), and that `deploy` then runs successfully.

- [ ] **Step 4: Verify the live site**

Spot-check `https://victor-welter.github.io/` in a real browser (or reuse `tool/smoke_test` with `--url`) to confirm the deploy went out correctly and nothing regressed.

- [ ] **Step 5: Fill in the CI run link and commit**

Edit `docs/superpowers/specs/2026-08-29-portfolio-qa-report.md`, replacing `[link to the GitHub Actions run, filled in during Task 11]` with the real run URL.

```bash
git add docs/superpowers/specs/2026-08-29-portfolio-qa-report.md
git commit -m "$(cat <<'EOF'
Record the first CI run that included the smoke-test gate

Confirms Fase 8's permanent smoke gate is live and passing on main,
not just verified locally.
EOF
)"
git push origin main
```
