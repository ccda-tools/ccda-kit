# Android

The planned native Android implementation will live in this directory and publish compiled libraries as Maven artifacts.

Intended layout:

```text
android/
  ccda-engine/   # Kotlin parser and normalized models
  ccda-ui/       # Android and Jetpack Compose presentation helpers
  examples/app/  # Example Android application
```

Android development and pull requests remain in the `ccda-kit` monorepo. A separate Android source repository is not required.
