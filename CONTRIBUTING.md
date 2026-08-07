# Contributing

Thanks for helping improve `ccda-kit`.

## Development Principles

- Keep parsing logic separate from UI.
- Keep SwiftUI optional.
- Avoid committing PHI or real patient data.
- Prefer public/synthetic C-CDA fixtures.
- Add tests for parser behavior changes.
- Keep platform implementations aligned through shared fixtures and conformance expectations.

## Local Development

Run Swift package tests:

```bash
swift test --package-path apple
```

Regenerate conformance output after intentional parser behavior changes:

```bash
swift run --package-path apple CCDAConformanceGenerator
```

Shared C-CDA test files live under `test-data/ccda/samples/`, and expected parser summaries live under `test-data/ccda/expected-output/`.

Run a syntax check:

```bash
swiftc -parse apple/Sources/CCDAEngine/Models/*.swift apple/Sources/CCDAEngine/Parsing/*.swift apple/Sources/CCDAEngine/XML/*.swift apple/Sources/CCDAUI/Views/*.swift
```

## Pull Requests

Before opening a PR:

- Add or update tests.
- Update docs when public APIs change.
- Avoid unrelated formatting churn.
- Confirm no generated files are included.

## Sample Files

Sample documents must be public, synthetic, or explicitly approved for testing. Never add real clinical documents.
