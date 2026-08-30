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
