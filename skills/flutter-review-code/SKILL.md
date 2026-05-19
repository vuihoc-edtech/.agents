---
name: flutter-review-code
description: Use when reviewing Flutter or Dart code changes, AI-generated implementations, large feature diffs, refactors, maintainability risks, readability problems, unnecessary complexity, or missing validation.
---

# Flutter Review Code

## Goal

Review Flutter and Dart code so it stays easy to read, easy to maintain, and no larger than the problem requires.

If a feature can be implemented in roughly `50` clear lines instead of `200` lines while preserving behavior, quality, testability, and user-visible output, prefer the smaller implementation.

Prefer simplicity that removes real complexity. Do not preserve abstractions, public APIs, or helper methods just because generated code created them.

## Review Stance

Lead with findings. Prioritize correctness, regressions, maintainability, and missing validation over style.

Do not approve code only because it compiles. A change can pass analysis and still be too complex, fragile, duplicated, or hard to modify.

## Workflow

### 1. Understand the intended behavior

Before reviewing details, inspect:

- the user's request or ticket summary
- `git diff` or the touched files
- nearby existing patterns
- relevant tests or snapshots
- `.agents.env` if it exists

Ask: what behavior should remain the same, and what behavior intentionally changed?

### 2. Review for correctness first

Look for:

- broken user flows
- wrong async ordering
- missing error, empty, loading, or retry states
- state updates after dispose
- GetX lifecycle mistakes
- unsafe null assertions with `!`
- risky `late` fields that are not clearly initialized before use
- unsafe `first`, `last`, `single`, `firstWhere`, or indexed access without an empty/bounds fallback
- unsafe `int.parse` or `double.parse` on user/API data instead of `tryParse`
- duplicated dependency registration
- repositories leaking transport exceptions
- UI code calling raw APIs or storage directly
- controllers importing UI-specific widget/color/theme code
- localization, asset, or environment access bypassing project conventions

If correctness is uncertain, request or run the smallest useful validation before judging maintainability.

### 3. Review for maintainability

Prefer code that:

- has one obvious place for each responsibility
- uses names that explain domain intent
- keeps controllers focused on presentation orchestration
- keeps widgets readable at the screen level
- keeps declarations private unless another library genuinely needs to call them
- uses small helpers only when they remove real complexity
- keeps dependency ownership discoverable
- follows existing project conventions before inventing new ones

Flag code that:

- makes future changes require edits in many unrelated places
- hides important side effects behind generic helpers
- adds wrappers whose only job is to call one other method
- exposes methods, fields, controllers, or helpers publicly when they can be private
- spreads the same condition, mapping, style, or error handling across files
- mixes UI, networking, persistence, and parsing in one class
- passes a whole `GetxController` into reusable widgets instead of passing the required values and callbacks

Private-by-default rule:

- use `_privateName` for functions, fields, widgets, helpers, and constants that are only used in the same Dart library
- keep public APIs small and intentional
- prefer private helpers because unused private declarations are easier for analysis and reviewers to identify and remove later
- make something public only when it is part of a real cross-file/module contract

### 4. Review for code size and AI bloat

AI-generated code often looks polished while adding unnecessary surface area. Treat these as review smells:

- a feature has many abstractions before reuse is proven
- a simple flow has manager, coordinator, handler, helper, adapter, and factory layers
- methods mostly forward to other methods without adding policy
- a function exists only to call exactly one other function with the same inputs
- comments describe obvious code instead of explaining a hard decision
- enum, class, or extension names sound generic but hide only one call site
- code creates a custom framework around a local problem
- the diff contains broad cleanup unrelated to the requested change

Use this simplification test:

1. Can the same behavior be expressed with fewer moving parts?
2. Would a new developer understand the shorter version faster?
3. Does the shorter version keep the same output, error handling, and testability?
4. Does it preserve established architecture boundaries?

If all answers are yes, recommend the simpler version. If the long version protects a real boundary or future requirement, keep it and explain why.

Function extraction rule:

- keep a direct call when a function only forwards to one other function
- extract a function only when it adds branching, error handling, naming clarity, reuse, lifecycle control, or a meaningful abstraction boundary
- for UI chunks, prefer a private widget class or `StatelessWidget` over a helper method when the chunk is reusable, has parameters, or benefits from its own rebuild boundary

### 5. Review Flutter UI specifically

Check:

- build methods remain scan-friendly
- extracted widgets have a clear reason to exist
- reusable UI chunks are widgets rather than helper functions returning widgets
- feature widgets are not prematurely promoted to shared/design-system layers
- layout handles long text, empty data, loading, errors, and small screens
- spacing, radius, color, typography, and assets follow project conventions
- user-facing strings follow the localization policy
- `Obx`, `GetBuilder`, `FutureBuilder`, and similar builders rebuild only what needs to change
- `const` constructors are used where they fit without hurting API flexibility
- UI state ownership is local when behavior is purely local

Avoid asking for extra widgets just because a file is long. Ask for extraction when it improves reading, reuse, testing, or responsibility boundaries.

GetX review preferences:

- prefer `GetView<Controller>` for route/screen views with one binding-owned controller
- use `StatelessWidget` when the view has no controller or the controller relationship is not one-to-one
- avoid repeated `Get.find()` calls in widget trees when `GetView` or constructor wiring is clearer
- prefer GetX bindings for route dependency setup; avoid scattering `Get.put()` through views and `main`
- prefer `Get.toNamed()` and named route constants over anonymous route pushes or string literals in UI code
- pass values and callbacks into reusable/common widgets instead of letting them call `Get.find()`
- for feature-specific child widgets, still prefer values/callbacks, but allow `GetView` or `Get.find()` when avoiding severe prop drilling is clearly simpler
- do not pass `GetxController` instances through constructors unless the widget is explicitly controller-bound and feature-local
- prefer small `Obx` scopes for Rx-driven UI state
- prefer `Obx` over `GetBuilder` when only specific observable values should update independently
- use `GetBuilder` only when grouped manual `update()` semantics are simpler and intentional
- do not wrap entire pages or `Scaffold`s in `Obx` unless the whole screen genuinely depends on one state
- allow `StatefulWidget`/`setState` for purely local UI behavior such as hover, expand/collapse, tab selection, local animation, or password visibility
- avoid `FutureBuilder` for app state that already belongs in a controller/service; expose loading/data/error state from the controller and render it with `Obx`
- when `FutureBuilder` is genuinely local and one-shot, ensure the future is created before `build`, such as in `initState`, `didUpdateWidget`, or `didChangeDependencies`

Lifecycle and leak checks:

- `TextEditingController`, `ScrollController`, `AnimationController`, `FocusNode`, `PageController`, timers, and subscriptions must be disposed or canceled by the owner
- GetX workers such as `ever`, `once`, `debounce`, or `interval` should be created where their lifecycle is clear and disposed when not managed by the controller lifecycle
- avoid passing `BuildContext` into controllers; pass data/events instead and keep UI effects at the view/service boundary
- if a `StatefulWidget` uses `BuildContext` after `await`, check `mounted` first

Flutter performance and readability checks:

- avoid repetitive or costly work in `build`
- avoid overly large single widgets with large `build` methods
- localize rebuild triggers to the subtree that actually changes
- use lazy builders for long lists or grids
- avoid broad `Opacity`, clipping, intrinsic layout, or `saveLayer`-triggering effects unless they are necessary and measured
- do not override `operator ==` on non-leaf widgets as a performance trick

### 6. Review tests and validation

Look for the smallest useful proof:

- unit tests for pure mapping, formatting, repository, and service behavior
- widget tests for meaningful UI state changes
- controller tests for state transitions
- golden or screenshot checks only when visual regression risk is real
- targeted `dart analyze`, `flutter analyze`, `flutter test`, or project-specific commands

If tests are missing, state the exact risk they would cover. Do not ask for broad test work when the change is low risk.

## Output Format

Use code-review format:

- Findings first, ordered by severity.
- Include file and line references when available.
- Keep summaries short and secondary.
- If there are no blocking findings, say so clearly and list residual risks or test gaps.

Finding shape:

```text
- [P1] Short issue title
  File/line. Explain the concrete failure mode, when it happens, and what should change.
```

Severity:

- `P0`: breaks build, data loss, security, payment, or critical production flow
- `P1`: likely user-visible bug or serious maintainability problem
- `P2`: moderate maintainability, testability, or edge-case risk
- `P3`: small cleanup or readability improvement

## Decision Rules

When reviewing a long implementation:

1. preserve behavior first
2. remove needless layers second
3. reduce duplication third
4. keep names domain-specific
5. keep public APIs small
6. prefer existing project patterns
7. validate the smallest risky surface
8. prefer private declarations unless public access is required
9. prefer `GetView` and focused `Obx` for ordinary GetX views
10. remove forwarding functions that do not add meaning

Do not request a rewrite just to make code shorter. Request simplification only when it makes the code easier to understand without weakening behavior, output quality, or future maintenance.

## External Criteria Notes

The HauTV Flutter Senior Review skill has useful review prompts for GetX architecture, null safety, lifecycle cleanup, widget extraction, and logging. Adopt those ideas with project judgment, not as unconditional blockers.

Adjust these strict rules before applying them:

- "always use `firstOrNull`, `lastOrNull`, `whereOrNull`": prefer safe alternatives, but note Dart/package APIs vary; `firstWhereOrNull` is common from `collection`, while `whereOrNull` is not the usual API.
- "all async operations need try-catch": require explicit handling at the right boundary, not repetitive catches everywhere.
- "no hardcoded numbers": design tokens should replace repeated UI values, but one-off values can be acceptable when they are local and self-explanatory.
- "controllers use `Get.context`": avoid context in controllers where possible; keep UI effects close to the view or a dedicated UI-feedback service.
