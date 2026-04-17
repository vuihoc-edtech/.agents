# FlutterGen Asset Rules

## Core Principle

Asset paths should be generated, not handwritten.

Use `flutter_gen` so asset, font, and related references are strongly typed and refactor-safe.

## Package Rule

Prefer:

- `flutter_gen_runner` in `dev_dependencies`
- generated files produced by `build_runner`

The package documentation describes FlutterGen as a code generator to get rid of string-based APIs for assets, fonts, colors, and more.

## Source of Truth

Declare assets and fonts in `pubspec.yaml`.

Then generate code and consume only the generated APIs.

Do not:

- keep parallel manual constants for asset paths
- write raw `assets/...` strings throughout the app
- let feature widgets invent their own path conventions

## Asset Format Rule

Prefer asset formats that help reduce bundle size and keep rendering predictable.

Use:

- `svg` for icons, simple illustrations, and other vector-friendly assets
- `webp` for raster images such as banners, photos, thumbnails, and marketing graphics

Why:

- `svg` keeps vector assets scalable and usually smaller than shipping multiple raster sizes
- `webp` is often a better default than `png` or `jpg` for app image size optimization

Avoid:

- using large PNG files for assets that could be vector
- exporting every illustration as raster by default
- keeping legacy image formats when a smaller `webp` version is available and visually acceptable

Use judgment:

- photos and textured images are usually better as `webp`
- icons and flat illustrations are usually better as `svg`
- if an asset has rendering issues as SVG, fall back to raster intentionally rather than by habit

When a project needs batch conversion from PNG to WebP, use the bundled script:

```bash
scripts/png_to_webp.sh <file-or-directory> [quality]
```

This script keeps the original PNG files and writes sibling `.webp` files. It prefers `cwebp` and falls back to ImageMagick `magick`.

## Preferred Usage

Prefer:

```dart
Assets.images.logo.image()
Assets.icons.close.svg()
Assets.images.homeBanner.path
```

Avoid:

```dart
Image.asset('assets/images/logo.png')
SvgPicture.asset('assets/icons/close.svg')
const logoPath = 'assets/images/logo.png';
```

## Generation Rule

Use `build_runner` so generated files stay in sync:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This aligns with FlutterGen's documented `build_runner` workflow.

## Placement Rule

Prefer the generated output under a stable folder such as:

- `lib/gen/`
- `app/gen/`

Import generated assets from there instead of recreating wrappers in each feature.

## Decision Rule

When unsure:

1. declare the asset in `pubspec.yaml`
2. prefer `svg` for vector assets and `webp` for raster assets
3. generate accessors with `flutter_gen`
4. use the generated API in widgets and theme code
5. only fall back to raw paths if a library integration truly requires it
