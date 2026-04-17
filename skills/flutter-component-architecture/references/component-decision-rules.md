# Component Decision Rules

## Core Principle

Every widget should earn its existence.

Create a new component only if it improves at least one of these:

- readability
- reuse
- testability
- API stability
- state isolation

If it improves none of them, keep the code inline.

## When To Extract

Extract a widget when:

- the parent screen becomes hard to scan
- a visual pattern repeats
- a conditional branch is complex enough to deserve a name
- a section needs its own local state
- a group of parameters naturally belongs together
- the widget may later be tested or previewed in isolation
- the page file is becoming too large to scan comfortably

## When Not To Extract

Do not extract when:

- the new widget only wraps one child without adding meaning
- the widget name would be vague like `ContentWidget` or `CustomContainer`
- the widget would be used once and adds navigation cost without clarity
- the extraction only hides hardcoded values instead of solving them
- the parent still has to know too many internal implementation details

## File Boundary Rule

Prefer one meaningful widget class per file once the widget has been promoted out of inline page structure.

Good practice:

- `profile_view.dart` contains the main screen
- `widgets/profile_header.dart` contains `ProfileHeader`
- `widgets/profile_actions.dart` contains `ProfileActions`

Avoid:

- one page file containing the screen plus many sibling widget classes after they already became conceptually separate

If a widget was worth naming, it is usually worth placing in its own file.

## Good Boundaries

Good component boundaries usually map to one of these:

- semantic UI unit
- repeated pattern
- stateful island
- reusable primitive
- feature section

Examples:

- `ProfileHeader`
- `OrderSummaryCard`
- `SearchFilterBar`
- `EmptyOrdersState`
- `SettingToggleTile`

## Bad Boundaries

Common weak boundaries:

- widgets split purely by rows and columns with no semantic meaning
- widgets extracted only because someone dislikes scrolling
- giant shared widgets with many unrelated options
- components that mix app state fetching, layout, and navigation for many features

## Shared Placement Rules

Keep a widget inside the feature when:

- its wording is feature-specific
- its state shape depends on one feature
- it has not repeated enough to prove stability

Move to shared when:

- at least two or three places use the same shape
- the API can be named without referring to a feature
- the styling aligns with the design system

## Extraction Order

When refactoring a large screen:

1. extract repeated sections
2. extract complex conditional branches
3. isolate local stateful islands
4. standardize shared patterns
5. only then consider moving components to shared folders
