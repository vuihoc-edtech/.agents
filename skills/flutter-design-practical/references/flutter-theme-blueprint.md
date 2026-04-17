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

## Example

```dart
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  @override
  AppSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
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
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
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

- `xxs = 2`
- `xs = 4`
- `sm = 8`
- `md = 12`
- `lg = 16`
- `xl = 24`
- `xxl = 32`

Usage:

```dart
final spacing = Theme.of(context).extension<AppSpacing>()!;

Padding(
  padding: EdgeInsets.all(spacing.lg),
  child: SizedBox(height: spacing.sm),
)
```

## Practical Conventions

- Use `const` widgets aggressively when possible
- Prefer `EdgeInsets.symmetric(horizontal: spacing.lg)` over repeating literals
- Prefer extracting repeated layout blocks into widgets before they spread to many screens
- Keep one place where default card radius and content padding are defined
- Keep base components such as `PrimaryButton`, `SecondaryButton`, `AppTextField`, `SearchBar`, `AppCheckbox`, `AppDialog`, and `Skeleton` under `app/design_system/components/`

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
