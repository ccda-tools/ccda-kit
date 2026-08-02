# Android

The native Android implementation lives in this directory.

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

Published Android artifacts are intended to be consumed from Maven repositories.

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

## Test

From this directory:

```bash
./gradlew test
```

The engine tests reuse shared samples from `../test-data/ccda`.

## Package

Android artifacts are versioned from the central release workflow and generated directly from this monorepo:

```bash
./gradlew publishReleasePublicationToLocalReleaseRepository -PVERSION_NAME=<version>
```

This produces Maven-style artifacts for:

- `io.github.shahzaibiqbal.ccdakit:ccda-engine`
- `io.github.shahzaibiqbal.ccdakit:ccda-compose`

The current workflow uploads those artifacts as release build outputs. A future Maven Central upload step can use the same Gradle publications once signing and repository credentials are configured.
