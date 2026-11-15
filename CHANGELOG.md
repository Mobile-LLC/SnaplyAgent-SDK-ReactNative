## 1.0.1

Carries the Snaply Agent iOS SDK 2.49.1 and brings the Android SDK 2.40.1 from Maven Central. No change to the
JavaScript API.

* The consent record fixes of both SDKs: an Allow that never reached Snaply is not kept, a live session lost
  mid-way needs a new Allow, and a screenshot approval never lasts past 45 minutes.
* iOS: the framework inside the package no longer carries the compiler's ABI descriptor files (`.abi.json`).

## 1.0.0

The first release. Carries the Snaply Agent iOS SDK 2.48.0 and brings the Android SDK 2.39.0 from Maven Central.

* `Snaply.configure`, `on`, `identify`, `reset`, `supportCode`, `showSupportCode`, `stop` — from JavaScript,
  with no code in the `ios` or `android` folders.
* `<SnaplyRedact>` hides its children on the device before the image is encoded.
* iOS: an agent with remote control can tap any pressable. React Native answers a touch, not an
  accessibility activation, so a tap the SDK could not deliver its own way is passed into React Native's own
  touch system.
* Android: a dashboard rule by identifier matches a `testID` (Android SDK 2.39.0).
