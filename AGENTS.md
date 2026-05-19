# Flutter Skill Usage

This repository contains reusable Flutter skills under `skills/`.

When working in a Flutter project that includes this repository as `.agents`, use these skills when the task matches:

- `skills/flutter-getx-architecture/SKILL.md` for GetX app structure, dependency boundaries, bootstrap, API/data conventions, assets, env, storage, deep links, localization, and purchase architecture.
- `skills/flutter-design-practical/SKILL.md` for app-level design system, theme tokens, spacing, radius, typography, and visual consistency.
- `skills/flutter-component-architecture/SKILL.md` for splitting large Flutter widgets, defining component APIs, state ownership, and feature/shared component placement.
- `skills/flutter-review-code/SKILL.md` for reviewing Flutter/Dart changes, AI-generated code, readability, maintainability, unnecessary complexity, and validation gaps.

Default behavior:

- Before applying any skill, read project-root `.agents.env` once if it exists. If it does not exist, use `.agents/.agents.env.example` only as the schema/default reference.
- Apply configuration with this precedence: direct user request > project-local `AGENTS.md`/`CLAUDE.md` > project-root `.agents.env` > shared skill defaults.
- Shared skill defaults target new Flutter apps. Existing apps should add project-root `.agents.env` and set `FLUTTER_ARCHITECTURE_MODE=incremental` plus `existing` policies where needed.
- Inspect the existing project conventions before applying any skill rule.
- Keep changes scoped to the user's request.
- Use the skill rules as guidance, not permission for broad unrelated refactors.
- When reviewing code, prioritize correctness and maintainability. Prefer shorter code when it preserves behavior, quality, testability, and output.
- Only apply the full new-app architecture rules when `FLUTTER_ARCHITECTURE_MODE=strict` or the user explicitly asks to create a new app, adopt the full architecture, or enable strict architecture mode.
- If a project's local `AGENTS.md`, `CLAUDE.md`, or direct user instruction conflicts with these skills, follow the project-local/user instruction.
