# Platform Guide

`ccda-kit` is planned as a multi-platform toolkit with native parser and UI integrations per platform.

## Library Philosophy

`ccda-kit` is built around a strict separation between parsing, normalized data, and presentation.

The parser layer should understand C-CDA XML and produce stable model objects. It should preserve source meaning, avoid UI dependencies, expose useful structured data, and keep enough raw source detail for host apps that need it. Anything related to SwiftUI, UIKit, Android views, React components, or Flutter widgets should stay out of the parser layer.

The UI layer should be optional. Default views should make parsed documents easy to inspect, but host apps should always be able to replace every header, patient, section, entry, and media renderer with their own native components.

The platform layer should feel native on each platform. Apple uses Swift and SwiftUI. Android will use Kotlin and native Android UI helpers. React Native and Flutter should wrap the native Apple and Android parsers instead of adding separate parser implementations.

Shared test data should keep behavior aligned across platforms. Each parser can expose idiomatic APIs, but the same C-CDA input should produce equivalent normalized summaries wherever possible.

## What Goes Where

`CCDAEngine` owns:

- XML parsing.
- Normalized C-CDA models.
- Timestamp, code, section, entry, patient, and media data extraction.
- Engine-level errors.
- Media storage references and cache-backed payload handling.
- Search and document indexing APIs when they are added.

`CCDAUI` owns:

- SwiftUI rendering helpers.
- Apple-specific formatting, such as names, postal addresses, and display timestamps.
- Default media presentation for images, PDFs, text, and HTML.
- Composable views that let host apps provide their own native UI.

Example apps own:

- Demonstrating package usage.
- Loading bundled shared sample data.
- Showing default and custom rendering patterns.

Shared `test-data` owns:

- Public, synthetic, or approved C-CDA samples.
- Expected parser summaries used to compare behavior across platforms.

Docs own:

- Installation and usage.
- Public roadmap.
- Platform direction.
- Contribution, security, and release guidance.

SwiftPM package surface:

- `apple/Package.swift` is the source of truth for public SwiftPM products.
- Public SwiftPM products should represent supported app-facing APIs.
- Internal tools and conformance helpers should not be exposed as public SwiftPM products.
- Each Apple release exports the tracked contents of `apple/` as a linear snapshot commit in `ccda-tools/ccda-swift`; development and pull requests remain in this monorepo.
- Platform publishing uses the `CCDA_PUBLISHER_APP_ID` and `CCDA_PUBLISHER_PRIVATE_KEY` repository secrets to create short-lived GitHub App tokens. The publisher App is granted access only to generated distribution repositories such as `ccda-swift`.
- A release uses the same semantic tag name in `ccda-kit` and `ccda-swift`, even though each tag points to its repository-specific commit.
- The manually triggered central release workflow calculates the version; reusable platform workflows receive it as an input and do not calculate their own versions.

## Current Platform

Apple is the first implementation:

- `CCDAEngine`: Swift parser and normalized C-CDA model layer.
- `CCDAUI`: optional SwiftUI views, including default image, PDF, text, and HTML media rendering.
- `apple/Examples/iOS`: iOS example app.

See [Apple Usage](apple-usage.md).

## Planned Platforms

Android:

- Native Kotlin parser.
- Native Android UI helpers.
- Shared test data from `test-data/ccda/`.
- Gradle modules, tests, and the example app under `android/`.
- Compiled libraries published as Maven artifacts without requiring a separate source repository.

React Native:

- JavaScript/TypeScript package surface.
- Native iOS bridge backed by the Swift Apple implementation.
- Native Android bridge backed by the Kotlin Android implementation.
- React Native components for rendering parsed document structures.
- Package source and its example under `react-native/`, published to npm.

Flutter:

- Dart package surface after React Native.
- Native iOS bridge backed by the Swift Apple implementation.
- Native Android bridge backed by the Kotlin Android implementation.
- Flutter widgets for rendering parsed document structures.
- Package source and its example under `flutter/`, published directly to pub.dev.

## Shared Test Data

All platforms should use the same sample inputs and expected parser summaries:

```text
test-data/
  ccda/
    samples/
      *.xml
    expected-output/
      *.json
```

This keeps parser behavior comparable across Swift, Kotlin, React Native, and Flutter implementations.
