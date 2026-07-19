# Platform Guide

`ccda-kit` is planned as a multi-platform toolkit with native parser and UI integrations per platform.

## Current Platform

Apple is the first implementation:

- `CCDAEngine`: Swift parser and normalized C-CDA model layer.
- `CCDAUI`: optional SwiftUI views built on top of `CCDAEngine`.
- `apple/Example`: iOS example app.

See [Apple Usage](apple-usage.md).

## Planned Platforms

Android:

- Native Kotlin parser.
- Native Android UI helpers.
- Shared test data from `test-data/ccda/`.

React Native:

- JavaScript/TypeScript package surface.
- Native iOS bridge backed by the Swift Apple implementation.
- Native Android bridge backed by the Kotlin Android implementation.
- React Native components for rendering parsed document structures.

Flutter:

- Dart package surface after React Native.
- Native iOS bridge backed by the Swift Apple implementation.
- Native Android bridge backed by the Kotlin Android implementation.
- Flutter widgets for rendering parsed document structures.

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
