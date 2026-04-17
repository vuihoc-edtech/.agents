# Envied Rules

## Core Principle

Environment configuration should be generated and typed.

Use `envied` so runtime configuration such as API URLs and keys comes from one app-level source instead of duplicated constants.

## Package Rule

Prefer:

- `envied` in dependencies
- `envied_generator` and `build_runner` in dev dependencies

The package documentation describes `envied` as reading environment variables into a generated Dart file from a `.env` file.

## Suggested Placement

Prefer:

```text
app/
  env/
    env.dart
    env.g.dart
```

Use one typed env entry point for the app.

## Usage Rule

Prefer a pattern such as:

```dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', useConstantCase: true)
abstract class Env {
  @EnviedField()
  static const String apiBaseUrl = _Env.apiBaseUrl;
}
```

Then consume:

```dart
final baseUrl = Env.apiBaseUrl;
```

Avoid:

- raw environment strings in repositories or services
- multiple base URL constants in different layers
- parsing `.env` files manually at runtime

## Multiple Environment Rule

If the app has multiple environments, use env-specific files such as:

- `.env`
- `.env.dev`
- `.env.staging`
- `.env.prod`

Use Envied's documented path override or multiple environment patterns rather than inventing a second config system.

## Security Rule

The package documentation warns that `.env` and generated env files can expose values if committed incorrectly.

Prefer:

- keeping sensitive `.env` files out of source control
- keeping generated env files out of git when they contain secrets
- using obfuscation only as a difficulty increase, not as real secret protection

## Decision Rule

When unsure:

1. put app config in `app/env/env.dart`
2. generate typed values with `envied`
3. inject or read those typed values from composition code
4. do not duplicate config constants anywhere else
