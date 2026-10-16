# C-CDA React Native Example

Runnable React Native example app for the local `@ccda-tools/react-native` package.

The app starts with the same seven-document list as the native iOS example:
Local Comprehensive Sample, Media Attachments, HL7 CCD, HL7 Discharge Summary,
HL7 Progress Note, Cerner Problems and Medications, and Transition of Care Full XML.
Tap a document to parse it through the native bridge and render it with
`CCDADocumentView`. The example uses React Navigation's native stack for the
list and document screens, with native navigation headers, iOS swipe-back, and
Android back handling. Use the navigation bar to return to the list or **Retry**
if loading fails. Routes contain only the sample filename; XML and parsed
documents stay out of navigation state.

XML is bundled directly from `../../test-data/ccda/samples/` using the example's
Metro transformer; no separate copies of the fixtures are maintained.

## Setup

From the React Native package directory:

```bash
npm install
npm run build
cd example
npm install
```

The example depends on the parent package through `file:..`, so build the parent package before installing the example.

Navigation dependencies (`@react-navigation/native`, `@react-navigation/native-stack`,
`react-native-screens`, and `react-native-safe-area-context`) belong to this
example. They are not dependencies of the `@ccda-tools/react-native` library.
Versions are pinned for the example's React Native 0.74 setup.
Adding these native dependencies requires pod installation on iOS and a new
native app build on both platforms before the navigator can run. Restarting
Metro alone is insufficient. Run those steps when you are ready to rebuild.

For iOS, install CocoaPods dependencies:

Use Ruby 3.2 or newer with Bundler 4 (CI uses Ruby 4.0).

```bash
cd ios
bundle install
bundle exec pod install --no-repo-update
cd ..
```

Use `bundle exec pod install` rather than the global `pod` command so the
project's pinned CocoaPods and JSON compatibility versions are used.

Pod installation creates an ignored `ios/.xcode.env.local` with the absolute
path to Node so builds launched from Xcode also work with nvm. Existing local
overrides are preserved. After changing or removing your Node installation,
refresh that path from a terminal where `node` works:

```bash
cd ios
ruby -rshellwords -e 'puts "export NODE_BINARY=#{Shellwords.escape(ARGV.fetch(0))}"' "$(node -p process.execPath)" > .xcode.env.local
```

By default, this example passes the local `apple/` package path to
`ccda_post_install`. Android substitutes the published engine coordinate with
the local `android/ccda-engine` project. Both overrides are explicitly configured
in this example; the library defaults to published dependencies.
The app receives the engine through the bridge's static library; linking the
engine directly to the app as well would produce duplicate symbols.
The example requires iOS 16 or newer. The Podfile applies that minimum to
pod targets as well; rerun `bundle exec pod install --no-repo-update` after
updating the Podfile to refresh the generated Pods project.

## Native dependency modes

The example always uses the local React Native wrapper (`file:..`). Native engine
selection is separate:

| Mode | iOS engine | Android engine |
| --- | --- | --- |
| `local` (default) | Local `apple/` Swift package | Local Gradle project via dependency substitution |
| `published` | Versioned `ccda-tools/ccda-swift` package | Maven Central artifact |

To check the consumer dependency setup, set this in the terminal used for pod
installation and app commands:

```bash
export CCDA_EXAMPLE_ENGINE_SOURCE=published
```

Published mode reads the same exact engine version for both platforms from
`engine-version.json` (currently `1.0.0`). This pin is independent of the
unreleased wrapper's development version. Update it only after that engine
version is available in both distribution locations. A missing release fails
resolution; it does not fall back to local source.

To return to source development:

```bash
unset CCDA_EXAMPLE_ENGINE_SOURCE
```

After switching modes, rerun pod installation for iOS and rebuild the native
app when builds are permitted. Metro reloads cannot change native dependencies.
PR CI has separate local and published jobs for both platforms. The native
Apple and Android suites validate engine source; published-mode example jobs
validate the wrapper against released engines. This does not install the wrapper
from npm; a registry smoke check remains a separate release verification step.

All example files, local paths, substitutions, and the compatibility version pin
are excluded from the npm package. Published hosts use the library defaults:
Maven Central on Android and `ccda_post_install(installer)` on iOS, both matching
the npm release version.

## Run

Start Metro in one terminal:

```bash
npm start
```

Run the app in another terminal:

```bash
npm run ios
npm run android
```

Use an iOS simulator or Android emulator/device with the normal React Native development prerequisites installed.
Android requires Java 17, SDK 35, and API 26 or newer. The example uses Android's
locally generated debug signing key; no keystore is committed.

Metro resolves the local package's React and React Native peer dependencies
from the example app to keep a single runtime. After changing Metro settings,
stop Metro and restart it with `npm start -- --reset-cache` before reloading
the app.

Attachment buttons open optional native previews. After changes under `ios/`
or `android/` in the parent package, rebuild the app; for iOS also rerun pod
installation so new source files are included. An XML file picker is planned;
the current list contains bundled samples only.
