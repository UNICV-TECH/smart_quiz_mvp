'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"manifest.json": "33ea37ac464e2ada0b64328beead3a82",
"404.html": "58547fa9a7196ce4f27f4ea136bc8231",
"version.json": "48dbe1dd505e72b7682d698f38de93f2",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"index.html": "4227fe5b50f3568e3c5d18104b595726",
"/": "4227fe5b50f3568e3c5d18104b595726",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"web-build/manifest.json": "33ea37ac464e2ada0b64328beead3a82",
"web-build/404.html": "58547fa9a7196ce4f27f4ea136bc8231",
"web-build/version.json": "48dbe1dd505e72b7682d698f38de93f2",
"web-build/canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"web-build/canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"web-build/canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"web-build/canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"web-build/canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"web-build/canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"web-build/canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"web-build/canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"web-build/canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"web-build/canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"web-build/canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"web-build/canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"web-build/index.html": "a08b3d8fd232b727024757bca2cee673",
"web-build/flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"web-build/web-build/manifest.json": "33ea37ac464e2ada0b64328beead3a82",
"web-build/web-build/404.html": "58547fa9a7196ce4f27f4ea136bc8231",
"web-build/web-build/version.json": "48dbe1dd505e72b7682d698f38de93f2",
"web-build/web-build/canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"web-build/web-build/canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"web-build/web-build/canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"web-build/web-build/canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"web-build/web-build/canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"web-build/web-build/canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"web-build/web-build/canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"web-build/web-build/canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"web-build/web-build/canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"web-build/web-build/canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"web-build/web-build/canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"web-build/web-build/canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"web-build/web-build/index.html": "184ffa751e723c6bccd7a25610d2e2bc",
"web-build/web-build/flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"web-build/web-build/web-build/manifest.json": "33ea37ac464e2ada0b64328beead3a82",
"web-build/web-build/web-build/404.html": "58547fa9a7196ce4f27f4ea136bc8231",
"web-build/web-build/web-build/version.json": "48dbe1dd505e72b7682d698f38de93f2",
"web-build/web-build/web-build/canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"web-build/web-build/web-build/canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"web-build/web-build/web-build/canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"web-build/web-build/web-build/canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"web-build/web-build/web-build/canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"web-build/web-build/web-build/canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"web-build/web-build/web-build/canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"web-build/web-build/web-build/canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"web-build/web-build/web-build/canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"web-build/web-build/web-build/canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"web-build/web-build/web-build/canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"web-build/web-build/web-build/canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"web-build/web-build/web-build/index.html": "c6875ec548b7963a0d2ceae6c8a62483",
"web-build/web-build/web-build/flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"web-build/web-build/web-build/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"web-build/web-build/web-build/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"web-build/web-build/web-build/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"web-build/web-build/web-build/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"web-build/web-build/web-build/assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"web-build/web-build/web-build/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"web-build/web-build/web-build/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"web-build/web-build/web-build/assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"web-build/web-build/web-build/assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/web-build/assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"web-build/web-build/web-build/assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/web-build/assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/web-build/assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"web-build/web-build/web-build/assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/web-build/assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"web-build/web-build/web-build/assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/web-build/assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/web-build/assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"web-build/web-build/web-build/assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/web-build/assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/web-build/assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/web-build/web-build/assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"web-build/web-build/web-build/assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"web-build/web-build/web-build/assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"web-build/web-build/web-build/assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"web-build/web-build/web-build/assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"web-build/web-build/web-build/assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"web-build/web-build/web-build/flutter_bootstrap.js": "b9569bba82756db20e4e6d7994f0a652",
"web-build/web-build/web-build/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"web-build/web-build/web-build/main.dart.js": "80be2b0a8215e04fe837a290f5402151",
"web-build/web-build/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"web-build/web-build/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"web-build/web-build/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"web-build/web-build/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"web-build/web-build/assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"web-build/web-build/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"web-build/web-build/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"web-build/web-build/assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"web-build/web-build/assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"web-build/web-build/assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"web-build/web-build/assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"web-build/web-build/assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"web-build/web-build/assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/web-build/assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"web-build/web-build/assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"web-build/web-build/assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"web-build/web-build/assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"web-build/web-build/assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"web-build/web-build/assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"web-build/web-build/flutter_bootstrap.js": "bbd460d181ab4d67ffe524e9dfea69b3",
"web-build/web-build/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"web-build/web-build/main.dart.js": "80be2b0a8215e04fe837a290f5402151",
"web-build/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"web-build/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"web-build/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"web-build/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"web-build/assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"web-build/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"web-build/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"web-build/assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"web-build/assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"web-build/assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"web-build/assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"web-build/assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"web-build/assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"web-build/assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"web-build/assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"web-build/assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"web-build/assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"web-build/assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"web-build/assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"web-build/assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"web-build/assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"web-build/assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"web-build/flutter_bootstrap.js": "d0e1da85bd6e17d6ac1168026bcab7e9",
"web-build/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"web-build/main.dart.js": "9a2d69f7f0c731142cc021d9f3f5e1a3",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"flutter_bootstrap.js": "0d58ee049307c052336fa107a8e1e223",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "9a2d69f7f0c731142cc021d9f3f5e1a3"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
