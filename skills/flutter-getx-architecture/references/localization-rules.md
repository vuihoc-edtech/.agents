# Localization Rules

## Core Principle

Localization should be centralized and source-driven.

Use English as the source of truth in `app_en.arb`, then generate translated ARB files from it.

## Source of Truth Rule

Prefer:

- `app_en.arb` as the only manually authored content source
- semantic and reusable localization keys
- generated locale files for every supported language
- one app-level localization wrapper for runtime access

Content writers should write English only in `app_en.arb`.

Do not treat `app_vi.arb`, `app_ar.arb`, or other translated files as the main authoring surface unless a specific correction workflow requires it.

## Translation Workflow

Prefer this flow:

1. write or update English content in `app_en.arb`
2. run `arb_translate` to generate other locale ARB files
3. run `flutter gen-l10n` to regenerate the localization access classes

Typical commands:

```bash
dart run arb_translate
flutter gen-l10n
```

If the repo already has a wrapper script or agreed command, preserve that convention.

## Suggested Placement

Prefer:

```text
app/
  l10n/
    app_en.arb
    app_vi.arb
    app_ar.arb
    l10n.dart
    l10n_wrapper.dart
  l10n.yaml
```

The exact path may follow the repo convention, but keep localization app-wide rather than feature-local.

## Code Usage Rule

Widgets should consume one app-level localization wrapper such as:

- `L10n.tr.loginTitle`

Do not call generated accessors directly across feature code such as:

- `S.of(context).loginTitle`
- `AppLocalizations.of(context)!.loginTitle`

Prefer a thin wrapper shape such as:

```dart
class L10n {
  static S get tr => S.of(Get.context!) ?? SEn();
}
```

or:

```dart
class L10n {
  static AppLocalizations get tr =>
      AppLocalizations.of(Get.context!) ?? AppLocalizationsEn();
}
```

Do not hardcode user-facing strings in widgets once localization is established.

This keeps call sites short and consistent:

```dart
Text(L10n.tr.loginTitle)
```

## Scope Rule

Move into ARB:

- labels
- hints
- button text
- dialog copy
- snackbar copy
- empty, loading, and error messages meant for users

Do not move into ARB unless the app explicitly needs it:

- route names
- API endpoints
- asset paths
- debug logs
- server identifiers

## Decision Rule

When unsure:

1. write English in `app_en.arb`
2. generate translated files with `arb_translate`
3. regenerate localization classes with `gen_l10n`
4. expose localization through `L10n.tr`
5. keep localized strings out of Dart UI code
