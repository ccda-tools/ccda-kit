# Apple

Native Swift tools for parsing and rendering C-CDA documents on iOS, iPadOS, and macOS.

This directory is developed in the [`ccda-tools/ccda-kit`](https://github.com/ccda-tools/ccda-kit) monorepo and published as the generated [`ccda-tools/ccda-swift`](https://github.com/ccda-tools/ccda-swift) Swift Package Manager distribution. Changes and pull requests should be made in `ccda-kit`.

The generated distribution also includes the project changelog, license, notices, security policy, and shared test-safe C-CDA corpus.

## Products

- `CCDAEngine`: XML parsing and normalized C-CDA models.
- `CCDAUI`: optional SwiftUI rendering helpers.

## Package Setup

Add the package to your app with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ccda-tools/ccda-swift.git", from: "<latest-version>")
]
```

### Engine Only

Use `CCDAEngine` when your app only needs parsing and normalized model objects:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CCDAEngine", package: "ccda-swift")
    ]
)
```

Then parse C-CDA XML:

```swift
import CCDAEngine

let document = try CCDAEngine().parse(url: ccdaURL)
let sections = document.sections
```

### Engine With SwiftUI

Use `CCDAUI` when your app also wants the default SwiftUI document renderer and formatting helpers. `CCDAUI` depends on `CCDAEngine`, but listing both products makes the dependency boundary clear:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CCDAEngine", package: "ccda-swift"),
        .product(name: "CCDAUI", package: "ccda-swift")
    ]
)
```

Then render a parsed document:

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

Or provide an `InputStream` directly:

```swift
let stream = InputStream(url: ccdaURL)!
let document = try CCDAEngine().parse(stream: stream)
```

When parsing `Data`, the engine writes the bytes to a temporary file and then uses the same stream-backed parser path as file URLs. During parsing, document-level metadata is retained separately and each structured body section is mapped as its XML subtree closes, so media in that section can be cached before the parser moves to the next section.

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

The UI test target currently covers view construction and formatting helpers. Pixel snapshot coverage can be added later once the default Apple and Android UI designs stabilize together.
