# Deep Link Rules

## Core Principle

Deep links should enter the app through one service boundary, not through many feature listeners.

Prefer an app-level `DeeplinkService` that receives incoming links, parses them, and dispatches navigation intents.

Only app-owned URL paths should trigger in-app navigation. Prefer reserved prefixes such as `/a/*` or `/app/*` so normal website URLs continue opening on the web instead of unexpectedly launching the app.

## Package Rule

Prefer `app_links` for incoming app links, universal links, and custom scheme links.

The package documentation says to instantiate `AppLinks` early in the app so the first cold-state link is not missed.

## Suggested Placement

Prefer:

```text
app/
  services/
    deeplink_service.dart
```

This service can coordinate with routing, auth/session checks, and feature entry logic.

## Service Responsibilities

`DeeplinkService` should usually:

- create or receive the `AppLinks` instance
- subscribe once to the incoming URI stream
- handle the initial link and later links
- parse URIs into app-level intents or route targets
- delegate final navigation to the routing layer
- expose one public `navigate(String url)` method for explicit deep link navigation

It should usually not:

- contain feature-specific UI code
- let every screen subscribe independently
- mix platform setup concerns into view code
- accept arbitrary website paths as valid app routes

## Path Filtering Rule

To avoid hijacking ordinary web navigation, only process URLs whose path is intentionally reserved for the app.

Prefer patterns such as:

- `/a/profile`
- `/a/orders`
- `/app/profile`
- `/app/settings`

Avoid processing general website paths such as:

- `/blog/...`
- `/products/...`
- `/landing/...`

unless those paths are explicitly designed as app entry routes.

If the path does not start with an approved app prefix, return without navigation.

## Navigation API Rule

Prefer one main entrypoint:

```dart
Future<void> navigate(String url)
```

Recommended behavior:

1. parse the input into `Uri`
2. validate that the path starts with `/a/` or `/app/`
3. normalize the route used inside the app
4. convert query parameters into an `args` map
5. try-parse argument values to `bool` and `num`, otherwise keep them as `String`
6. check whether the route exists in the registered `GetPage` list
7. call `Get.toNamed(route, arguments: args)` only if the route is valid
8. return without navigation when validation fails

Recommended normalization example:

- incoming `/a/profile?id=1&editable=true`
- app route `/profile`
- args `{ "id": 1, "editable": true }`

Example shape:

```dart
Future<void> navigate(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final path = uri.path;
  final isAppPath = path.startsWith('/a/') || path.startsWith('/app/');
  if (!isAppPath) return;

  final route = path.startsWith('/a/')
      ? path.substring(2)
      : path.substring(4);

  final normalizedRoute = route.startsWith('/') ? route : '/$route';

  final args = <String, dynamic>{
    for (final entry in uri.queryParameters.entries)
      entry.key: _tryParseValue(entry.value),
  };

  final routeExists = Get.routeTree.routes.any(
    (page) => page.name == normalizedRoute,
  );
  if (!routeExists) return;

  await Get.toNamed(normalizedRoute, arguments: args);
}
```

Typical parser behavior:

- `"true"` and `"false"` become `bool`
- numeric strings become `num`
- everything else remains `String`

This keeps the service predictable and avoids accidental navigation on unsupported links.

## Platform Rule

When using `app_links`, disable Flutter's default deep link handler for mobile apps.

Per Flutter's official deep linking docs:

- in `AndroidManifest.xml`, set `flutter_deeplinking_enabled` to `false`
- in `Info.plist`, set `FlutterDeepLinkingEnabled` to `false`

This avoids Flutter's default handler conflicting with plugin-based deep link handling.

## Android and iOS Setup Rule

Still configure platform-level app links and universal links normally:

- Android intent filters and app links setup
- iOS associated domains and universal links setup

Disabling Flutter's default deep linking does not replace platform setup. It only avoids double-handling when a plugin owns the flow.

## Decision Rule

When unsure:

1. use one app-level `DeeplinkService`
2. use `app_links` as the input source
3. initialize it early
4. disable Flutter's default deep link handler on Android and iOS
5. only accept reserved app path prefixes such as `/a/*` or `/app/*`
6. route everything through `navigate(String url)`
7. map URIs to explicit app navigation intents before routing
