# Worker Manager Rules

## Core Principle

Use `worker_manager` only for compute work heavy enough to justify isolate management.

The package is designed for CPU-intensive calculations across isolates and emphasizes reusable isolates over always spawning a new one.

## Use `worker_manager` When

Use it when:

- a computation is heavy enough to threaten frame rendering
- the task runs often enough that isolate reuse matters
- there is repeated parsing, transformation, crypto, compression, or image processing
- plain async code would still leave expensive work on the main isolate

## Do Not Use It When

Avoid it when:

- the task is small
- the work is infrequent
- the cost of serialization and isolate coordination would outweigh the benefit
- a normal async call is already fast enough

For many small tasks, keeping the code simple is the better engineering decision.

## Practical Rule

Prefer this order:

1. keep work synchronous if it is trivial
2. use normal async code for ordinary I/O
3. use `worker_manager` for repeated CPU-bound work that can cause UI jank

## Function Rule

The package documentation notes that functions passed to workers should be static, top-level, or otherwise accessible to isolates.

Design worker tasks to be:

- pure or nearly pure
- serializable
- independent from widget tree state

## Suggested Placement

Prefer:

- `app/workers/` for reusable worker task definitions
- repositories or services delegating heavy compute to workers when needed

Do not let controllers own complex worker orchestration unless the task is tightly coupled to one screen and remains simple.

## Decision Rule

When unsure:

1. measure or identify whether the task is actually heavy
2. if the work is small, do not use `worker_manager`
3. if the work is repeated and CPU-heavy, introduce `worker_manager`
4. keep the worker boundary narrow and explicit
