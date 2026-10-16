# Library tests

These suites test `@ccda-kit/react-native`. The example app's tests are separate.

## JavaScript and TypeScript

From `react-native/`:

```bash
npm test
npm run typecheck
```

Coverage includes parser and preview forwarding, native installation errors,
all renderer override boundaries, missing patient data, repeated identifiers,
attachment loading and retries, measurement/date formatting, and a synthetic
10,000-entry document. The large-input test checks bounded component mounting;
it is not a device frame-rate or memory benchmark.

Light and dark React component snapshots live under `src/__tests__/__snapshots__/`.
They catch changes to rendered content and styles, not pixel differences on
physical devices. Update them intentionally with `npm test -- --updateSnapshot`
and inspect the snapshot diff.

## Native iOS bridge

The CocoaPods integration helper has library tests that create temporary Xcode
projects without building or downloading packages. With the example's pinned
Ruby dependencies installed, run from `react-native/example/`:

```bash
bundle exec ruby ../ios/Tests/ccda_pods_test.rb
```

These cover published version pinning and explicit version overrides, local
source selection, repeat installs, source switching, bridge-only linking,
search paths, and installation errors.

`ios/Tests/CCDAMediaBridgeTests.m` belongs to the pod's optional `Native` test
specification. It is not an example-app test target. Opt a development test host
into it with the normal pod dependency:

```ruby
pod 'ccda-kit-react-native', :path => '/path/to/react-native', :testspecs => ['Native']
```

Link `CCDAEngine` to the bridge as described in the installation guide. CocoaPods
creates the test host required to present UIKit previews. Run the generated
Native unit-test scheme in Xcode on an iOS simulator when native builds are
permitted. The suite covers cached and inline image/PDF/text/HTML presentation,
dismissal, invalid or unavailable media, parser failures, and numeric byte counts.
Only synthetic payloads are used.

## Native Android bridge

`android/src/androidTest/` contains library instrumentation tests. They reuse
`test-data/ccda/samples/local-media-attachments.xml` from the monorepo. The tests
exercise real image/PDF preparation, cached and inline payloads, numeric bridge
values, invalid inputs, and temporary PDF cleanup without depending on the
example's UI or Metro.

With an emulator/device and a development Gradle host including the local module,
run its `connectedDebugAndroidTest` task when native builds are permitted. For the
existing monorepo Gradle host the module task is:

```bash
./gradlew :ccda-kit_react-native:connectedDebugAndroidTest
```

## Release verification

PR native jobs run the same host in separate `local` and `published` engine
modes. Example-owned overrides select source in local mode; published mode uses
the release pinned in `example/engine-version.json` and never falls back to
source. Both modes use the local RN wrapper. See the example's README for mode
selection and how this differs from installing the wrapper from npm.

Native suites require compilation and a simulator/device. Adding their source
does not mean they have run. Device pixel baselines, measured scroll performance,
and a real registry publish remain separate release checks.
