---
name: flutter-component-architecture
description: Design or refactor Flutter UI into maintainable components with clear boundaries, stable APIs, and practical state ownership. Use when Codex needs to split large widgets, extract reusable components, define variants, organize feature UI files, or improve composability without over-engineering.
---

# Flutter Component Architecture

## Goal

Build Flutter UI from components that are easy to read, reuse, test, and evolve.

This skill favors practical boundaries over rigid patterns. It should reduce duplication and complexity without turning the codebase into a forest of tiny meaningless widgets.

## Workflow

### 1. Inspect the current feature and widget structure first

Read only the files needed to understand the current composition:

- the target screen or widget
- nearby feature widgets in the same folder
- shared UI components under paths such as `lib/widgets/`, `lib/shared/`, `lib/core/widgets/`, `lib/design_system/`
- state management files used by the screen such as provider, bloc, cubit, notifier, controller, or view model

Use fast searches first:

```bash
rg -n "build\\(BuildContext|ConsumerWidget|HookConsumerWidget|BlocBuilder|BlocConsumer|ValueListenableBuilder|StreamBuilder|FutureBuilder|setState\\(|copyWith\\("
```

Decide which case applies:

- If the screen is large but mostly unique, extract structure-first subwidgets without forcing reuse.
- If the same UI pattern repeats across features, extract a shared component.
- If state and UI are tangled, separate state ownership before expanding reuse.

### 2. Split widgets by responsibility, not by line count alone

Extract a widget when it has one or more of these properties:

- repeated in multiple places
- has a clear visual role such as card, tile, section header, filter chip, form field, or empty state
- has a stable input API
- can be reasoned about independently
- makes the parent screen noticeably easier to scan

Do not extract a widget just because the file is long if the extraction creates meaningless names or prop drilling without benefit.

Once a widget has been extracted and has a clear identity, give it its own file. Do not keep accumulating many widget classes in the page file after the split already happened.

Read [references/component-decision-rules.md](references/component-decision-rules.md) for the extraction rules.

### 3. Keep state ownership close to the feature boundary

Prefer this rule:

- shared app state lives in the chosen state-management layer
- screen-level orchestration stays in the screen
- reusable presentational components stay mostly stateless
- ephemeral visual state stays local when it does not matter outside the component

Examples of local ephemeral state:

- password visibility
- hover or pressed styling
- expanded or collapsed section
- tab selection inside a self-contained widget

Do not push every boolean into bloc, provider, or notifier just for purity.

### 4. Design component APIs around intent

Prefer semantic parameters over style leakage.

Prefer:

- `title`
- `subtitle`
- `leading`
- `trailing`
- `onTap`
- `isSelected`
- `variant`
- `size`

Avoid:

- passing ten raw paddings and colors into each widget
- boolean soup such as `isPrimary`, `isLarge`, `hasBorder`, `isRounded`, `useShadow`
- exposing internal layout details in public APIs

If a component has multiple looks, use a small variant model instead of many unrelated flags.

Read [references/component-api-patterns.md](references/component-api-patterns.md) for common API shapes.

### 5. Prefer composition over inheritance and giant base widgets

Use:

- child slots
- leading and trailing slots
- small helper widgets
- builders only when dynamic rendering actually needs them

Avoid:

- abstract UI base classes for ordinary widgets
- monolithic "AppCard/AppButton/AppInput" that try to solve every possible use case in one file
- deep wrapper chains that hide simple layout

Shared components should feel narrow and intentional.

### 6. Organize files by feature first, then shared layer

Prefer this order:

1. keep feature-specific widgets inside the feature
2. move widgets to shared only after repetition is proven
3. keep design-system primitives separate from product-specific shared widgets

Typical layers:

- feature screen
- feature-only subwidgets
- shared product widgets
- design system primitives

Within a feature, extracted UI pieces should usually live under `widgets/`.

Do not move a widget to `shared/` just because two files use it once.

### 7. Build screen trees that are easy to scan

A good screen file should read like structure and orchestration, not low-level decoration.

The screen should usually contain:

- layout skeleton
- wiring to state
- navigation and callbacks
- high-level section composition

The screen should usually not contain:

- repeated tile markup
- repeated styling literals
- deeply nested conditional rendering blocks when a dedicated widget would clarify intent
- many standalone widget classes piled into the same file

As a practical heuristic, if a UI file grows beyond roughly `300` lines, review whether the structure should be split into dedicated widget files.

### 8. Validate before finishing

Before wrapping up:

- check whether each extracted widget has a clear reason to exist
- check whether shared widgets are truly shared
- check whether state ownership is sensible
- check whether the public API is smaller and clearer than before
- check whether extracted widgets were moved into their own files
- check whether any file now contains too many classes
- remove dead wrappers or premature abstractions
- run the smallest useful validation set

Typical commands:

```bash
dart format <changed-files>
dart analyze
flutter test
```

If full validation cannot run, report exactly what was and was not validated.

## Output Expectations

When using this skill, finish with a short summary that includes:

- which widget boundaries changed
- whether state ownership was clarified
- which reusable components were introduced or avoided
- whether any shared API or variant model was standardized
- any remaining architectural debt

## Heuristics

- Extract for clarity first, reuse second.
- Reuse only after a shape proves stable.
- Keep widget APIs small and semantic.
- Prefer local state for local behavior.
- A shared component should remove duplication, not just move it.
