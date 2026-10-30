// Offline-Speicher für Buchstaben-Bingo.
// Seiten (HTML) kommen zuerst aus dem Netz, damit Updates sofort ankommen,
// und nur ohne Netz aus dem Speicher. Alles andere (Töne, Schrift,
// Bibliotheken, Symbole) kommt sofort aus dem Speicher und wird im
// Hintergrund aufgefrischt. Bei Änderungen an der Dateiliste VERSION erhöhen.
const VERSION = "abcbingo-v3";

const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
const FILES = [
  "./",
  "index.html",
  "karten.html",
  "README.md",
  "sounds.js",
  "manifest.webmanifest",
  "icons/icon-180.png",
  "icons/icon-192.png",
  "icons/icon-512.png",
  "fonts/andika-latin-400.woff2",
  "fonts/andika-latin-700.woff2",
  "lib/mqtt.min.js",
  "lib/qrcode.js",
  ...LETTERS.map(l => l + ".mp3"),
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

const NET_TIMEOUT_MS = 4000;   // langsames Schul-WLAN: dann lieber die gespeicherte Seite

function fromCache(req) {
  return caches.match(req, { ignoreSearch: true }).then(r => r || caches.match("index.html"));
}

function networkFirst(req) {
  const net = fetch(req).then(res => {
    if (res.ok) { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
    return res;
  });
  const timeout = new Promise(res => setTimeout(res, NET_TIMEOUT_MS))
    .then(() => fromCache(req))
    .then(hit => hit || net);
  return Promise.race([net.catch(() => fromCache(req)), timeout]);
}

function cacheFirst(req) {
  return caches.match(req).then(hit => {
    const fresh = fetch(req).then(res => {
      if (res.ok) { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
      return res;
    });
    if (hit) { fresh.catch(() => {}); return hit; }
    return fresh;
  });
}

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== location.origin) return;
  // Seiten und die Anleitung (README.md) zuerst aus dem Netz, damit sie aktuell sind
  const isPage = req.mode === "navigate" || req.destination === "document" ||
                 new URL(req.url).pathname.endsWith(".md");
  e.respondWith(isPage ? networkFirst(req) : cacheFirst(req));
});
