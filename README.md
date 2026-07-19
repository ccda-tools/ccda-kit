# ccda-kit

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20iPadOS%20%7C%20macOS-blue.svg)
![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)
![Status](https://img.shields.io/badge/status-alpha-yellow.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

`ccda-kit` is an open-source toolkit for parsing C-CDA XML documents into structured models that apps can inspect, transform, and render with native UI.

C-CDA documents can be large, inconsistent, and full of nested clinical sections. This project aims to provide a practical parser layer, shared test data, and platform-native rendering helpers without forcing every app into one UI.

## Goals

- Parse C-CDA XML into stable, typed objects.
- Preserve important clinical document structure: header, patient, sections, entries, coded values, timestamps, and media.
- Keep parser logic separate from UI.
- Support custom rendering by host apps.
- Share test data and expected output across platforms.
- Optimize large documents and embedded media over time.

## Current Status

The first implementation is for Apple platforms.

Available Swift products:

- `CCDAEngine`: parser, normalized models, and engine-level errors.
- `CCDAUI`: optional SwiftUI views built on top of `CCDAEngine`.

The Swift package intentionally exposes only these two products. Repository tooling and test-data helpers are not public SwiftPM products.

Supported Apple platforms:

- iOS
- iPadOS through SwiftPM's `.iOS` platform
- macOS

Planned platforms:

- Android with Kotlin
- React Native through native iOS and Android bridges
- Flutter through native iOS and Android bridges after React Native

## Guides

- [Apple Usage Guide](docs/apple-usage.md): SwiftPM setup, parsing, XML errors, SwiftUI rendering, example app, and tests.
- [Platform Guide](docs/platform-guide.md): library philosophy, package boundaries, and Apple, Android, React Native, and Flutter direction.
- [Roadmap](docs/roadmap.md): public project direction, milestones, and release priorities.
- [Changelog](CHANGELOG.md): user-facing release history and unreleased changes.
- [Contributing Guide](CONTRIBUTING.md): local development, test expectations, and pull request notes.
- [Security Guide](SECURITY.md): security reporting and PHI handling guidance.
- [Notices](NOTICE.md): sample data sources and healthcare data warnings.

## Testing

The Apple package includes parser behavior tests, XML error tests, public model construction tests, SwiftUI helper tests, shared sample corpus checks, conformance snapshot checks, and parser performance measurements.

Testing and conformance commands are documented in [Apple Usage](docs/apple-usage.md).

## Versioning And Releases

This repository uses global semantic version tags, such as `v0.1.0`, so Swift Package Manager can resolve package versions correctly.

Pull requests that change Apple source, the iOS example, shared test data, or `Package.swift` run the Apple test workflow. After those changes merge to `main`, the release workflow runs tests again, creates the next global tag, and publishes a GitHub Release.

Release notes are generated from commits since the previous tag. Human-authored release history should be tracked in [CHANGELOG.md](CHANGELOG.md).

## Important Notes

- This library parses C-CDA XML but does not validate clinical correctness.
- This library does not guarantee regulatory compliance.
- Do not commit protected health information, real patient records, credentials, or production clinical documents.
- Sample files must be public, synthetic, or explicitly approved for test use.

## License

MIT. See [LICENSE](LICENSE).
