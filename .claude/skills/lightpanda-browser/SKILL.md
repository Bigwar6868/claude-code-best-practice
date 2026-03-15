---
name: lightpanda-browser
description: "Use when the user wants to use Lightpanda headless browser for web scraping, automation, or testing. Lightpanda is a fast, low-memory alternative to headless Chrome. Use for fetching pages, running CDP servers, or connecting via Puppeteer/Playwright."
user-invocable: true
argument-hint: "[url or action]"
allowed-tools: Bash
---

# Lightpanda Browser

> Source: [lightpanda-io/browser](https://github.com/lightpanda-io/browser)

A headless browser built for AI and automation — 9x less memory than Chrome, 11x faster execution.

## Installation

```bash
# Linux x86_64
curl -L -o lightpanda https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-x86_64-linux
chmod a+x ./lightpanda

# macOS aarch64
curl -L -o lightpanda https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-aarch64-macos
chmod a+x ./lightpanda

# Docker
docker run -d --name lightpanda -p 9222:9222 lightpanda/browser:nightly
```

## Usage Modes

### 1. Fetch & Parse a URL

Retrieve a page, execute JS, output rendered HTML:

```bash
./lightpanda fetch --log_format pretty --log_level info https://example.com
```

### 2. Start CDP Server

Run as a Chrome DevTools Protocol server for Puppeteer/Playwright:

```bash
./lightpanda serve --host 127.0.0.1 --port 9222
```

### 3. Connect via Puppeteer

```javascript
import puppeteer from 'puppeteer-core';

const browser = await puppeteer.connect({
  browserWSEndpoint: "ws://127.0.0.1:9222"
});

const context = await browser.createBrowserContext();
const page = await context.newPage();
await page.goto('https://example.com', { waitUntil: "networkidle0" });

const content = await page.evaluate(() => document.body.innerText);
console.log(content);
await browser.disconnect();
```

### 4. Connect via Playwright

```javascript
const { chromium } = require('playwright');

const browser = await chromium.connectOverCDP('http://127.0.0.1:9222');
const context = browser.contexts()[0];
const page = await context.newPage();
await page.goto('https://example.com');
```

## Key Features

- HTTP loading, HTML parsing, full DOM tree
- JavaScript engine (V8), DOM APIs
- AJAX (XHR and Fetch APIs)
- CDP/WebSocket server (Puppeteer/Playwright compatible)
- User interactions (click, form input)
- Cookie management, custom HTTP headers
- Proxy support, network request interception
- robots.txt compliance (`--obey_robots` flag)

## When to Choose Lightpanda vs Chrome

| Scenario | Use Lightpanda | Use Chrome |
|----------|---------------|------------|
| Web scraping at scale | Yes — 9x less memory | Overkill |
| Simple page fetching | Yes — instant startup | Slow startup |
| Complex SPAs with WebGL | Not yet | Yes |
| CI/CD testing | Yes — lightweight | Heavy |
| Full browser compatibility | Partial Web APIs | Complete |

## Disable Telemetry

```bash
export LIGHTPANDA_DISABLE_TELEMETRY=true
```

## Troubleshooting

- **Page doesn't render correctly:** Lightpanda is in Beta — some Web APIs are not yet implemented. Try with Chrome/Playwright as fallback.
- **Connection refused on port 9222:** Ensure `lightpanda serve` is running. Check `--host` binding (use `0.0.0.0` for Docker).
- **robots.txt blocking:** Remove `--obey_robots` flag if you have permission to scrape the target.
