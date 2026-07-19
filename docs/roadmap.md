# Roadmap

This roadmap describes the public direction for `ccda-kit`. It is intentionally high level and may change as the parser matures and more real-world C-CDA samples are tested.

## Project Direction

`ccda-kit` aims to provide native tools for parsing and rendering C-CDA documents across mobile platforms.

The project is organized around three principles:

- Parser logic should be independent from UI.
- Host applications should be able to render clinical data with their own native components.
- Platform implementations should be validated against shared sample data and expected parser output.

## Current Focus

The first milestone is the Apple implementation.

Current Apple modules:

- `CCDAEngine`: Swift parser, normalized models, and engine-level errors.
- `CCDAUI`: optional SwiftUI views for default and composable rendering.

Current test coverage includes:

- Minimal C-CDA parsing.
- Shared sample corpus parsing.
- XML parser error details.
- Conformance snapshot checks.
- Parser performance measurements.

## Near-Term Priorities

Planned Apple work:

- Expand parsing coverage for common C-CDA sections and entries.
- Improve media handling for embedded and referenced content.
- Add cache-backed media references for large documents.
- Continue growing public, synthetic, and test-safe sample coverage.
- Harden parser behavior around malformed, incomplete, and vendor-specific XML.
- Improve API documentation before the first tagged release.

## Multi-Platform Direction

Android is planned as a native Kotlin implementation that follows the same parser concepts and shared test-data expectations as Apple.

React Native is planned as a JavaScript and TypeScript package backed by the native Apple and Android parsers. It should not introduce a third parser implementation.

Flutter is planned after React Native, using Dart APIs and Flutter widgets backed by the native Apple and Android parser implementations.

## Shared Validation

All platform implementations should use the shared test fixtures under `test-data/ccda/`.

The goal is for each platform parser to produce equivalent normalized summaries for the same C-CDA inputs, while still allowing each platform to expose idiomatic native APIs and UI components.

## Release Goals

Before a first stable release, the project should have:

- Documented public APIs.
- Clear install and usage guides.
- A stable parser model for core document data.
- Robust XML error reporting.
- Media handling that avoids unnecessary memory pressure.
- Cross-sample conformance tests.
- PHI-safe sample data policy.
