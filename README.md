# YTFY

Share a YouTube Music link, pick Spotify from the system share sheet, done.

YTFY is a tiny Flutter app that turns YouTube Music share intents into Spotify search links. It calls the [noembed](https://noembed.com) API to read the track title and artist, then hands the resulting Spotify URL back to the OS share sheet so you can route it wherever you want — Spotify app, browser, or anywhere else.

## How it works

```
[YouTube Music] → share link → [YTFY] → noembed → build Spotify URL
                                                      ↓
                                            [system share sheet]
                                                      ↓
                                  user picks Spotify / browser / ...
                                                      ↓
                                         [that app opens with search]
                                                      ↓
                                  [YTFY pops back to YouTube Music]
```

## Prerequisites

- **Flutter** stable, 3.44 or newer
- **Java 17** (managed via [mise](https://mise.jdx.dev/) — `mise.toml` is committed)
- **Android SDK** with `platform-tools` on `PATH` for `adb`

Quick mise setup:

```bash
mise install        # reads mise.toml
mise use java@17
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
flutter doctor
```

## Quick start

```bash
flutter pub get
flutter run
```

On a physical device or emulator, share any `https://music.youtube.com/watch?v=…` link and pick YTFY from the share sheet.

## Build

Targets **Android 15+ (API 35+)** and **arm64-v8a** only — modern phones, single ABI. The release APK is ~16 MB.

**Debug APK** (sideload for testing):

```bash
flutter build apk --debug --target-platform=android-arm64
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

**Release APK** (unsigned, arm64-only):

```bash
flutter build apk --release --target-platform=android-arm64
# build/app/outputs/flutter-apk/app-release.apk  (~16 MB)
```

**iOS** (requires Xcode, signing not configured by default):

```bash
flutter build ios --simulator --no-codesign
```

## Tests

```bash
flutter test
```

9 unit tests cover `Track` parsing, `MetadataService` noembed integration, and `SpotifyService.buildSearchUrl` URL construction.

## Releases

Push a tag like `v0.2.0` to trigger `.github/workflows/release.yml`. The workflow:

- Sets up Java 17 + Flutter 3.44
- Runs `flutter analyze` and `flutter test`
- Generates launcher icons from `assets/icon.png` (if present)
- Builds an arm64-only release APK
- Attaches it to a GitHub Release with auto-generated notes

You can also trigger it manually from the Actions tab.

## Project structure

```
ytfy/
├── lib/
│   ├── main.dart                       # App entry, share intent handling, share sheet trigger
│   ├── models/
│   │   └── track.dart                  # Track data model + noembed parsing
│   └── services/
│       ├── metadata_service.dart       # noembed API client
│       └── spotify_service.dart        # Spotify search URL builder
├── test/
│   ├── models/track_test.dart
│   └── services/
│       ├── metadata_service_test.dart
│       └── spotify_service_test.dart
├── assets/
│   └── icon.png                        # Source for launcher icons (1024×1024+)
├── android/                            # Native Android project
├── ios/                                # Native iOS project
├── .github/workflows/
│   └── release.yml                     # Build + release on tag push
├── mise.toml                           # Pinned toolchain (java@17)
├── pubspec.yaml
└── README.md
```

## Customisation

- **App icon:** replace `assets/icon.png` (1024×1024 PNG, opaque), then `dart run flutter_launcher_icons`. Both Android and iOS icons regenerate.
- **Package / org name:** `applicationId` lives in `android/app/build.gradle.kts`.
- **Share target filter:** the YT Music URL check is in `_handleSharedUrl` in `lib/main.dart`.

## Troubleshooting

**`Unsupported class file major version 70`** — Java 26 is too new for the bundled Gradle. Use Java 17: `mise use java@17`.

**`Inconsistent JVM Target Compatibility`** — the `receive_sharing_intent` plugin compiles Kotlin to JVM 17. The `android/build.gradle.kts` `subprojects` block aligns the rest of the project to match.

**`Android SDK not found`** — export `ANDROID_HOME` as shown in Prerequisites.

**Share sheet doesn't include Spotify** — make sure Spotify is installed and you've opened it at least once so it registers its intent filter for `https://open.spotify.com/...`.

## License

MIT. Do whatever you want.
