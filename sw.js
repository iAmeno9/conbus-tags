// Serves the app from the cache first so it opens with no signal, and refreshes
// the cache in the background, so a new version shows up on the next launch.
var CACHE = 'conbus';

self.addEventListener('install', function (event) {
  event.waitUntil(caches.open(CACHE).then(function (cache) {
    return cache.addAll(['./', 'manifest.webmanifest', 'apple-touch-icon.png', 'icon-192.png', 'icon-512.png']);
  }).then(function () { return self.skipWaiting(); }));
});

self.addEventListener('activate', function (event) {
  event.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.filter(function (key) { return key !== CACHE; }).map(function (key) { return caches.delete(key); }));
  }).then(function () { return self.clients.claim(); }));
});

self.addEventListener('fetch', function (event) {
  var req = event.request;
  if (req.method !== 'GET') { return; }
  var fresh = fetch(req);
  event.waitUntil(fresh.then(function (res) {
    if (res.ok && !res.redirected) {
      var copy = res.clone();
      return caches.open(CACHE).then(function (cache) { return cache.put(req, copy); });
    }
  }).catch(function () {}));
  event.respondWith(caches.match(req, { ignoreSearch: true }).then(function (hit) {
    return hit || fresh.catch(function () { return req.mode === 'navigate' ? caches.match('./') : Response.error(); });
  }));
});
