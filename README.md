# Daily Reflections — Offline Audio App (Starter)

A Flutter starter for a fully offline, single-scholar audio app: morning and
night lessons, khutbah excerpts, with Unity LevelPlay (formerly "Unity Ads")
for monetization.

## What's here

```
lib/
  models/lesson.dart        - Lesson data model
  data/sample_lessons.dart  - Placeholder lesson list (replace with real content)
  services/ads_service.dart - Unity LevelPlay wrapper (rewarded + interstitial)
  theme/neumorphic.dart     - Soft-UI (neumorphic) design system: colors + reusable widgets
  screens/home_screen.dart  - Morning / Night / All tabs
  screens/player_screen.dart- Audio player + post-lesson reflection prompt
  widgets/lesson_card.dart  - List item for the library
  main.dart                 - App entry point
assets/
  audio/                    - Put your .mp3 files here
```

## Design

The UI follows a neumorphic ("soft UI") style: everything is carved out of
one light-grey background (`AppColors.background`) using paired light/dark
shadows, with a single deep-sage accent color (`AppColors.accent`) for text,
icons, and the progress fill. All of this lives in `lib/theme/neumorphic.dart`
as reusable `Neumorphic` and `NeumorphicCircleButton` widgets, so new screens
can stay visually consistent by just wrapping content in them.

## Ads & offline behavior

This app is built offline-first for listening:

- Audio playback never touches the network - it plays bundled/local files
  regardless of connectivity.
- `AdsService` only initializes Unity LevelPlay and preloads ads **when the
  device has a connection** (checked via `connectivity_plus`), and keeps
  listening for connectivity changes so it can quietly load ads the moment
  data turns on - even mid-session.
- If there's no connection, ad calls are simply skipped - nothing blocks,
  errors, or interrupts the listening experience.
- Interstitials only ever show at a natural break point (after a lesson
  finishes), never during playback.

## Getting this running

This project was hand-scaffolded (no Flutter SDK was available in the
environment that generated it), so you'll need to turn it into a real
runnable Flutter project on your machine:

1. Install the Flutter SDK if you haven't: https://docs.flutter.dev/get-started/install
2. In this folder, run:
   ```
   flutter create --project-name islamic_audio_app .
   ```
   This generates the missing `android/`, `ios/`, and platform boilerplate
   without touching the `lib/` files above.
3. Run:
   ```
   flutter pub get
   ```
4. Drop your scholar's `.mp3` files into `assets/audio/` and update
   `lib/data/sample_lessons.dart` (or wire up loading from
   `assets/data/lessons.json` instead — easier to edit without touching code).
5. Sign up at https://dashboard.unity3d.com, create an app, and get your
   real App Key + ad unit IDs. Replace every placeholder in
   `lib/services/ads_service.dart`.

## Before you ship

- **Rights**: get written permission from the scholar (or their institution)
  to distribute and monetize their audio in-app. This protects you and them.
- **Ad placement**: interstitials only appear *after* a lesson finishes —
  never mid-playback. Keep it that way; interrupting sacred content with ads
  is the fastest way to lose trust and get bad reviews.
- **Verify the LevelPlay API**: the exact method names in `ads_service.dart`
  (`LevelPlay.init`, `LevelPlayRewardedAd`, etc.) are based on the
  `unity_levelplay_mediation` package as of mid-2026. Ad SDKs update
  frequently — check https://pub.dev/packages/unity_levelplay_mediation
  and the official docs before you build against this, in case the API
  surface has shifted since.
- **App icon, name, splash screen**: still need to be set up via
  `flutter_launcher_icons` / `flutter_native_splash` or manually.

## Suggested next steps

- Add a streak tracker (shared_preferences) for "listened today" morning + night
- Add offline download progress UI if you later support downloadable packs
  instead of bundling everything at install
- Add a "remove ads" one-time purchase or a sadaqah/donation button as a
  second revenue stream alongside Unity Ads
