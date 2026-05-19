# Flutter Theme Blueprint

Use this structure when the app needs a clean, scalable UI foundation.

## Recommended Files

```text
lib/
  app/
    design_system/
      foundations/
        colors.dart
        typography.dart
        spacing.dart
        radius.dart
        elevations.dart
        theme/
          app_theme.dart
          app_text_theme.dart
          app_theme_extensions.dart
      components/
        buttons/
        inputs/
        feedback/
        surfaces/
test/
  design_system/
    buttons_golden_test.dart
    inputs_golden_test.dart
  goldens/
```

The exact paths can change to match the repo, but keep the responsibilities separated. The important rule is that the design system lives at app level, not inside a feature.

## Token Strategy

Use:

- `ColorScheme` for color roles
- `TextTheme` for typography
- `ThemeExtension` for custom spacing, radius, component dimensions, or stateful tokens
- app-level base components built on top of those foundations

Avoid:

- placing every token into global top-level constants with no theme access path
- feature modules defining their own competing spacing scales
- feature folders owning the app's base button, input, dialog, or snackbar components
- overriding Flutter defaults such as `AppBar.toolbarHeight` just to make every dimension tokenized
- public token names without `///` comments explaining the concrete value and intended use

## Example

This example is a minimal implementation shape, not the entire token catalog. Keep `design-system-rules.md` as the source of truth for approved values, and add documented tokens when a project needs values such as `0` or `40`.

```dart
@immutable
class Spacing extends ThemeExtension<Spacing> {
  const Spacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  /// 4dp. Tiny internal adjustment only.
  final double xxs;

  /// 8dp. Default tight gap between related elements.
  final double xs;

  /// 16dp. Default component padding and stack gap.
  final double sm;

  /// 24dp. Section padding or spacious component interior.
  final double md;

  /// 32dp. Page-level separation.
  final double lg;

  /// 48dp. Large page-level separation.
  final double xl;

  /// 64dp. Extra-large page-level separation.
  final double xxl;

  @override
  Spacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return Spacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  Spacing lerp(ThemeExtension<Spacing>? other, double t) {
    if (other is! Spacing) return this;
    return Spacing(
      xxs: lerpDouble(xxs, other.xxs, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
    );
  }
}
```

Typical mapping:

- `xxs = 4`
- `xs = 8`
- `sm = 16`
- `md = 24`
- `lg = 32`
- `xl = 48`
- `xxl = 64`

Usage:

```dart
final spacing = Theme.of(context).extension<Spacing>()!;

Padding(
  padding: EdgeInsets.all(spacing.md),
  child: SizedBox(height: spacing.sm),
)
```

## Practical Conventions

- Use `const` widgets aggressively when possible
- Prefer `EdgeInsets.symmetric(horizontal: spacing.sm)` for the common 16dp screen padding, or `spacing.md` for wider 24dp layouts
- Prefer extracting repeated layout blocks into widgets before they spread to many screens
- Keep one place where default card radius and content padding are defined
- Keep base components such as `PrimaryButton`, `SecondaryButton`, `AppTextField`, `SearchBar`, `AppCheckbox`, `AppDialog`, and `Skeleton` under `app/design_system/components/`
- Keep Flutter's default `AppBar` height unless the product design explicitly needs a custom toolbar height
- Add `///` comments to every public token, base component, and public design-system enum so generated docs and IDE hover explain intent
- Add focused golden tests for stable base components and update golden baselines only after visual review

## Component Promotion Rule

Promote a component into `app/design_system/components/` when it meets most of these conditions:

- it represents part of the app's base visual language
- it is reusable across multiple screens or features
- its API can be named semantically without feature terms
- its behavior and visual contract are stable enough to become a foundation

Do not promote a component when:

- it still contains feature wording or business logic
- it is only used once
- its API is unstable or still changing rapidly
- moving it would turn the design system into a dumping ground for miscellaneous widgets

The design system should contain foundational components, not every widget that happens to be reusable once.

## Refactor Order

When cleaning an inconsistent app:

1. normalize colors
2. normalize typography
3. normalize spacing and radius
4. extract repeated shared widgets
5. clean one feature area at a time

This order reduces churn and avoids fighting the whole codebase at once.
