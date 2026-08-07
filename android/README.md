# Android

The native Android implementation lives in this directory.

## Requirements

- Android API 26 or newer
- Android compile SDK 35
- Java 17
- Kotlin 2.0.21

Current layout:

```text
android/
  ccda-engine/   # Kotlin parser and normalized models
  ccda-compose/  # Optional Jetpack Compose presentation helpers
  sample-app/    # Example Android application
```

The engine follows the same source organization as the Apple package:

```text
ccda-engine/src/main/kotlin/com/ccdakit/engine/
  Media/
  Models/
  Parsing/
  XML/
```

Android development and pull requests remain in the `ccda-kit` monorepo. A separate Android source repository is not required.

## Gradle Setup

Published Android artifacts are consumed from Maven Central. Replace `<latest-version>` in the examples below with a version that has been published; coordinates do not resolve until their first Maven Central release is approved.

In your app's repository settings, include Maven Central:

```kotlin
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
```

### Engine Only

Use `ccda-engine` when your app only needs parsing and normalized model objects:

```kotlin
dependencies {
    implementation("io.github.shahzaibiqbal.ccdakit:ccda-engine:<latest-version>")
}
```

Parse a C-CDA file or stream:

```kotlin
import com.ccdakit.engine.CCDAEngine

val document = CCDAEngine().parse(ccdaFile)
val sections = document.sections
```

You can also parse bytes or an `InputStream`:

```kotlin
val fromBytes = CCDAEngine().parse(ccdaBytes)
val fromStream = ccdaFile.inputStream().use { stream ->
    CCDAEngine().parse(stream)
}
```

When parsing a `ByteArray`, the engine writes the bytes to a temporary file and then uses the same stream-backed parser path as files. During parsing, document-level metadata is retained separately and each structured body section is mapped from a section-scoped XML subtree.

### Engine With Compose UI

Use `ccda-compose` when your app also wants default Jetpack Compose rendering helpers. `ccda-compose` depends on `ccda-engine`, so most apps only need the UI artifact:

```kotlin
dependencies {
    implementation("io.github.shahzaibiqbal.ccdakit:ccda-compose:<latest-version>")
}
```

Render a parsed document:

```kotlin
import androidx.compose.runtime.Composable
import com.ccdakit.compose.CCDADocumentView
import com.ccdakit.engine.CCDADocument

@Composable
fun CCDAScreen(document: CCDADocument) {
    CCDADocumentView(document = document)
}
```

The Compose module formats parsed HL7 timestamps according to their source precision. A date-only timestamp displays as a date, while a timestamp containing time components displays both date and time. The engine preserves the original value in `CCDATimestamp.rawValue` and exposes its parsed year, month, day, hour, minute, second, fractional-second, and time-zone components.

## Parse XML

```kotlin
import com.ccdakit.engine.CCDAEngine

val engine = CCDAEngine()
val document = engine.parse(ccdaFile)

val title = document.header.title
val patientName = document.patient?.name
val birthDate = document.patient?.birthTime
val sections = document.sections
```

The engine accepts a `File`, `ByteArray`, or `InputStream`. The caller retains ownership of an `InputStream` and should close it, normally with `use`.

## Handle XML Errors

`CCDAEngine` reports malformed or unreadable XML as `CCDAEngineException.InvalidXml`, including parser location and source information when available:

```kotlin
import com.ccdakit.engine.CCDAEngine
import com.ccdakit.engine.CCDAEngineException

try {
    val document = CCDAEngine().parse(ccdaFile)
    println(document)
} catch (error: CCDAEngineException.InvalidXml) {
    println(error.failure.message)
    println(error.failure.lineNumber)
    println(error.failure.columnNumber)
    println(error.failure.sourceDescription)
}
```

## Render With Custom Compose Components

Use `CCDAComposableDocumentView` when the host app needs control over headers, patients, sections, entries, and media:

```kotlin
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import com.ccdakit.compose.CCDAComposableDocumentView
import com.ccdakit.compose.CCDAEntryRow
import com.ccdakit.compose.CCDAMediaView
import com.ccdakit.compose.CCDASectionView
import com.ccdakit.engine.CCDADocument

@Composable
fun CustomCCDAScreen(document: CCDADocument) {
    CCDAComposableDocumentView(
        document = document,
        header = { header ->
            Text(header.title ?: "Untitled document")
        },
        patient = { patient ->
            Text(patient.name?.family ?: "Unknown patient")
        },
        section = { section, entry, media ->
            CCDASectionView(section = section, entry = entry, media = media)
        },
        entry = { entry ->
            CCDAEntryRow(entry)
        },
        media = { media ->
            CCDAMediaView(media)
        },
    )
}
```

## Handle Media

C-CDA `observationMedia` entries are mapped to `CCDAMedia`. Supported media types are PNG, JPEG, GIF, PDF, plain text, and HTML. Unsupported MIME values are preserved in `CCDAMediaType.Unsupported`; missing MIME values use `CCDAMediaType.Unknown`.

By default, valid base64 payloads are decoded into the system temporary cache directory:

```kotlin
import com.ccdakit.engine.CCDAEngine
import com.ccdakit.engine.CCDAEngineConfiguration
import com.ccdakit.engine.CCDAMediaStoragePolicy
import java.io.File

val engine = CCDAEngine(
    configuration = CCDAEngineConfiguration(
        mediaStoragePolicy = CCDAMediaStoragePolicy.CacheToDisk,
        mediaCacheDirectory = File(cacheDirectory, "ccda-media"),
    ),
)
```

Use inline storage only when the app intentionally wants base64 payloads retained in memory:

```kotlin
val engine = CCDAEngine(
    configuration = CCDAEngineConfiguration(
        mediaStoragePolicy = CCDAMediaStoragePolicy.Inline,
        mediaCacheDirectory = null,
    ),
)
```

Inspect or load a media payload with:

```kotlin
import com.ccdakit.engine.CCDAMediaPayload

when (val payload = media.payload) {
    is CCDAMediaPayload.CachedFile -> println(payload.file)
    is CCDAMediaPayload.InlineBase64 -> println(media.loadData().size)
    CCDAMediaPayload.Unavailable -> println("Payload unavailable")
}
```

`media.loadData()` returns decoded bytes and throws `CCDAMediaPayloadException` when the payload is unavailable or invalid.

`CCDADocumentView` accepts an `onOpenMedia` callback. Apps can use it to present the built-in full-screen preview:

```kotlin
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.ccdakit.compose.CCDADocumentView
import com.ccdakit.compose.CCDAMediaPreview
import com.ccdakit.engine.CCDAMedia

var previewMedia by remember { mutableStateOf<CCDAMedia?>(null) }

CCDADocumentView(
    document = document,
    onOpenMedia = { previewMedia = it },
)

previewMedia?.let { media ->
    CCDAMediaPreview(
        media = media,
        onDismiss = { previewMedia = null },
    )
}
```

The preview renders images, the first page of a PDF, plain text, and HTML. Unsupported or unavailable media displays attachment details.

If you are working inside this monorepo or testing unreleased changes locally, use project dependencies like the sample app:

```kotlin
dependencies {
    implementation(project(":ccda-engine"))
    implementation(project(":ccda-compose"))
}
```

## Boundaries

- `ccda-engine` contains parser logic and models only.
- `ccda-compose` contains Android-specific formatting and Compose UI.
- `sample-app` demonstrates loading shared C-CDA XML samples and rendering parsed documents.

## Run The Example App

Open the `android/` directory in Android Studio and run the `sample-app` configuration. The app loads shared XML fixtures and lets you select and render a sample document.

Build its debug APK from the repository root with:

```bash
cd android
./gradlew :sample-app:assembleDebug
```

## Run Tests

From this directory:

```bash
./gradlew test
```

The engine tests reuse shared samples from `../test-data/ccda`.

The test suite covers parser mapping, XML errors, public model construction, timestamps, media behavior, formatting helpers, and shared expected-output conformance.

## Package

Android artifacts are versioned from the central release workflow and generated directly from this monorepo:

```bash
./gradlew publishReleasePublicationToLocalReleaseRepository -PVERSION_NAME=<version>
```

This produces Maven-style artifacts for:

- `io.github.shahzaibiqbal.ccdakit:ccda-engine`
- `io.github.shahzaibiqbal.ccdakit:ccda-compose`

The release workflow signs these artifacts, uploads a deployment bundle to Maven Central for validation, and retains the Maven repository as a GitHub Actions build artifact. A maintainer reviews the validated deployment in the [Central Publisher Portal](https://central.sonatype.com/publishing/deployments) before publishing it. Maven Central releases are immutable, so fixes require a new version.
