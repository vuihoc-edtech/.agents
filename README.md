# Flutter Skills

This repository contains reusable skills and architecture rules for Flutter projects, including structure, design system, localization, deep linking, storage, bootstrap, and coding conventions.

Available skills:

- `flutter-getx-architecture`: GetX architecture, bootstrap, DI, API/data, storage, env, assets, deep links, localization.
- `flutter-design-practical`: design-system-first Flutter UI, tokens, theme, spacing, radius, typography, visual consistency.
- `flutter-component-architecture`: Flutter widget/component boundaries, APIs, state ownership, feature/shared placement.
- `flutter-review-code`: Flutter/Dart code review for correctness, readability, maintainability, AI code bloat, and validation gaps.

## Usage with `git submodule`

Inside your Flutter project, add this repository under `.agents`:

```bash
git submodule add git@github.com:vuihoc-edtech/.agents.git .agents
```

Then initialize and update the submodule:

```bash
git submodule update --init --recursive
```

If you clone a project that already includes the submodule:

```bash
git clone --recurse-submodules <your-flutter-project-git>
```

Or, if you already cloned the project:

```bash
git submodule update --init --recursive
```

## Updating the Skills

Go into the submodule and pull the latest changes:

```bash
cd .agents
git pull origin main
```

Then return to the Flutter project and commit the updated submodule reference:

```bash
cd ..
git add .agents
git commit -m "chore: update flutter skills submodule"
```

## Recommended Structure

```text
your_flutter_project/
  AGENTS.md
  CLAUDE.md
  .agents/
  lib/
  pubspec.yaml
```

Because this repository is usually mounted as `.agents`, add a small bridge file
at the root of each Flutter project so agents can discover the shared skills.

Suggested `AGENTS.md`:

```md
# Project Agent Instructions

Use shared Flutter skills from `.agents/skills/` when the task matches.
Read `.agents.env` once before applying shared skill rules if the file exists.
Start with `.agents/AGENTS.md`, then load only the relevant skill files.
Project-local instructions and direct user requests take precedence.
```

Suggested `CLAUDE.md`:

```md
# Project Claude Instructions

Use shared Flutter skills from `.agents/skills/` when the task matches.
Read `.agents.env` once before applying shared skill rules if the file exists.
Start with `.agents/CLAUDE.md`, then load only the relevant skill files.
Project-local instructions and direct user requests take precedence.
```

## Project Skill Configuration

Copy `.agents/.agents.env.example` to `.agents.env` at the Flutter project root
when a project needs stable defaults. The shared default targets new apps.

```bash
cp .agents/.agents.env.example .agents.env
```

Default for a new app:

```env
FLUTTER_ARCHITECTURE_MODE=strict
FLUTTER_API_STACK=retrofit_json_result_dart
FLUTTER_STORAGE_POLICY=shared_preferences_realm
FLUTTER_DESIGN_SYSTEM=create
FLUTTER_COMPONENT_PROMOTION=promote_base_primitives
FLUTTER_LOCALIZATION_POLICY=app_en_arb_arb_translate
FLUTTER_ASSET_POLICY=flutter_gen
```

For an existing app, configure `.agents.env` explicitly:

```env
FLUTTER_ARCHITECTURE_MODE=incremental
FLUTTER_API_STACK=existing
FLUTTER_STORAGE_POLICY=existing
FLUTTER_DESIGN_SYSTEM=existing
FLUTTER_COMPONENT_PROMOTION=conservative
FLUTTER_LOCALIZATION_POLICY=existing
FLUTTER_ASSET_POLICY=existing
```

Precedence:

```text
direct user request > project AGENTS.md/CLAUDE.md > .agents.env > shared skill defaults
```

## Notes

- Use this repository as a shared source of skills and rules across multiple Flutter projects.
- Keep `.agents` at the project root for easier management.
- When new rules or skills are added, update the submodule to sync them into the project.
- One major advantage of using `git submodule` is that you can improve the skills while working inside a real project, push those changes back to the shared repository, and then sync the same improvements across other projects.
