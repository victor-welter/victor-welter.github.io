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
  { path: '/rota-que-nao-existe', expectText: 'Página não encontrada' },
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
  // If the click below throws (e.g. the text was never found because the
  // page is broken/blank), downloadPromise is left unawaited and rejects on
  // its own 10s timeout later, as an unhandled rejection that crashes the
  // whole Node process. Attach a no-op .catch() so that later rejection is
  // always handled; the `await downloadPromise` below still throws normally
  // (and is caught by runChecks's try/catch) if the click succeeds but no
  // download ever arrives.
  downloadPromise.catch(() => {});
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

/**
 * The Contato "Enviar" button calls launchUrl on a mailto: Uri. Per the
 * Firefox investigation in Fase 8 (task-7-report.md), url_launcher_web
 * opens external links via window.open() rather than same-tab navigation.
 * The brief for this check originally expected that same window.open() to
 * surface as a Playwright `popup` page carrying the mailto: URL, the way
 * it does for ordinary http(s) links. It doesn't: traced with a raw CDP
 * Target session, Chromium's browser process *does* create a new
 * page-type target the instant window.open() runs (with our page as
 * opener), but because mailto: is an unregistered external protocol in
 * this headless environment, Chromium intercepts the navigation before it
 * is ever committed — the target's title/url stay permanently empty, and
 * Playwright doesn't emit its own `popup` event for it until the browser
 * itself is torn down (well past any workable timeout), by which point
 * `popup.url()` is still empty too. Headless Chromium has no shell to hand
 * mailto: off to, so there's no OS-level "open with mail client" dialog to
 * fall back on either. The one real, immediate signal available is the
 * exact argument url_launcher_web passes to window.open() itself, so this
 * intercepts that call directly instead of trying to observe its outcome.
 */
async function checkContactMailto(page) {
  await page.evaluate(() => {
    window.__smokeTestOpenCalls = [];
    const originalOpen = window.open;
    window.open = function (url, ...rest) {
      window.__smokeTestOpenCalls.push(String(url));
      return originalOpen.apply(window, [url, ...rest]);
    };
  });
  await page.getByLabel('Nome', { exact: false }).fill('Visitante de Teste');
  await page
    .getByLabel('Assunto', { exact: false })
    .fill('Assunto de teste do smoke test');
  await page
    .getByLabel('Mensagem', { exact: false })
    .fill('Mensagem de teste do smoke test.');
  await page.getByText('Enviar', { exact: true }).click();
  await page.waitForTimeout(1000);
  const openCalls = await page.evaluate(() => window.__smokeTestOpenCalls);
  if (openCalls.length === 0) {
    throw new Error('window.open was never called after clicking Enviar');
  }
  const url = openCalls[openCalls.length - 1];
  if (!url.startsWith('mailto:victorwelter2003@gmail.com')) {
    throw new Error(`contact mailto URL looks wrong: ${url}`);
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
    /**
     * Firefox-only: url_launcher_web's `launchUrl` always opens via
     * `window.open()` (never a direct/`_self` navigation — confirmed by
     * reading its source, and by testing that forcing `_self` to dodge this
     * popup does avoid the error on Firefox/Chromium but silently breaks the
     * résumé link and semantics tree on WebKit, so it's not a safe app-level
     * fix). Firefox closes that popup the instant it decides there's nothing
     * to show in it — a download response on /curriculo, or (confirmed while
     * building the /contato mailto check) an unregistered mailto: protocol
     * navigation on /contato — and the Flutter engine's own popup-lifecycle
     * bookkeeping touches the (already-closing) popup's `window` object
     * during that handoff, throwing this exact TypeError. Neither real
     * behavior is affected: checkResumeDownload verifies the résumé file
     * always arrives on every engine including Firefox, and
     * checkContactMailto verifies the mailto: URL via the window.open() call
     * itself rather than relying on the popup surviving.
     */
    const isKnownFirefoxPopupRace =
      browserName === 'firefox' &&
      (currentRoutePath === '/curriculo' || currentRoutePath === '/contato') &&
      err.message.includes('access property "a"');
    if (isKnownFirefoxPopupRace) return;
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

  /**
   * Theme toggle runs before the résumé download check, not after: on
   * Firefox, url_launcher_web's popup-then-download (see the pageerror
   * handler above) leaves this same page's native pointer-input delivery
   * unreliable for a while afterward — confirmed by reproducing it directly
   * against the live site: a keyboard-focused Enter/Space or a JS-dispatched
   * click on the theme toggle still worked every time post-download, only a
   * real coordinate-based mouse click silently failed to reach the page at
   * all (zero pointerdown/mousedown/click events observed). That's a
   * Playwright/Firefox automation artifact tied to the transient popup
   * window, not a real user-facing bug, but it made this screenshot-diff
   * check flaky when run after the download. Running it first sidesteps it.
   */
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
