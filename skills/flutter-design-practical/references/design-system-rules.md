# Design System Rules

## Core Principle

Use an 8pt spacing rhythm as the default layout language. Use 4dp only for tight micro-adjustments.

This keeps the UI calm, professional, and predictable while avoiding the random spacing that often makes AI-generated interfaces look fake.

Prefer Flutter and Material defaults before adding custom dimensions. Override framework defaults only when the product design needs it and the reason is documented.

Public design-system APIs must include `///` doc comments. A developer reading `spacing.xs` or `radius.md` should be able to hover and see the concrete value and intended use.

Stable base components should have golden coverage so visual changes are visible during review. Keep golden tests focused on the design-system surface rather than every feature-only widget.

## Project Style Reference: Pidu Learning English

When this skill is used in the `learning_english` app, match the Pidu preview screenshots in `/screenshots` before falling back to generic defaults.

Reference lookup:

- `pidu-ui-kit-cover.png`: overall brand direction, green hero, playful education mood.
- `style-guide-colors-typography-course-card.png`: color, typography, radius, and course-card base style.
- `component-card-controls-overview.png`: modal, button, reward, room, progress, and lesson-card components.
- `mascot-set-overview.png`: rounded mascot/avatar language and soft mint panels.
- `app-workflow-screens-overview.png`: real screen density, tab treatment, benefit cards, and bottom navigation.
- `screen-collage-50-plus.png`: broad screen inventory and repeated visual patterns.
- `hero-learning-english-exercise.png`: app hero, exercise surface, and large green background arcs.
- `style-guide-feature-highlights.png`: feature stat cards and white rounded surface rhythm.

Extracted Pidu base style:

- Background: very light mint (`#F2FCF8`) rather than pure white.
- Primary: vivid green (`#1CC874`) with darker green (`#119E5C`) for headers, tabs, and emphasis.
- Surfaces: white cards over mint background with subtle `#E7EFEA` borders and very soft green shadows.
- Accent colors: orange (`#FF8A2A`) for progress and secondary CTAs, yellow (`#FDB72C`) for reward/gift states, pink (`#F25B9A`), purple (`#8C70E8`), and blue (`#2F9BEF`) for playful learning categories.
- Typography: rounded, friendly, heavy headings in a Fredoka-like style; body text stays compact and readable.
- Radius: soft consumer-app shapes dominate. Use 16dp for normal cards, 24dp for prominent panels, and pill radius for CTAs/chips.
- Components: primary buttons are green pills with soft shadow and small white gloss marks; implement those marks with a static `CustomPainter` in the base button rather than stacking decorative widgets in every caller. Secondary buttons use pale mint; reward/watch CTAs are orange; status chips are compact rounded pills; course and benefit cards are white, spacious, and lightly outlined.
- Illustration language: simple rounded mascot shapes and learning objects, not abstract gradients or AI-looking decoration.

## Spacing Scale

Default spacing scale:

- `0`
- `4`
- `8`
- `16`
- `24`
- `32`
- `40`
- `48`
- `64`

Practical usage:

- `4`: tiny internal adjustment only
- `8`, `16`: default component padding and stack gaps
- `24`: section padding, card interior spacing
- `32`, `40`, `48`, `64`: page-level spacing and large empty space

Rules:

- Never use odd values for layout spacing tokens.
- Avoid `6`, `10`, `12`, `14`, `18`, `20`, `22` unless an existing system already depends on them and a migration is out of scope.
- Prefer `8`, `16`, `24`, `32` as the dominant rhythm of the app.
- Prefer fewer spacing values used consistently over a mathematically complete scale.
- If a project intentionally uses intermediate values such as `12`, document them in the token comments and use them consistently instead of mixing ad-hoc literals.

## Border Radius Scale

Approved radius scale:

- `0`
- `4`
- `8`
- `12`
- `16`
- `24`
- `999`

Practical usage:

- `4`: dense chips, tiny tags, compact fields
- `8`: default buttons, inputs, cards in compact systems
- `12`: modern default for cards, sheets, inputs in consumer apps
- `16`: large cards, prominent containers, bottom sheets
- `24`: highly rounded panels
- `999`: pill, capsule, avatar masks

Rules:

- Do not use arbitrary values like `7`, `10`, `14`, `18` unless the system already defines them.
- Pick one default radius for primary surfaces and one secondary radius for larger surfaces.
- Most apps work well with `8` and `12` as the default pair, or `12` and `16` for softer consumer UI.
- If boxes are visually nested, keep radii mathematically concentric: inner radius should usually equal outer radius minus the surrounding padding.

## Border and Elevation

Approved border widths:

- `1`
- `2`

Use `1` by default. Use `2` only when contrast or emphasis needs it.

Elevation rules:

- prefer subtle elevation
- use border plus surface contrast before adding heavy shadows
- keep the number of shadow presets small
- do not use large hand-made shadows by default
- prefer `Material` elevation or extremely soft shadows only when hierarchy truly needs them
- if using `BoxShadow`, keep it extremely restrained: small blur, no exaggerated spread, very low alpha

## Component Heights

Recommended interactive heights:

- `32`: dense controls only
- `40`: compact but usable
- `48`: default tap target
- `56`: prominent CTA or input

Rules:

- Keep touch targets at or above `44`, preferably `48`
- Avoid visually tiny controls even if the content technically fits
- Do not redefine Flutter defaults such as `AppBar.toolbarHeight` unless the product design specifically requires a custom height
- Prefer built-in Material component sizing and density before introducing app-specific height tokens

## Icon Sizes

Approved icon sizes:

- `16`
- `20`
- `24`
- `32`

Use `24` as the default action icon size.

## Typography

Recommended mobile text scale:

- `12`: helper or caption
- `14`: secondary body, label
- `16`: default body
- `20`: section title
- `24`: screen title
- `32`: large display

Rules:

- Keep body text readable before making it stylish
- Use consistent line height, usually around `1.3` to `1.5`
- Avoid many near-duplicate sizes such as `15`, `17`, `19`, `23`
- prioritize clarity and reading comfort over display-like decoration

## Color System

Use semantic roles instead of raw color names:

- `primary`
- `onPrimary`
- `secondary`
- `background`
- `surface`
- `surfaceContainer`
- `outline`
- `error`
- `warning`
- `success`

Rules:

- Avoid hardcoding hex values in leaf widgets
- Use role-based colors so light and dark themes remain possible
- Favor contrast and hierarchy over decoration
- avoid neon, cyber, and loud gradient treatments unless they are core to the product direction
- ensure text and background contrast remains accessible

## Layout Rules

- Default screen horizontal padding is usually `16`
- Use `24` when the layout needs more breathing room or on tablet-width containers
- Keep lists and forms aligned to the same horizontal rhythm
- A screen should usually have one dominant visual rhythm, not many unrelated ones
- prioritize content over framing; remove borders and background panels that do not improve comprehension

## Component Composition Rules

- Avoid "container hell": do not stack more than two decorative `Container` layers without a specific visual reason.
- Prefer `Padding`, `SizedBox`, `Divider`, `Row`, `Column`, and slivers for structure.
- Prefer semantic Flutter widgets such as `Card`, `CircleAvatar`, `AppBar`, `ListTile`, `TextButton`, and `IconButton`.
- If app-wide visual consistency is required, build base components in the design system and consume those instead of rebuilding styled containers in feature code.
- Split complex UI sections into `StatelessWidget` components so the screen remains readable and maintainable.

## Golden Test Rules

Use golden tests for:

- design-system buttons, inputs, dialogs, snackbars, bottom sheets, cards, skeletons, and reusable surface primitives
- theme changes that affect many components
- component states such as default, disabled, loading, error, selected, focused, and long text when those states are part of the public visual contract

Avoid golden tests for:

- one-off feature widgets whose layout is still changing rapidly
- screens with volatile network images, clocks, random data, animations, or platform-specific rendering unless they are stabilized in the test
- behavior that is better covered by widget tests or unit tests

Golden test discipline:

- wrap the component in a stable test app/theme
- use deterministic fonts, text, sizes, and surface constraints
- prefer testing base component states together in one compact catalog when it improves review
- update goldens only when the visual change is intentional and has been reviewed
- keep golden files near the relevant test folder using a predictable path such as `test/goldens/`

## Decision Rules

When unsure:

1. pick the nearest approved token
2. prefer consistency over local perfection
3. add a new token only if the value repeats or carries semantic meaning
4. preserve Flutter defaults unless there is a product reason to override them
5. document public token values with `///` comments
6. add golden coverage for stable base components with public visual contracts
