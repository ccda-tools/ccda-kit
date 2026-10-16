# React Native

React Native bindings for `ccda-kit`.

This package exposes a JavaScript and TypeScript surface backed by the native Swift and Kotlin C-CDA parsers. It does not introduce another parser implementation.

## Status

This is the initial React Native foundation:

- TypeScript models matching the normalized Apple and Android document shape.
- Native `parseXml` and `parseFile` bridge methods.
- Android native module backed by `android/ccda-engine`.
- iOS native module backed by `CCDAEngine`.
- Lightweight React Native rendering components for parsed documents.
- A flattened `FlatList` document renderer for virtualized section, entry, and media rows.

Native UI wrappers can be added later, but the first surface keeps rendering optional and host-app owned.

The default renderer uses one `FlatList` for the document tree. It preserves native document, section, entry, and media order while avoiding a nested list for each section. Custom section renderers own their complete section subtree, matching the composable renderer boundary on Apple and Android.

Default components follow the [shared UI theme](../docs/ui-theme-guide.md): teal
document headers, indigo patient and entry accents, warm attachment rows,
8-point corners, and grouped section panels. Header metadata and patient fields
are labeled; clinical timestamps preserve source precision and offsets, and
numeric values include their units. `CCDATheme` and `useCCDATheme()` are exported
for host apps that want matching colors. Both document components and the
example app follow the system's light or dark appearance. Images render inline,
and PDF, text, and HTML attachment buttons open native in-app previews. Hosts
can replace the attachment UI with `renderMedia` or handle taps with `onOpenMedia`.

## Install

```bash
npm install @ccda-tools/react-native
```

### iOS

The iOS bridge imports `CCDAEngine` from the published Swift package. Add the
library's helper near the top of your app's `ios/Podfile` (Node resolution also
supports hoisted dependencies):

```ruby
require Pod::Executable.execute_command('node', ['-p',
  'require.resolve("@ccda-tools/react-native/ios/ccda_pods.rb", {paths: [process.argv[1]]})',
  __dir__]).strip
```

Then call it in your existing `post_install` block, after
`react_native_post_install`:

```ruby
post_install do |installer|
  react_native_post_install(installer, config[:reactNativePath])
  ccda_post_install(installer)
end
```

Run `bundle exec pod install` from `ios/`. The helper adds
`https://github.com/ccda-tools/ccda-swift.git` to the generated Pods project,
pins it to the npm package's exact release version, links `CCDAEngine` to the
bridge target, and configures its Swift module search path. No manual Xcode
package setup is needed. Xcode resolves/downloads the Swift package during
package resolution or the next build; `pod install` configures the reference.
The matching Swift release must already be published.

The host receives the engine through the bridge; do not also link it directly
to the app. Remove any previous manual engine wiring from the Podfile when
adopting the helper. Monorepo development can pass
`engine_path: File.expand_path('/path/to/apple')` to use local source, as the
example does explicitly. Local source is never selected automatically.
An explicit `engine_version: '1.0.0'` selects a different published release for
compatibility testing. iOS 16 or newer is required.

### Android

Published apps consume the Android engine from Maven Central:

```kotlin
repositories {
    google()
    mavenCentral()
}
```

The library always declares a Maven dependency. The monorepo example supplies
its own Gradle dependency substitution for local development; the library does
not detect or select local projects.
Android requires API 26 or newer, compile SDK 35 or newer, Java 17, and Kotlin
2.0.21 or newer to consume the native engine artifacts. The example uses Gradle
8.9 and Android Gradle Plugin 8.7.3. The
default engine dependency uses the npm package's coordinated release version;
hosts can override it with the root Gradle `ccdaKitVersion` property. The matching
engine version must be publicly available on Maven Central before consumption.

## Usage

```tsx
import { CCDADocumentView, parseCCDAFile, parseCCDAXml } from '@ccda-tools/react-native';

const document = await parseCCDAFile('/path/to/document.xml');
const sameDocument = await parseCCDAXml(xmlString);

export function CCDAScreen() {
  return <CCDADocumentView document={document} />;
}
```

## API

### Customize rendering

Use the default `CCDADocumentView` or replace any document area with
`renderHeader`, `renderPatient`, `renderSection`, `renderEntry`, and `renderMedia`.
Each callback receives its parsed model and returns a React node; returning
`null` hides that area. Omitted callbacks use the built-in components.
`renderPatient` is only called when the document contains a patient.

```tsx
import { Text, View } from 'react-native';
import { CCDADocumentView, type CCDADocument } from '@ccda-tools/react-native';

export function CustomDocument({ document }: { document: CCDADocument }) {
  return (
    <CCDADocumentView
      document={document}
      renderHeader={header => (
        <View>
          <Text>{header.title ?? 'Clinical document'}</Text>
          <Text>{header.documentId.stringValue}</Text>
        </View>
      )}
      renderPatient={patient => (
        <Text>{[...(patient.name?.given ?? []), patient.name?.family].filter(Boolean).join(' ') || 'Unknown patient'}</Text>
      )}
    />
  );
}
```

The host owns spacing and styling inside a custom header or patient renderer.
The document remains one virtualized list. A custom section renderer owns its
entire section subtree, including entries and media; entry and media callbacks
are used for sections that keep the default renderer. `CCDADocumentViewProps`
is exported for typed host wrappers. Apps building their entire UI can use the
parser APIs directly without using `CCDADocumentView`.

### Parsing

```ts
parseCCDAXml(xml: string): Promise<CCDADocument>
parseCCDAFile(path: string): Promise<CCDADocument>
```

`parseCCDAFile` accepts a plain file path or a `file://` URI.
Both parsing functions accept an optional `CCDAParseOptions` argument for media
storage policy and cache directory. File selection, content-URI access, and
copying an imported document into app-accessible storage belong to the host app.

### Attachment previews

`CCDADocumentView` and standalone `CCDAMediaRow` components provide inline image
thumbnails and attachment actions. Their default action calls
`openCCDAMedia(media): Promise<void>`, which presents an in-app preview with a
Close button. iOS uses native image and WebKit views; Android uses native image,
text, WebView, and PDF rendering. Android previews the first PDF page, matching
the native Compose component; iOS supports scrolling through the PDF.
Cached files and inline base64 payloads are supported. Unsupported types and
unavailable payloads remain informational unless a host supplies its own handler.
Opening errors appear below the attachment action so it can be retried.

```tsx
<CCDADocumentView document={document} onOpenMedia={media => showYourPreview(media)} />
```

For standalone rows use `onOpen`; `renderMedia` owns all rendering and interaction
when supplied. The promise from `openCCDAMedia` resolves once the preview is
presented. Reinstall pods and rebuild the app after updating native bridge code;
Metro reload alone cannot add native preview methods.

## Development

The intended package layout is:

```text
react-native/
  src/      # JavaScript and TypeScript package surface
  ios/      # Bridge to the native Swift implementation
  android/  # Bridge to the native Kotlin implementation
  example/  # Example React Native application
```

React Native development and pull requests remain in the `ccda-kit` monorepo. A separate source repository is not required.

## Tests

Install the package dependencies and run the Jest suite:

```bash
npm install
npm test
```

The tests cover native bridge forwarding and failures, normalized document fixtures, virtualized row ordering, nested entry rendering, and host-owned renderer hooks.
See [Library testing](TESTING.md) for library-only unit tests, light/dark component
snapshots, large-input checks, and opt-in native bridge suites. Native suites
require a separate authorized build and simulator/device run.
Run `npm run typecheck` to check the public types and `npm run build` to compile
the package when builds are permitted. PR checks also
test and bundle the example and build its native iOS and Android targets.

Release publishing is handled by `.github/workflows/publish-react-native.yml`. The central release workflow passes its coordinated tag and publishes with the repository `NPM_TOKEN` secret.

## Example App

The runnable example lives under [`example/`](example/README.md). It uses the
local React Native wrapper with example-owned native engine overrides by
default. Set `CCDA_EXAMPLE_ENGINE_SOURCE=published` to exercise the published
native engines pinned in `example/engine-version.json`. PR CI checks both modes.
The example and its overrides are excluded from the npm package.
