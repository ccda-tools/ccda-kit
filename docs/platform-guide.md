# Platform Guide

`ccda-kit` is planned as a multi-platform toolkit with native parser and UI integrations per platform.

## Library Philosophy

`ccda-kit` is built around a strict separation between parsing, normalized data, and presentation.

The parser layer should understand C-CDA XML and produce stable model objects. It should preserve source meaning, avoid UI dependencies, expose useful structured data, and keep enough raw source detail for host apps that need it. Anything related to SwiftUI, UIKit, Android views, React components, or Flutter widgets should stay out of the parser layer.

The UI layer should be optional. Default views should make parsed documents easy to inspect, but host apps should always be able to replace every header, patient, section, entry, and media renderer with their own native components.

The platform layer should feel native on each platform. Apple uses Swift and SwiftUI. Android uses Kotlin and Jetpack Compose helpers. React Native and Flutter should wrap the native Apple and Android parsers instead of adding separate parser implementations.

Shared test data should keep behavior aligned across platforms. Each parser can expose idiomatic APIs, but the same C-CDA input should produce equivalent normalized summaries wherever possible.

## What Goes Where

The Apple `CCDAEngine` product and Android `ccda-engine` module own:

- XML parsing.
- Normalized C-CDA models.
- Timestamp, code, section, entry, patient, and media data extraction.
- Engine-level errors.
- Media storage references and cache-backed payload handling.
- Search and document indexing APIs when they are added.

The Apple `CCDAUI` product and Android `ccda-compose` module own:

- SwiftUI and Jetpack Compose rendering helpers.
- Platform-specific formatting, such as names, postal addresses, values, and display timestamps.
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

Android publication surface:

- `android/ccda-engine` defines the `io.github.shahzaibiqbal.ccdakit:ccda-engine` publication.
- `android/ccda-compose` defines the `io.github.shahzaibiqbal.ccdakit:ccda-compose` publication and depends on `ccda-engine`.
- Android development, tests, and releases remain in this monorepo; no separate Android source repository is required.
- Release signing uses `MAVEN_SIGNING_KEY` and `MAVEN_SIGNING_PASSWORD`. Central upload uses `MAVEN_CENTRAL_USERNAME` and `MAVEN_CENTRAL_PASSWORD`.
- The Android publisher builds and signs a Maven Central bundle, then uploads it as a user-managed deployment. A maintainer must approve a validated deployment before it becomes publicly available from Maven Central.

## Current Platforms

Apple:

- `CCDAEngine`: Swift parser and normalized C-CDA model layer.
- `CCDAUI`: optional SwiftUI views, including default image, PDF, text, and HTML media rendering.
- `apple/Examples/iOS`: iOS example app.

Android:

- Native Kotlin parser.
- Jetpack Compose UI helpers.
- Shared test data from `test-data/ccda/`.
- Gradle modules, tests, and the example app under `android/`.
- Compiled libraries packaged as Maven artifacts without requiring a separate source repository.
- Android release automation runs tests, builds the sample app, signs versioned artifacts, and uploads them for Maven Central validation and maintainer approval.

See the [Apple README](../apple/README.md) and [Android README](../android/README.md) for installation, parsing, native UI, media handling, examples, tests, and packaging.

## Planned Platforms

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
