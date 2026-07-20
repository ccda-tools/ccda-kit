# ccda-swift

Native Swift tools for parsing and rendering C-CDA documents on iOS, iPadOS, and macOS.

This directory is developed in the [`ccda-tools/ccda-kit`](https://github.com/ccda-tools/ccda-kit) monorepo and published as the generated [`ccda-tools/ccda-swift`](https://github.com/ccda-tools/ccda-swift) Swift Package Manager distribution. Changes and pull requests should be made in `ccda-kit`.

The generated distribution also includes the project changelog, license, notices, security policy, and shared test-safe C-CDA corpus.

Public products:

- `CCDAEngine`: XML parsing and normalized C-CDA models.
- `CCDAUI`: optional SwiftUI rendering helpers.

Run the package tests from the monorepo root:

```bash
swift test --package-path apple
```

The iOS example is under `Examples/iOS`.
