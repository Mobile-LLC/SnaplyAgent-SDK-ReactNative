# @snaplyagent/react-native

Snaply Agent for React Native — consent-first screen capture for support teams: a screenshot, a live
view and remote control of your app, each only after the person allows it, with sensitive fields
hidden on the device before anything is sent.

One package, autolinked. No code in the `ios` or `android` folders.

## Install

```sh
npm install github:Mobile-LLC/SnaplyAgent-SDK-ReactNative
cd ios && pod install
```

- React Native 0.88 or later (the New Architecture).
- **iOS 15.1** or later. The package carries the Snaply Agent iOS SDK; do not add its Swift package to
  the app as well.
- **Android** `minSdk` 24. The package brings the Snaply Agent Android SDK from Maven Central.

## Use

```tsx
import { Platform } from 'react-native';
import { Snaply, SnaplyRedact } from '@snaplyagent/react-native';

// 1. Listen first: a request can arrive as soon as the device is registered.
Snaply.on({
  onAllowed: capture => console.log('Screenshot shared'),
  onError: error => console.warn(`Snaply: ${error.code}`),
});

// 2. Configure once. An iOS product and an Android product each have their own key
//    (Console → Products → your product → API key). A key is not a secret.
await Snaply.configure({
  key: Platform.OS === 'ios' ? iosKey : androidKey,
  user: { id: 'usr_20481', name: 'Maya Kowalski' }, // optional
});

// When someone signs in later, and when they sign out:
Snaply.identify({ id: 'usr_20481', name: 'Maya Kowalski' });
Snaply.reset();

// An anonymous caller reads this to the agent:
const code = await Snaply.supportCode();
Snaply.showSupportCode(); // …or the SDK shows it in its own sheet
```

Add the app's identifier (bundle id, package name) to each product's allowed list in the console, or
`configure` rejects with `origin_mismatch`. On Android `configure` resolves as soon as the SDK has
started; a refused registration arrives through `onError`.

## What is hidden

A React Native screen is native views, so the native SDKs capture it and hide fields in it as in any
other app. Everything is painted over **on the device, before the image is encoded**. A hidden field
is also locked for remote control: it takes neither a tap nor text.

| | Hidden |
|---|---|
| `<TextInput secureTextEntry />` | On its own |
| `<SnaplyRedact>…</SnaplyRedact>` | Whatever is inside |
| A `testID` containing `snaply-redact` | That view |
| A dashboard rule **by identifier** (Products → Hidden fields) | The view with that `testID` — exact match |
| A dashboard rule **by text** | A view whose `placeholder` or `accessibilityLabel` contains the text, in any case |

```tsx
<SnaplyRedact>
  <TextInput value={card} onChangeText={setCard} />
</SnaplyRedact>
<TextInput testID="ibanField" value={iban} onChangeText={setIban} />
```

Anything else on screen is captured as it is. On iOS a `<Text>` is its own accessibility label, so a
rule by text also hides a caption that contains the text.

## Remote control

When the person allows it during a live view, the agent can tap, scroll and type. Nothing needs
adding to your components: `Pressable`, the `Touchable`s and `Button` respond to an agent's tap as
they do to a finger.

## Not in this version

- A tap inside a React Native `Modal` is delivered the SDK's own way only (the modal is another
  window); a pressable there needs `onAccessibilityTap` beside `onPress` on iOS.
- Expo: not measured. A development build should work; Expo Go cannot load native code.

## What was measured

On 2026-11-10 with the example app
(<https://github.com/Mobile-LLC/SnaplyAgent-Example-ReactNative>): React Native 0.88.1, an iOS 18.6
simulator and an API 34 emulator, debug builds, against a local Snaply backend.

| | iOS | Android |
|---|---|---|
| Starts from JavaScript, registers, comes online | ✓ | ✓ |
| Screenshot after consent, screen content correct | ✓ | ✓ |
| `secureTextEntry` field hidden on its own | ✓ | ✓ |
| `<SnaplyRedact>` | ✓ | ✓ |
| Dashboard rule by identifier (`testID`) | ✓ | ✓ |
| Dashboard rule by text | ✓ | ✓ |
| Live view | ✓ | ✓ |
| Remote control — tap a plain `Pressable` | ✓ | ✓ |
| Remote control — type into a field | ✓ | ✓ |
| A hidden field refuses a tap and typed text | ✓ | ✓ |
| `identify`, `reset`, `supportCode`, `showSupportCode` | ✓ | ✓ |
| Callbacks reach JavaScript | ✓ | ✓ |

Not measured: scrolling (a React Native scroll view is a native one, the SDK's own path), a physical
device, a release build, Expo, a tap inside a `Modal`.

## Develop

```sh
npm install
npm test
npm run typecheck
npm run lint
```

The iOS SDK the pod embeds lives in `ios/Frameworks`. `scripts/vendor-ios-sdk.sh <version>` brings in a
published version and refuses a binary that does not match the checksums its release recorded;
`--check` compares what is there.

## Docs

<https://snaplyagent.com/docs>
