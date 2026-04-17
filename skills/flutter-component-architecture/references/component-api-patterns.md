# Component API Patterns

## Core Principle

Component APIs should expose intent, not implementation noise.

## Preferred Parameter Shapes

Prefer semantic inputs:

- `title`
- `subtitle`
- `caption`
- `value`
- `status`
- `variant`
- `size`
- `enabled`
- `selected`
- `loading`
- `onTap`
- `onChanged`
- `leading`
- `trailing`
- `child`

These make call sites readable and keep layout choices internal.

## Variant Model

When a component has a few stable visual modes, prefer an enum or sealed model.

Example:

```dart
enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  ghost,
}
```

Prefer this over many flags like:

```dart
AppButton(
  isPrimary: true,
  hasOutline: false,
  isDanger: false,
  transparent: false,
)
```

## Slot-Based Composition

Use slots when the component structure is stable but some regions vary.

Common slots:

- `leading`
- `trailing`
- `header`
- `footer`
- `actions`
- `child`

Example:

```dart
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
}
```

## Local State Pattern

If a widget owns purely local interaction state, keep it inside the widget.

Examples:

- show or hide password
- expand or collapse FAQ item
- switch selected tab inside a self-contained component

Do not leak this state upward unless another component or business rule needs it.

## Async and State-Managed UI

Keep business state outside reusable presentational widgets.

Prefer:

- `UserSummaryCard(user: user, onTap: ...)`

Avoid:

- `UserSummaryCard(userId: id)` when the component also fetches, loads, retries, and navigates unless that is the explicit architecture of the feature

## Naming Rules

Good names describe role:

- `AccountInfoSection`
- `NotificationPreferenceTile`
- `ProductPriceBadge`
- `CheckoutFooter`

Weak names describe shape or generic intent:

- `CustomWidget`
- `CommonContainer`
- `InfoView`
- `DataCardWidget`

## API Smells

Refactor when you see:

- too many optional booleans
- many style parameters leaked publicly
- parent code passing colors, padding, radius, icon sizes, and text styles every time
- callback names that do not describe user intent
- null-heavy constructors that imply too many modes

## Decision Rule

When unsure:

1. start with the smallest semantic API
2. keep styling internal
3. add parameters only after a real second use case appears
