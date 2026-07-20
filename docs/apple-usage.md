# Apple Usage

This guide covers the current Apple implementation for iOS, iPadOS, and macOS.

## Package Setup

Add the package to your app with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ccda-tools/ccda-swift.git", from: "<latest-version>")
]
```

Use `CCDAEngine` when you only need parsing and normalized model objects:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CCDAEngine", package: "ccda-swift")
    ]
)
```

Use `CCDAUI` when you also want SwiftUI rendering helpers:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CCDAEngine", package: "ccda-swift"),
        .product(name: "CCDAUI", package: "ccda-swift")
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
let patientName = document.patient?.name
let birthDate = document.patient?.birthTime
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

`CCDAUI` formats date and time fields from parsed HL7 timestamp components. Date-only values display as dates, while values that include time components display date and time.

The engine keeps date/time fields as `CCDATimestamp?` values. Use `rawValue` when you need the original HL7 timestamp string, or the component properties when you need year, month, day, hour, minute, second, fractional second, or time zone offset.

## Render With Custom SwiftUI Components

Use `CCDAComposableDocumentView` when your app wants full control over headers, patients, sections, entries, and media.

```swift
CCDAComposableDocumentView(
    document: document,
    header: { header in
        Section {
            Text(header.title ?? "Untitled")
            Text(header.documentId.stringValue)
        }
    },
    patient: { patient in
        Section {
            Text(patient.name?.formattedName ?? "Unknown patient")
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
        CCDAMediaView(media: media)
    }
)
```

## Handle Media

C-CDA attachments are parsed from `observationMedia` entries into `CCDAMedia` values. The engine maps MIME strings into typed media cases:

- `.imagePNG`
- `.imageJPEG`
- `.imageGIF`
- `.applicationPDF`
- `.textPlain`
- `.textHTML`
- `.unsupported(String)`
- `.unknown`

By default, valid base64 media is decoded and written to a temporary cache directory so large attachments do not stay inside the parsed document model.

```swift
let engine = CCDAEngine(
    configuration: CCDAEngineConfiguration(
        mediaStoragePolicy: .cacheToDisk,
        mediaCacheDirectory: cacheDirectory
    )
)

let document = try engine.parse(url: ccdaURL)
```

Use `.inline` only when your app intentionally wants base64 payloads kept in memory:

```swift
let engine = CCDAEngine(
    configuration: CCDAEngineConfiguration(mediaStoragePolicy: .inline)
)
```

Media payloads tell you how the attachment is stored:

```swift
switch media.payload {
case .cachedFile(let url, let byteCount):
    print(url, byteCount)
case .inlineBase64:
    let data = try media.loadData()
    print(data.count)
case .unavailable:
    break
}
```

`media.loadData()` throws when cached data cannot be read or inline base64 cannot be decoded.

`CCDAUI` includes default media rendering:

- Images render inline with `CCDAMediaImageView`.
- PDF, plain text, and HTML open in `CCDAMediaWebView`.
- Unsupported or unknown attachments render as attachment rows.

For custom UI, switch on `media.mediaType` and render each case however your app wants:

```swift
switch media.mediaType {
case .imagePNG, .imageJPEG, .imageGIF:
    CCDAMediaImageView(media: media)
case .applicationPDF, .textPlain, .textHTML:
    CCDAMediaWebView(media: media)
case .unsupported(let mimeType):
    Text("Unsupported attachment: \(mimeType)")
case .unknown:
    Text("Attachment")
}
```

## Run The Example App

Open the example project:

```bash
open apple/Examples/iOS/Example.xcodeproj
```

The example app loads bundled XML files and lets you select a sample C-CDA document from a list.

## Run Tests

Run the Apple package tests from the repository root:

```bash
swift test --package-path apple
```

The test suite includes macOS 26 reference-image coverage for the default SwiftUI document renderer in light and dark appearances, nested entry rows, and media rows.
