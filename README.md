# YTFY - YouTube Music to Spotify Converter

A Flutter app that receives YouTube Music URLs via share intent, extracts metadata, and opens Spotify with a pre-filled search.

---

## Prerequisites

### 1. Install Flutter SDK

**macOS (Apple Silicon - M1/M2/M3)**

```bash
# Download Flutter for Apple Silicon
cd ~/Downloads
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.22.2-arm64.zip
unzip flutter_macos_3.22.2-arm64.zip

# Move to Applications
mv flutter /Applications/Flutter

# Add to PATH (add this to ~/.zshrc)
echo 'export PATH="$PATH:/Applications/Flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

**Verify installation:**
```bash
flutter --version
```

### 2. Install Xcode Command Line Tools

```bash
# Check if installed
xcode-select --version

# If not installed, run:
xcode-select --install
```

### 3. Accept Xcode Licenses

```bash
sudo xcodebuild -license accept
```

### 4. Configure iOS Simulator (optional, for iOS testing)

```bash
# List available simulators
xcrun simctl list devices available

# Boot a simulator (e.g., iPhone 15)
open -a Simulator
```

### 5. Configure Android SDK (optional, for Android testing)

If you want to build Android APKs:
```bash
# Install Android Studio from https://developer.android.com/studio
# Or set ANDROID_HOME manually
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
```

---

## Clone the Project

```bash
# Navigate to your projects directory
cd ~/projects

# Clone the repo
git clone https://github.com/dumgreg/ytfy.git
cd ytfy
```

---

## Install Dependencies

```bash
# Get all Flutter dependencies
flutter pub get
```

Expected output:
```
Running "flutter pub get" in ytfy...
  htt... (fetch)
  url_l... (fetch)
  receiv... (fetch)
  ...
  Running "flutter pub get" in ytfy...  1.2s
```

---

## Run Tests

```bash
# Run all tests
flutter test
```

Expected output:
```
00:00 +3: All tests passed!
```

---

## Build for iOS (Simulator)

Builds an iOS app for the simulator (no Apple Developer account needed):

```bash
flutter build ios --simulator --no-codesign
```

**To run on simulator:**
```bash
# Boot simulator first
open -a Simulator

# Then run the app
flutter run
```

**To run on a specific simulator:**
```bash
flutter run -d "iPhone 15"
```

---

## Build for iOS (Device - Real iPhone)

Requires an Apple Developer account ($99/year):

```bash
# Check connected devices
flutter devices

# Build for device
flutter build ios --release

# Install via Xcode
# 1. Open ~/projects/ytfy/ios/Runner.xcworkspace in Xcode
# 2. Select your device from the device selector
# 3. Click the Run button (▶️)
```

---

## Build for Android (Debug APK)

```bash
# Build debug APK
flutter build apk --debug
```

**APK location:** `build/app/outputs/flutter-apk/app-debug.apk`

**To install on connected Android device/emulator:**
```bash
flutter install
# Or manually:
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## Build for Android (Release APK)

```bash
# Build release APK (unsigned, for testing)
flutter build apk --release

# To sign the APK for Play Store:
# 1. Create a keystore (one-time setup)
keytool -genkey -v -keystore ~/ytfy-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ytfy

# 2. Create android/app/key.properties
echo "storePassword=<your-store-password>" >> android/key.properties
echo "keyPassword=<your-key-password>" >> android/key.properties
echo "keyAlias=ytfy" >> android/key.properties
echo "storeFile=/Users/<your-username>/ytfy-release-key.jks" >> android/key.properties

# 3. Build signed release APK
flutter build apk --release
```

---

## Project Structure

```
ytfy/
├── lib/
│   ├── main.dart              # App entry point + share intent handling
│   ├── models/
│   │   └── track.dart         # Track data model
│   └── services/
│       ├── metadata_service.dart   # noembed API integration
│       └── spotify_service.dart    # Spotify launch logic
├── test/
│   ├── models/
│   │   └── track_test.dart        # Track model unit tests
│   └── services/
│       ├── metadata_service_test.dart
│       └── spotify_service_test.dart
├── pubspec.yaml              # Dependencies
├── README.md                 # This file
└── ios/                      # iOS-specific config
    └── Runner/
        └── Info.plist        # Share intent configuration
```

---

## How It Works

```
1. User shares YouTube Music link → App receives via share intent
2. App extracts URL and calls noembed API
3. noembed returns track title + artist
4. App constructs Spotify search URL (spotify:search:query or open.spotify.com/search?q=...)
5. Spotify app/website opens with pre-filled search
```

---

## Troubleshooting

### "Flutter command not found"

```bash
# Add Flutter to PATH permanently
echo 'export PATH="/Applications/Flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### "iOS build fails - no simulators"

```bash
# Install Xcode from App Store, then:
xcode-select --install
open -a Simulator
```

### "Android SDK not found"

```bash
# Download Android Studio from https://developer.android.com/studio
# Or set path manually:
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools"
```

### "Permission denied" on build

```bash
# Accept Xcode licenses
sudo xcodebuild -license accept
```

### "No devices found" with flutter devices

```bash
# For iOS:
xcrun simctl list devices available
open -a Simulator

# For Android:
emulator -list-avds
emulator @Pixel_5_API_33  # Replace with your AVD name
```

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `flutter doctor` | Check Flutter setup |
| `flutter clean` | Clear build cache |
| `flutter pub get` | Refresh dependencies |
| `flutter test` | Run all tests |
| `flutter analyze` | Check for errors |
| `flutter devices` | List available devices |
| `flutter run -d <device>` | Run on specific device |
| `flutter build ios --simulator` | Build iOS simulator app |
| `flutter build apk --debug` | Build Android debug APK |

---

## Next Steps

1. **Run it:** `flutter run` on simulator
2. **Test share intent:** Share a YouTube Music link from Safari
3. **Customize:** Modify `lib/main.dart` UI as needed
4. **Deploy:** Follow iOS/Android deployment guides for App Store/Play Store

---

## License

MIT License - Do whatever you want with it.