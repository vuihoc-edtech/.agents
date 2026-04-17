# Local Storage Rules

## Core Principle

Choose local storage by data shape and growth risk, not by convenience.

Within this architecture, prefer only these two options by default:

- `shared_preferences`
- `realm`

## Use `shared_preferences` When

Use `shared_preferences` for small, stable key-value data such as:

- onboarding completion flags
- locale or theme preference
- small feature toggles
- tiny primitive counters or timestamps

Prefer the newer package APIs for new code:

- `SharedPreferencesAsync`
- `SharedPreferencesWithCache`

The package documentation describes `shared_preferences` as persistent storage for simple key-value pairs and notes that cache-based APIs have tradeoffs. That makes it a poor fit for large, evolving user datasets.

If the app uses `get_it` or `injectable`, the shared preferences abstraction can be pre-resolved during app bootstrap so settings access is available immediately. This is acceptable for a small app-level settings service.

## Avoid Overusing `shared_preferences`

Avoid using `shared_preferences` for:

- large JSON strings
- growing arrays of user content
- lists of objects
- draft systems
- history, feed, or offline domain data

As an architectural inference, overusing `shared_preferences` increases cache and initialization overhead, which can hurt startup behavior and waste memory for data that should live in a real local database.

Also note that the official plugin states it should not be used for critical data.

Pre-resolving one small preferences service is reasonable. Pre-resolving large amounts of preference-backed state at startup is not.

## Use `realm` When

Use `realm` for:

- structured local user data
- offline-first or cached user content
- dynamic models that may grow over time
- object collections that need filtering or richer queries
- local data that changes frequently

Realm is explicitly positioned as a mobile database and an alternative to key-value stores, which makes it the better default for non-trivial local datasets.

## Decision Rule

When unsure:

1. if the data is a few simple settings or flags, use `shared_preferences`
2. if the data belongs to user content, models, or collections, use `realm`
3. if the data may expand later, choose `realm` early instead of migrating late

## Suggested Placement

Prefer:

- `app/storage/preferences/` for `shared_preferences` wrappers
- `app/storage/realm/` for Realm config, schemas, and stores

Do not read and write preference keys all over the app. Wrap storage access behind small services or repositories.

## DI Rule

If the project already uses `get_it` for bootstrap composition, it is acceptable to register a preferences service as a pre-resolved dependency there.

If the project uses GetX as the main composition root, keep the boundary explicit:

- use `get_it` only for app bootstrap if the project already depends on it
- expose one small preferences service or wrapper
- keep non-GetX storage infrastructure in `get_it`
- do not register ordinary storage wrappers in GetX bindings unless they are truly GetX-specific
