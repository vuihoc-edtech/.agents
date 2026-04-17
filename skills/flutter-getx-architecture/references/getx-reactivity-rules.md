# GetX Reactivity Rules

## Core Principle

Reactive state should be intentional and narrow. Rebuild only what needs to change.

## Use `GetBuilder` When

Use `GetBuilder` when:

- state changes are grouped
- rebuilds can happen in one bounded widget region
- you want explicit `update()` control
- the UI does not need every field to be independently reactive

This is often a good default for screen sections.

## Use `Obx` When

Use `Obx` when:

- a small piece of state changes independently
- the UI benefits from direct reactive reads
- the rebuild surface is small and obvious

Examples:

- loading spinner visibility
- selected chip state
- cart badge count
- password visibility

## Avoid Over-Reactivity

Avoid:

- marking every field with `.obs`
- wrapping a whole `Scaffold` in `Obx`
- multiple nested `Obx` builders for the same state
- using reactive state where a local `StatefulWidget` would be simpler

## Workers

Use workers such as `ever`, `once`, `debounce`, and `interval` for side-effect coordination when they simplify intent.

Typical cases:

- search query debounce
- reacting to auth state changes
- analytics events tied to state transitions

Rules:

- register workers in the controller
- dispose them in `onClose` when needed
- do not hide core business rules inside opaque worker chains

## Decision Rule

When unsure:

1. start with the smallest non-reactive or minimally reactive approach
2. use `GetBuilder` for grouped UI refresh
3. use `Obx` for fine-grained independent values
4. use local widget state if the behavior is purely presentational
