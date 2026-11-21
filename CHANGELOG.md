## 1.5.0

Carries the Snaply Agent iOS SDK 2.54.0 and brings the Android SDK 2.45.0 from Maven Central. No change to the
JavaScript API.

* **Errors are read the way Snaply's server now sends them.** The server answers every refusal with HTTP 200 and the
  real status and code inside the answer (a failed sign-in still with 401). The SDK reads both that and the older way,
  so an app gets the same error, with the same status and code, from either server. An app on an older package reads
  a refusal from the new server as a success until it updates.

## 1.4.0

Carries the Snaply Agent iOS SDK 2.53.0 and brings the Android SDK 2.44.0 from Maven Central. No change to the
JavaScript API.

* **Certificate pinning, for a workspace that turns it on.** When a workspace's owner, or Snaply's staff, turns the
  switch on, the app talks only to a server showing the certificate Snaply's server published in its signed key list;
  anything else between the phone and Snaply is refused before a byte is sent, and the call fails with the code
  `pinning_refused`. A renewed certificate is followed by itself. Off by default: an app whose workspace leaves it off
  behaves exactly as before. Nothing to configure.

## 1.3.0

Carries the Snaply Agent iOS SDK 2.52.0 and brings the Android SDK 2.43.0 from Maven Central.

Everything the SDK and Snaply's server exchange is now sealed a second time inside HTTPS: registration, prompts,
answers, screenshots, live frames and the live connection. The native SDKs do it. An app that talks to the live
server changes nothing and configures nothing.

* New option `serverKeys` and the export `SnaplyDevelopmentMaster`, for a Snaply server other than the live one: that
  server's master public keys travel with its address (`environment`). **An `environment` without `serverKeys` no
  longer connects**: the SDK sends nothing and reports `no_master_key`.
* The consent sheet's logo travels inside the seal too.

## 1.2.0

Carries the Snaply Agent iOS SDK 2.51.0 and brings the Android SDK 2.42.0 from Maven Central. No change to the
JavaScript API.

* When the app identifies a different user, the agent's console now says so: "Someone else signed in on {name}'s
  device — screenshots for this call ended." (the SDKs report the new reason `switched`; before, the console read
  "the device no longer holds the screenshot approval").
* A correction to 1.1.0's note: signing out does end an open screenshot approval — the Snaply server ends it on a
  sign-out — though the SDK itself does not.

## 1.1.0

Carries the Snaply Agent iOS SDK 2.50.0 and brings the Android SDK 2.41.0 from Maven Central. No change to the
JavaScript API.

* When the app identifies a different user (`Snaply.identify` with another id), an open screenshot approval on the
  device ends and support asks again. A live share that is already running continues. Signing out alone, a first
  sign-in and the same user signing in again change nothing.

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
