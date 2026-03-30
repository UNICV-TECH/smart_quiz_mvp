'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"404.html": "84fa7299288f97a9c73cf778bef29dc7",
"assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"assets/AssetManifest.json": "7e70ade9532fc6a3fd5ef7a2aa5126c0",
"assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "11cd7b19c3fd0fb2633652ec39fcabfe",
"assets/NOTICES": "8081dc6ee8513eb2cee238d88061b078",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "a70217f9ceba606e287441a0df5be64d",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "7b07b595397b38ca106ad1bbe5b84d77",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "79a4c420f3728fedd9f864a59d388339",
"icons/Icon-192.png": "5792e1d84689d4aaba54610f7e512777",
"icons/Icon-512.png": "df7954b7552389d759359bb69e246573",
"icons/Icon-maskable-192.png": "5792e1d84689d4aaba54610f7e512777",
"icons/Icon-maskable-512.png": "df7954b7552389d759359bb69e246573",
"index.html": "3702515eda388f52defa9e60955a953d",
"/": "3702515eda388f52defa9e60955a953d",
"main.dart.js": "29b5c6ee43b22adcba1cb6e2e8548d6f",
"manifest.json": "6f8b27ded7d33bdc69475fb75fa4f804",
"version.json": "48dbe1dd505e72b7682d698f38de93f2",
"web-build/404.html": "84fa7299288f97a9c73cf778bef29dc7",
"web-build/assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"web-build/assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"web-build/assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"web-build/assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"web-build/assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"web-build/assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"web-build/assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"web-build/assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"web-build/assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"web-build/assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"web-build/assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"web-build/assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"web-build/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"web-build/assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"web-build/assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"web-build/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"web-build/assets/shaders/ink_sparkle.frag": "9bb2aaa0f9a9213b623947fa682efa76",
"web-build/assets/shaders/stretch_effect.frag": "a70217f9ceba606e287441a0df5be64d",
"web-build/canvaskit/canvaskit.js": "4d1e85fa7485c3b2f38877206ad60089",
"web-build/canvaskit/canvaskit.js.symbols": "cd60996d998c96148c6b3245aa4f79be",
"web-build/canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"web-build/canvaskit/chromium/canvaskit.js": "5986f8281d3ff5aa43516ec637c2352b",
"web-build/canvaskit/chromium/canvaskit.js.symbols": "abce3e84295438db81e9753c30fe3c2b",
"web-build/canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"web-build/canvaskit/skwasm.js": "d16458b3d26fe6c8c52bf62df5e5a52f",
"web-build/canvaskit/skwasm.js.symbols": "148546317b68494b4e09dcab02f87135",
"web-build/canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"web-build/canvaskit/skwasm_heavy.js": "d684311c36a7a439e12bebd0b63a9bea",
"web-build/canvaskit/skwasm_heavy.js.symbols": "218aadf9004b320bc6cf0d0bb04ed157",
"web-build/canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"web-build/favicon.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/flutter.js": "1c7e59be1cc906f8d37361ad32ed7e52",
"web-build/flutter_bootstrap.js": "a9c24a80beff34973e7a363530454516",
"web-build/icons/Icon-192.png": "5792e1d84689d4aaba54610f7e512777",
"web-build/icons/Icon-512.png": "df7954b7552389d759359bb69e246573",
"web-build/icons/Icon-maskable-192.png": "5792e1d84689d4aaba54610f7e512777",
"web-build/icons/Icon-maskable-512.png": "df7954b7552389d759359bb69e246573",
"web-build/index.html": "c5def6bb343b3aa2832ccc6f1897e244",
"web-build/main.dart.js": "78454024aecd1f4104cea03ea82281f5",
"web-build/manifest.json": "6f8b27ded7d33bdc69475fb75fa4f804",
"web-build/version.json": "48dbe1dd505e72b7682d698f38de93f2",
"web-build/web-build/404.html": "84fa7299288f97a9c73cf778bef29dc7",
"web-build/web-build/assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"web-build/web-build/assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"web-build/web-build/assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"web-build/web-build/assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"web-build/web-build/assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"web-build/web-build/assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"web-build/web-build/assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/web-build/assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"web-build/web-build/assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"web-build/web-build/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"web-build/web-build/assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"web-build/web-build/assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"web-build/web-build/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"web-build/web-build/assets/shaders/ink_sparkle.frag": "9bb2aaa0f9a9213b623947fa682efa76",
"web-build/web-build/assets/shaders/stretch_effect.frag": "a70217f9ceba606e287441a0df5be64d",
"web-build/web-build/canvaskit/canvaskit.js": "4d1e85fa7485c3b2f38877206ad60089",
"web-build/web-build/canvaskit/canvaskit.js.symbols": "cd60996d998c96148c6b3245aa4f79be",
"web-build/web-build/canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"web-build/web-build/canvaskit/chromium/canvaskit.js": "5986f8281d3ff5aa43516ec637c2352b",
"web-build/web-build/canvaskit/chromium/canvaskit.js.symbols": "abce3e84295438db81e9753c30fe3c2b",
"web-build/web-build/canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"web-build/web-build/canvaskit/skwasm.js": "d16458b3d26fe6c8c52bf62df5e5a52f",
"web-build/web-build/canvaskit/skwasm.js.symbols": "148546317b68494b4e09dcab02f87135",
"web-build/web-build/canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"web-build/web-build/canvaskit/skwasm_heavy.js": "d684311c36a7a439e12bebd0b63a9bea",
"web-build/web-build/canvaskit/skwasm_heavy.js.symbols": "218aadf9004b320bc6cf0d0bb04ed157",
"web-build/web-build/canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"web-build/web-build/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"web-build/web-build/flutter.js": "1c7e59be1cc906f8d37361ad32ed7e52",
"web-build/web-build/flutter_bootstrap.js": "876955349853ede391bc1847887bd135",
"web-build/web-build/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"web-build/web-build/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"web-build/web-build/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"web-build/web-build/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"web-build/web-build/index.html": "f9cfdd008cf44f4612bf19867ac27014",
"web-build/web-build/main.dart.js": "78454024aecd1f4104cea03ea82281f5",
"web-build/web-build/manifest.json": "15df426d07b9383f185e699cc145d67b",
"web-build/web-build/version.json": "48dbe1dd505e72b7682d698f38de93f2",
"web-build/web-build/web-build/404.html": "84fa7299288f97a9c73cf778bef29dc7",
"web-build/web-build/web-build/assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"web-build/web-build/web-build/assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"web-build/web-build/web-build/assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"web-build/web-build/web-build/assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"web-build/web-build/web-build/assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"web-build/web-build/web-build/assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"web-build/web-build/web-build/assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/web-build/web-build/assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/web-build/assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/web-build/assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/web-build/assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/web-build/assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/web-build/assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/web-build/assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/web-build/assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/web-build/assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"web-build/web-build/web-build/assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"web-build/web-build/web-build/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"web-build/web-build/web-build/assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"web-build/web-build/web-build/assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"web-build/web-build/web-build/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"web-build/web-build/web-build/assets/shaders/ink_sparkle.frag": "9bb2aaa0f9a9213b623947fa682efa76",
"web-build/web-build/web-build/assets/shaders/stretch_effect.frag": "a70217f9ceba606e287441a0df5be64d",
"web-build/web-build/web-build/canvaskit/canvaskit.js": "4d1e85fa7485c3b2f38877206ad60089",
"web-build/web-build/web-build/canvaskit/canvaskit.js.symbols": "cd60996d998c96148c6b3245aa4f79be",
"web-build/web-build/web-build/canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"web-build/web-build/web-build/canvaskit/chromium/canvaskit.js": "5986f8281d3ff5aa43516ec637c2352b",
"web-build/web-build/web-build/canvaskit/chromium/canvaskit.js.symbols": "abce3e84295438db81e9753c30fe3c2b",
"web-build/web-build/web-build/canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"web-build/web-build/web-build/canvaskit/skwasm.js": "d16458b3d26fe6c8c52bf62df5e5a52f",
"web-build/web-build/web-build/canvaskit/skwasm.js.symbols": "148546317b68494b4e09dcab02f87135",
"web-build/web-build/web-build/canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"web-build/web-build/web-build/canvaskit/skwasm_heavy.js": "d684311c36a7a439e12bebd0b63a9bea",
"web-build/web-build/web-build/canvaskit/skwasm_heavy.js.symbols": "218aadf9004b320bc6cf0d0bb04ed157",
"web-build/web-build/web-build/canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"web-build/web-build/web-build/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"web-build/web-build/web-build/flutter.js": "1c7e59be1cc906f8d37361ad32ed7e52",
"web-build/web-build/web-build/flutter_bootstrap.js": "fb5b96fa0a3ec20f4f752533f2f0cb05",
"web-build/web-build/web-build/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"web-build/web-build/web-build/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"web-build/web-build/web-build/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"web-build/web-build/web-build/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"web-build/web-build/web-build/index.html": "6d663e3f83d78b1d220d931c16a19b45",
"web-build/web-build/web-build/main.dart.js": "2f9ce014c0bf780bde6f84cd2cddf9a6",
"web-build/web-build/web-build/manifest.json": "15df426d07b9383f185e699cc145d67b",
"web-build/web-build/web-build/version.json": "48dbe1dd505e72b7682d698f38de93f2",
"web-build/web-build/web-build/web-build/404.html": "84fa7299288f97a9c73cf778bef29dc7",
"web-build/web-build/web-build/web-build/assets/AssetManifest.bin": "8beb0583dee55003bb6b3a408eecaa34",
"web-build/web-build/web-build/web-build/assets/AssetManifest.bin.json": "4e380c613e1f1bece38343c33c35ba93",
"web-build/web-build/web-build/web-build/assets/assets/images/background.jpg": "74d157b39b0d9a341606890cee3ea3cc",
"web-build/web-build/web-build/web-build/assets/assets/images/fundo.png": "3af174ab3db5bf5add743b2a29323399",
"web-build/web-build/web-build/web-build/assets/assets/images/FundoWhiteHome.png": "24a254dcde276a0ef1593c4328de699a",
"web-build/web-build/web-build/web-build/assets/assets/images/logo.webp": "21608bc0dcc4470981185a6b05c0ee89",
"web-build/web-build/web-build/web-build/assets/assets/images/logo_color.png": "7b07b595397b38ca106ad1bbe5b84d77",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_1.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_2.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_3.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_4.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_explorador.png": "62d7f62d448930e8e41451408f175e78",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_iniciante.png": "ef729fdc9e016468431113fffd6f53f5",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_lendario.png": "761c491b64c1ce237103f53903562c50",
"web-build/web-build/web-build/web-build/assets/assets/images/medal_mestre.png": "e1014294e568b8e018cd86eaff14ec7b",
"web-build/web-build/web-build/web-build/assets/assets/images/SmartQuiz.png": "b6363d4d53000e91f49c2b0aa7e17c33",
"web-build/web-build/web-build/web-build/assets/assets/images/SmartQuiz_branca.png": "1f6d8e3c3ba4fd8700691bddb567b83e",
"web-build/web-build/web-build/web-build/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"web-build/web-build/web-build/web-build/assets/fonts/MaterialIcons-Regular.otf": "4d1eef6906b7def69f2d337d783fea5f",
"web-build/web-build/web-build/web-build/assets/NOTICES": "a6a0bf76f8792a84cfa1155cba916beb",
"web-build/web-build/web-build/web-build/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"web-build/web-build/web-build/web-build/assets/shaders/ink_sparkle.frag": "9bb2aaa0f9a9213b623947fa682efa76",
"web-build/web-build/web-build/web-build/assets/shaders/stretch_effect.frag": "a70217f9ceba606e287441a0df5be64d",
"web-build/web-build/web-build/web-build/canvaskit/canvaskit.js": "4d1e85fa7485c3b2f38877206ad60089",
"web-build/web-build/web-build/web-build/canvaskit/canvaskit.js.symbols": "cd60996d998c96148c6b3245aa4f79be",
"web-build/web-build/web-build/web-build/canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"web-build/web-build/web-build/web-build/canvaskit/chromium/canvaskit.js": "5986f8281d3ff5aa43516ec637c2352b",
"web-build/web-build/web-build/web-build/canvaskit/chromium/canvaskit.js.symbols": "abce3e84295438db81e9753c30fe3c2b",
"web-build/web-build/web-build/web-build/canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"web-build/web-build/web-build/web-build/canvaskit/skwasm.js": "d16458b3d26fe6c8c52bf62df5e5a52f",
"web-build/web-build/web-build/web-build/canvaskit/skwasm.js.symbols": "148546317b68494b4e09dcab02f87135",
"web-build/web-build/web-build/web-build/canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"web-build/web-build/web-build/web-build/canvaskit/skwasm_heavy.js": "d684311c36a7a439e12bebd0b63a9bea",
"web-build/web-build/web-build/web-build/canvaskit/skwasm_heavy.js.symbols": "218aadf9004b320bc6cf0d0bb04ed157",
"web-build/web-build/web-build/web-build/canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"web-build/web-build/web-build/web-build/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"web-build/web-build/web-build/web-build/flutter.js": "1c7e59be1cc906f8d37361ad32ed7e52",
"web-build/web-build/web-build/web-build/flutter_bootstrap.js": "d33b94080ceb5a45276ef49db046380c",
"web-build/web-build/web-build/web-build/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"web-build/web-build/web-build/web-build/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"web-build/web-build/web-build/web-build/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"web-build/web-build/web-build/web-build/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"web-build/web-build/web-build/web-build/index.html": "ed73bc01c7a581666d3bcf88b1857f2a",
"web-build/web-build/web-build/web-build/main.dart.js": "2f9ce014c0bf780bde6f84cd2cddf9a6",
"web-build/web-build/web-build/web-build/manifest.json": "15df426d07b9383f185e699cc145d67b",
"web-build/web-build/web-build/web-build/version.json": "48dbe1dd505e72b7682d698f38de93f2"};
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
