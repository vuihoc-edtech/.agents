# GetX Controller Rules

## Core Principle

A `GetxController` is a presentation coordinator, not the entire application.

## Controller Responsibilities

Good controller responsibilities:

- expose UI state
- trigger loading and refreshing
- handle user intent such as submit, retry, select, filter, or navigate
- map repository results into screen state
- own disposable workers or listeners related to the screen

Bad controller responsibilities:

- raw API implementation
- database setup
- route registration
- JSON model definitions
- giant cross-feature business workflows

## Visibility Rule

Keep controller internals private by default.

Prefer:

- private fields such as `_isSubmitting`
- private helper methods such as `_loadProfile()` or `_mapError()`
- exposing only the state and actions that other classes truly need

If a field or method is only used inside the controller, prefix it with `_`.

This reduces accidental external access and makes unused internal code easier to identify.

## Size Rules

Warning signs that a controller is too large:

- many unrelated `.obs` fields
- methods for multiple tabs or screens that barely relate
- validation, networking, caching, and UI mapping in one file
- the view becomes just `controller.doEverything()`
- very long methods that mix many steps and branches

If this happens:

1. split repository or service logic out first
2. split feature sections into smaller widgets
3. split the flow into multiple controllers only if the screen boundaries are real

As a practical rule, if one controller method becomes long enough that it is hard to scan quickly, treat that as a signal to extract helpers or move responsibilities down a layer.

## Lifecycle Rules

Use lifecycle hooks intentionally:

- `onInit` for initial setup
- `onReady` for behavior that depends on first render or navigation completion
- `onClose` for cleanup

Do not dump every startup action into `onInit` if some work should happen lazily.

## Async State

Controllers should expose async state in a way the view can read clearly.

Common patterns:

- explicit booleans such as `isLoading`
- status enum
- `StateMixin<T>` when a resource-centric async model fits well

Prefer clarity over cleverness.

## Function Signature Rule

Prefer functions with explicit input and output contracts.

Prefer shapes such as:

```dart
Future<UserProfile> getProfile({required String id})
```

or:

```dart
ResultDart<UserProfile, AppFailure> mapProfile(ApiResponse<ProfileDto> response)
```

Avoid vague helper methods with unclear inputs, hidden side effects, or ambiguous return values.

Named parameters are usually preferable when a function has more than one meaningful input.
