# Spin Master (Spinning Wheel / Decision Maker)

A production-style Flutter app for premium animated decision wheels.

## Features

- Physics-based spinning wheel with deterministic winner selection at a fixed 12 o'clock pointer
- Fancy animated background on all core screens (blobs + particles + parallax-style motion)
- Slice editor: add, edit, reorder, delete, validation, color randomizer
- Built-in presets (Food, Activities, Yes/No, Random 1-10)
- Saved wheels CRUD (create, rename, duplicate, delete, switch)
- Result modal with blur, confetti, haptics, optional sounds, share action
- Settings persistence: sound, haptics, remove winner, background intensity, theme, reset app
- Riverpod-based app state + SharedPreferences persistence
- AdMob monetization: banner ads + rewarded interstitial cadence

## Tech stack

- Flutter stable + null safety
- State management: `flutter_riverpod`
- Storage: `shared_preferences`
- Rendering/animation: `CustomPainter`, `AnimationController`, `FrictionSimulation`

## Run

1. `flutter pub get`
2. `flutter run`

## AdMob setup

- This repo now uses `google_mobile_ads`.
- Default IDs in code are Google test IDs so local development is safe.
- For production earnings, replace app IDs and pass your real ad unit IDs:
  - Android banner: `--dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxxx/yyyy`
  - iOS banner: `--dart-define=ADMOB_BANNER_IOS=ca-app-pub-xxxx/yyyy`
  - Android rewarded interstitial: `--dart-define=ADMOB_REWARDED_INTERSTITIAL_ANDROID=ca-app-pub-xxxx/yyyy`
  - iOS rewarded interstitial: `--dart-define=ADMOB_REWARDED_INTERSTITIAL_IOS=ca-app-pub-xxxx/yyyy`
- Replace test app IDs in:
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Info.plist`

Current monetization behavior:
- Banner shown on `Wheels` and `Settings` tabs (not on the main spin tab).
- Rewarded interstitial attempted every 2 completed spins.
- Rewarded interstitial attempted when creating wheels after the first user-created wheel.

## Test

- `flutter test`

## Project structure

- `lib/core/` models, state controller, storage, theme, utils
- `lib/features/wheel/` wheel logic + wheel UI
- `lib/features/wheels/` saved wheels screen
- `lib/features/presets/` built-in presets
- `lib/features/settings/` settings screen
- `lib/features/editor/` slice management bottom sheet
- `lib/shared/widgets/` reusable UI and animations

## Wheel math

Winner is computed from final wheel rotation and pointer at 12 o'clock:

- `totalAngle = rotation % (2π)`
- wheel start angle is centered so slice `0` starts under pointer at rest
- local pointer angle in wheel space:
  - `local = normalize(pointerAngle - rotation - startAngle)`
- winner index:
  - `index = floor(local / sweepAngle) % sliceCount`

Implementation: `lib/features/wheel/logic/wheel_math.dart`

## Add presets

Edit `lib/features/presets/data/preset_library.dart` and add a `Preset` entry:

```dart
const Preset(
  id: 'my-preset',
  name: 'My Preset',
  items: ['One', 'Two', 'Three'],
),
```

Presets can be loaded into the active wheel or saved as a new custom wheel.
