# Changelog

All notable user-facing changes to this project should be documented here.

This project follows semantic versioning before and after `1.0.0`, with the expectation that breaking changes may still happen during early `0.x` releases.

## Unreleased

### Added

- Initial Android Kotlin implementation with parser models, media handling, Jetpack Compose rendering helpers, sample app, and unit coverage against shared C-CDA fixtures.
- SwiftUI snapshot coverage for default document rendering in light and dark appearances, nested entries, and media rows.

### Changed

- Moved the Swift package manifest and iOS example under the platform-owned `apple/` directory.
- Prepared the Apple subtree for generated SwiftPM distribution while keeping Android, React Native, and Flutter publishing in the monorepo.
- Coordinated toolkit and Swift distribution tags through GitHub Actions without package-owned release scripts.

### Fixed

- Nothing yet.

### Notes

- Do not include protected health information or real patient records in changelog entries.

## 0.1.0 - 2026-07-19

### Added

- Initial Apple package with `CCDAEngine` and `CCDAUI` SwiftPM products.
- C-CDA parser for document headers, patient demographics, sections, entries, coded values, timestamps, and media.
- Component-based HL7 timestamp parsing with SwiftUI formatting that avoids inventing missing time values.
- Common C-CDA section kind mapping through `CCDASectionKind`.
- Cache-backed media extraction for inline base64 `observationMedia` values.
- Default and composable SwiftUI document rendering helpers.
- iOS example app under `examples/ios`.
- Shared C-CDA sample corpus under `test-data/ccda`.
- Conformance-style expected parser output checks.
- Parser performance tests.
- Public initializers for engine model construction.
- Public documentation for Apple usage, parser behavior, media handling, roadmap, security, contribution, and notices.
- Pull request workflow for Apple changes.
- Release workflow and scripts for tested merges to `main`.

### Notes

- This release is an early Apple-focused alpha.
- The parser does not validate clinical correctness, full C-CDA conformance, or regulatory compliance.
- The current parser uses an internal DOM; streaming parsing is planned for a later iteration.
