# React Native

The planned React Native package will live in this directory and publish to npm.

Intended layout:

```text
react-native/
  src/      # JavaScript and TypeScript package surface
  ios/      # Bridge to the native Swift implementation
  android/  # Bridge to the native Kotlin implementation
  example/  # Example React Native application
```

React Native development and pull requests remain in the `ccda-kit` monorepo. A separate source repository is not required.
