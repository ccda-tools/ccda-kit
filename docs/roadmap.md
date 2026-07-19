# Roadmap

This roadmap describes the public direction for `ccda-kit`. It is intentionally high level and may change as the parser matures.

## Project Direction

`ccda-kit` aims to provide native tools for parsing and rendering C-CDA documents across mobile platforms.

The project is organized around three principles:

- Parser logic should be independent from UI.
- Host applications should be able to render clinical data with their own native components.
- Platform implementations should be validated against shared sample data and expected parser output.

## Current Status

The first implementation is focused on Apple platforms:

- `CCDAEngine`: Swift parser, normalized models, media extraction, timestamps, and engine-level errors.
- `CCDAUI`: optional SwiftUI views and Apple-specific formatting helpers.
- `examples/ios`: iOS example app using shared sample data.

## Current Limitations

- `ccda-kit` parses C-CDA XML but is not a clinical validator.
- `ccda-kit` does not perform full C-CDA conformance validation.
- The current parser builds an internal DOM and is not streaming-first yet.
- Current media handling is basic and focuses on inline base64 `observationMedia`.
- Shared test data must remain public, synthetic, or explicitly approved for test use; real PHI must never be committed.

## Next Apple Work

- Expand parsing coverage for common C-CDA sections and entries.
- Harden parser behavior around malformed, incomplete, and vendor-specific XML.
- Add search APIs over a parsed `CCDADocument`.
- Continue growing public, synthetic, and test-safe sample coverage.

## Later Apple Iterations

Search:

- Search across header, patient, section titles, narrative text, entry codes, entry values, timestamps, and media metadata.
- Return structured search results that identify the matched document area.
- Keep search independent from `CCDAUI`.

Large files:

- Move toward streaming XML parsing for very large C-CDA documents.
- Add larger synthetic performance fixtures and baseline performance tests.

Media:

- Add configurable media policies for ignoring media, capturing metadata only, caching media to disk, or keeping small media inline up to a caller-defined size.
- Add media cache cleanup and lifecycle APIs.
- Support referenced external media in addition to inline base64 media.
- Decide the supported behavior for audio, video, and opaque binary attachments.

Typed models and UI:

- Add more section-specific typed clinical models.
- Add DocC generation when the public API stabilizes.
- Add snapshot or visual tests for default UI rendering.

## Multi-Platform Direction

Android is planned as a native Kotlin implementation that follows the same parser concepts and shared test-data expectations as Apple.

React Native is planned as a JavaScript and TypeScript package backed by the native Apple and Android parsers. It should not introduce a third parser implementation.

Flutter is planned after React Native, using Dart APIs and Flutter widgets backed by the native Apple and Android parser implementations.

## Shared Validation

All platform implementations should use the shared test fixtures under `test-data/ccda/`.

The goal is for each platform parser to produce equivalent normalized summaries for the same C-CDA inputs, while still allowing each platform to expose idiomatic native APIs and UI components.
