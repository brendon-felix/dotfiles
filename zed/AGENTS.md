# AGENTS.md

This project (or set of projects) should favor clear, idiomatic, correctness-oriented code with as little incidental complexity as possible.

## Core Principles

- Prefer correctness by construction over correctness by testing.
- Encode invariants in types and state transitions wherever practical.
- Make invalid states difficult or impossible to represent.
- Prefer small, comprehensible functions, methods, modules, and types.
- Keep context close to the code that needs it.
- Optimize for readability without being unnecessarily verbose.
- Prefer concise, precise names over long explanatory ones.
- Avoid cleverness that obscures intent, but concise and stylish code is welcome when it remains readable.

When choosing between adding explanation and improving the code so explanation is unnecessary, prefer improving the code.

## Rust

Rust is the default implementation language.

Prefer:

- algebraic data types
- explicit state machines
- newtypes where they strengthen invariants
- exhaustive matching
- ownership and borrowing that reflect actual data relationships
- iterator-based transformations
- functional and declarative code where it improves clarity
- standard-library and crate convenience methods such as `.map()`, `.and_then()`, `.filter_map()`, `.unwrap_or()`, and similar idioms
- established Rust conventions over custom abstractions
- domain types over loosely related primitive fields

Avoid:

- boolean-heavy state modeling when an enum would express the states better
- loosely defined intermediate states
- unnecessary cloning
- unnecessary mutation
- deeply nested control flow
- abstractions that exist only to make code look architecturally elaborate
- verbose code when an equally readable idiomatic expression exists

Do not prematurely generalize code. Introduce abstractions when they make the current system easier to understand or enforce meaningful invariants.

## Structure

Code should be easy to navigate without needing extensive documentation.

Prefer:

- predictable module placement
- cohesive modules with narrow responsibilities
- extracting named functions when doing so exposes meaningful intent
- keeping domain logic close to domain types
- APIs that make the correct operation obvious

Avoid large functions containing several conceptual operations. Break them apart along semantic boundaries, not merely to reduce line count.

## Comments and Documentation

Be extremely restrained with comments.

Do not add comments that restate what the code already says.

Do not add comments merely to explain straightforward control flow, variable assignments, function calls, or standard Rust idioms.

Prefer making code self-explanatory through:

- naming
- types
- function boundaries
- module structure
- explicit states

Comments are appropriate when they preserve context that cannot reasonably be expressed in code, such as:

- non-obvious external constraints
- hardware or protocol behavior
- compatibility requirements
- intentional workarounds
- reasoning behind a surprising implementation choice

Prefer explaining **why**, not **what**.

Avoid doc comments in application code unless they provide information that is genuinely useful at the API boundary. Do not mechanically document every type, field, function, or method.

## Tests

Do not create tests by default.

Prefer eliminating bug classes through type design, invariants, explicit states, and simple implementations.

Add tests when they provide meaningful protection that cannot reasonably be encoded into the design itself, especially for:

- parsers
- serialization formats
- complex algorithms
- subtle boundary conditions
- regression bugs
- externally observable behavior with multiple interacting cases

Tests should be few, focused, readable, and behavior-oriented.

Avoid:

- testing trivial getters or constructors
- mirroring implementation details
- excessive mocking
- large test matrices with little additional confidence
- tests added solely to increase coverage

A small number of high-value tests is preferable to a large test suite.

## Errors

Model expected failure explicitly when it is part of the domain.

Use `Result` and `Option` naturally rather than introducing exceptional control flow.

Prefer preserving useful error context without constructing elaborate error hierarchies unless the domain requires them.

Do not silently discard errors unless doing so is intentional and obvious.

## Dependencies

Prefer mature, idiomatic Rust crates over rebuilding common functionality.

Before introducing a dependency, consider whether:

- the standard library already handles the problem cleanly
- the crate meaningfully reduces complexity
- its API fits the surrounding code
- the dependency burden is justified

Follow existing dependency choices and project conventions where possible.

## Scripts and Tooling

Prefer Nushell for:

- scripts
- shell automation
- data manipulation
- quick calculations
- development utilities
- workflow helpers

Use Bash when required by external tooling or portability constraints.

Use Python when it is clearly better suited to the task, particularly for ecosystems or libraries where Rust/Nushell would create unnecessary friction.

