---
version: 2.0
date: 2026-05-04
status: accepted
---

# TM HTM - tm_core Architecture

## 1. Purpose

This document replaces the previous architecture baseline for practical implementation in the current repository state.

Goals:

- Simplify the file structure.
- Align code with Clean Architecture boundaries.
- Remove technical debt that blocks feature growth.
- Establish a safe migration order.

## 2. Core Constraints

- `tm_core` remains framework-agnostic.
- Infrastructure stays inside `tm_core` for now under `lib/src/infra`.
- Expected business failures use `Result`, not `Exception` as a return value.
- Mutations go through operations and transaction port.

## 3. Target Structure

```txt
packages/tm_core/
├── lib/
│   ├── tm_core.dart
│   └── src/
│       ├── application/
│       │   ├── operations/
│       │   │   ├── operation.dart
│       │   │   ├── project/
│       │   │   └── task/
│       │   ├── queries/
│       │   │   ├── project/
│       │   │   └── task/
│       │   ├── ports/
│       │   ├── repositories/
│       │   └── services/
│       ├── domain/
│       │   ├── entities/
│       │   ├── events/
│       │   ├── exceptions/
│       │   ├── guards/
│       │   ├── results/
│       │   ├── services/
│       │   ├── utils/
│       │   └── value_objects/
│       ├── di/
│       └── infra/
│           ├── events/
│           ├── repositories/
│           └── tracing/
├── test/
│   ├── integration/
│   ├── unit/
│   └── fixtures/
└── example/
```

## 4. Layer Rules

1. `domain` has no dependency on `infra`.
2. `application` depends on `domain` contracts and models.
3. `infra` implements `application` ports.
4. `di` wires concrete implementations.

## 5. Immediate Technical Corrections

Priority P0:

1. Move `operations` under `application/operations`.
2. Move `domain/queries` to `application/queries`.
3. Move `exceptions` under `domain/exceptions`.
4. Introduce `domain/results/result.dart` and migrate operations from `Object` returns.
5. Align `DomainEventBus` contract with implementations.

Priority P1:

1. Normalize value object API symmetry (`raw`, validation shape).
2. Remove runtime-unsafe reference getters that throw on normal access.
3. Fill or narrow repository methods currently throwing `UnimplementedError`.
4. Publish stable exports in `lib/tm_core.dart`.

Priority P2:

1. Restructure tests into unit/integration/fixtures.
2. Add baseline coverage for operations, value objects, and event bus behavior.

## 6. Migration Sequence

1. Structural migration with import fixes.
2. Contract migration (`Result`, `Operation`, `DomainEventBus`).
3. DI and public API stabilization.
4. Tests and quality gates.

## 7. Definition Of Done

- `dart analyze` passes in `packages/tm_core`.
- Core operations return `Result<Success, Failure>`.
- No expected-flow `Object` return values.
- No `UnimplementedError` in actively used repository methods.
- Public package usage works without importing from `src`.
