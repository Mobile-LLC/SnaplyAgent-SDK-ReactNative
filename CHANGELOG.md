## 1.0.0

The first release. Carries the Snaply Agent iOS SDK 2.48.0 and brings the Android SDK 2.39.0 from Maven Central.

* `Snaply.configure`, `on`, `identify`, `reset`, `supportCode`, `showSupportCode`, `stop` — from JavaScript,
  with no code in the `ios` or `android` folders.
* `<SnaplyRedact>` hides its children on the device before the image is encoded.
* iOS: an agent with remote control can tap any pressable. React Native answers a touch, not an
  accessibility activation, so a tap the SDK could not deliver its own way is passed into React Native's own
  touch system.
* Android: a dashboard rule by identifier matches a `testID` (Android SDK 2.39.0).
