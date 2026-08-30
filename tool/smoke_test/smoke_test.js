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
