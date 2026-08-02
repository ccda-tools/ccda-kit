# Roadmap

This roadmap describes the public direction for `ccda-kit`. It is intentionally high level and may change as the parser matures.

## Project Direction

`ccda-kit` aims to provide native tools for parsing and rendering C-CDA documents across mobile platforms.

The project is organized around three principles:

- Parser logic should be independent from UI.
- Host applications should be able to render clinical data with their own native components.
- Platform implementations should be validated against shared sample data and expected parser output.

## Current Status

The first implementations are available for Apple and Android platforms:

- `CCDAEngine`: Swift parser, normalized models, media extraction, timestamps, and engine-level errors.
- `CCDAUI`: optional SwiftUI views and Apple-specific formatting helpers.
- `apple/Examples/iOS`: iOS example app using shared sample data.
- `android/ccda-engine`: Kotlin parser and normalized model layer.
- `android/ccda-compose`: optional Jetpack Compose rendering helpers.
- `android/sample-app`: Android example app using shared sample data.

## Current Limitations

- `ccda-kit` parses C-CDA XML but is not a clinical validator.
- `ccda-kit` does not perform full C-CDA conformance validation.
- The current parser is stream-backed and maps structured body sections as each section closes; extremely large individual sections and inline media can still be memory-heavy.
- Current media handling is basic and focuses on inline base64 `observationMedia`.
- Shared test data must remain public, synthetic, or explicitly approved for test use; real PHI must never be committed.

## Prioritized Milestones

### 1. Release Polish

- Keep Apple and Android public APIs stable enough for early adopters.
- Keep README badges, platform guides, changelog, and release notes aligned with published versions.
- Continue validating both platforms against the shared sample corpus before each release.

### 2. Cross-Platform UI Testing

- Add snapshot or golden tests for default Apple and Android document, section, entry, and media rendering once the shared UI theme stabilizes.
- Cover representative light and dark appearances and supported mobile layouts where practical.
- Use public, synthetic, and test-safe fixtures so UI changes can be reviewed without exposing PHI.
- Keep parser, conformance, and performance test suites passing while visual coverage is added.

### 3. React Native

- Provide a JavaScript and TypeScript package surface backed by the native Swift and Kotlin implementations.
- Add native iOS and Android bridges instead of introducing another parser implementation.
- Provide React Native components for rendering parsed document structures.

### 4. Flutter

- Provide a Dart package surface and Flutter widgets backed by the native Swift and Kotlin implementations.
- Reuse the native iOS and Android parsers instead of introducing another parser implementation.
- Validate Flutter behavior with the same shared fixtures and normalized expectations.

### 5. Further Capabilities

After the initial Apple, Android, React Native, and Flutter foundations are in place, continue with:

- Search APIs across headers, patients, sections, narrative text, codes, values, timestamps, and media metadata.
- Structured search results that identify the matched document area while remaining independent from UI layers.
- Larger synthetic fixtures and performance baselines for very large documents.
- Configurable media policies, cache lifecycle APIs, referenced external media, and additional attachment types.
- Expanded parsing coverage for common C-CDA sections, entries, and vendor-specific XML.
- More section-specific typed clinical models and DocC generation as public APIs stabilize.
- Continued growth of public, synthetic, and test-safe sample coverage.

## Shared Validation

All platform implementations should use the shared test fixtures under `test-data/ccda/`.

The goal is for each platform parser to produce equivalent normalized summaries for the same C-CDA inputs, while still allowing each platform to expose idiomatic native APIs and UI components.
