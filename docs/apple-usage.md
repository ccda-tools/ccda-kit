# Apple Usage

This guide covers the current Apple implementation for iOS, iPadOS, and macOS.

## Package Setup

Add the package to your app with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/shahzaibiqbal/ccda-kit.git", branch: "main")
]
```

Use `CCDAEngine` when you only need parsing and normalized model objects:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CCDAEngine", package: "ccda-kit")
    ]
)
```

Use `CCDAUI` when you also want SwiftUI rendering helpers:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CCDAEngine", package: "ccda-kit"),
        .product(name: "CCDAUI", package: "ccda-kit")
    ]
)
```

Swift Package Manager uses `.iOS` for iPhone and iPad, so iPadOS support is covered by the iOS platform declaration.

## Parse XML

```swift
import CCDAEngine

let engine = CCDAEngine()
let document = try engine.parse(url: ccdaURL)

let title = document.header.title
let patientName = document.patient?.name?.display
let sections = document.sections
```

You can also parse in-memory data:

```swift
let document = try CCDAEngine().parse(data: xmlData)
```

## Handle XML Errors

`CCDAEngine` keeps XML failures under one error case and includes parser context.

```swift
do {
    let document = try CCDAEngine().parse(url: ccdaURL)
    print(document)
} catch CCDAEngineError.invalidXML(let failure) {
    print(failure.message)
    print(failure.lineNumber as Any)
    print(failure.columnNumber as Any)
    print(failure.sourceDescription as Any)
} catch {
    print(error.localizedDescription)
}
```

## Render With Default SwiftUI

```swift
import SwiftUI
import CCDAEngine
import CCDAUI

struct CCDAScreen: View {
    let document: CCDADocument

    var body: some View {
        CCDADocumentView(document: document)
    }
}
```

## Render With Custom SwiftUI Components

Use `CCDAComposableDocumentView` when your app wants full control over headers, patients, sections, entries, and media.

```swift
CCDAComposableDocumentView(
    document: document,
    header: { header in
        Section {
            Text(header.title ?? "Untitled")
            Text(header.documentId.display)
        }
    },
    patient: { patient in
        Section {
            Text(patient.name?.display ?? "Unknown patient")
        }
    },
    section: { section, entryView, mediaView in
        Section {
            Text(section.narrativeText)

            ForEach(section.entries) { entry in
                entryView(entry)
            }

            ForEach(section.media) { media in
                mediaView(media)
            }
        } header: {
            Text(section.title ?? section.code?.displayName ?? "Section")
        }
    },
    entry: { entry in
        CCDAEntryRow(entry: entry)
    },
    media: { media in
        CCDAMediaImageView(media: media)
    }
)
```

## Run The Example App

Open the example project:

```bash
open apple/Example/Example.xcodeproj
```

The example app loads bundled XML files and lets you select a sample C-CDA document from a list.

## Run Tests

Run the Apple package tests from the repository root:

```bash
swift test
```

Regenerate expected parser summaries after intentional parser behavior changes:

```bash
swift run CCDAConformanceGenerator
```
