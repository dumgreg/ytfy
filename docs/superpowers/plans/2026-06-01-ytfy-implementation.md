# YTFY Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter app that receives YouTube Music URLs via share intent, extracts metadata via noembed API, and opens Spotify with a pre-filled search.

**Architecture:** Simple 3-layer flow — Share Intent → Metadata Extraction → Spotify Launch. No Spotify API keys needed.

**Tech Stack:** Flutter, http package, url_launcher, receive_sharing_intent

---

## File Structure

```
ytfy/
├── lib/
│   ├── main.dart                 # App entry, share intent handling
│   ├── models/
│   │   └── track.dart            # Track data model
│   └── services/
│       ├── metadata_service.dart # noembed API call + parsing
│       └── spotify_service.dart  # Spotify URL generation + launch
├── test/
│   ├── models/
│   │   └── track_test.dart       # Track model tests
│   └── services/
│       ├── metadata_service_test.dart  # Metadata parsing tests
│       └── spotify_service_test.dart   # URL generation tests
└── pubspec.yaml                 # Dependencies
```

---

## Task 1: Project Setup

**Files:**
- Create: `ytfy/pubspec.yaml`
- Create: `ytfy/lib/main.dart` (placeholder)
- Create: `ytfy/lib/models/track.dart`
- Create: `ytfy/lib/services/metadata_service.dart`
- Create: `ytfy/lib/services/spotify_service.dart`

- [ ] **Step 1: Create pubspec.yaml with dependencies**

```yaml
name: ytfy
description: Convert YouTube Music links to Spotify
publish_to: 'none'
version: 0.1.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  url_launcher: ^6.2.0
  receive_sharing_intent: ^1.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

- [ ] **Step 2: Create Track model**

```dart
class Track {
  final String title;
  final String artist;
  final String url;

  const Track({
    required this.title,
    required this.artist,
    required this.url,
  });

  factory Track.fromNoembed(Map<String, dynamic> json) {
    final fullTitle = json['title'] as String? ?? '';
    final author = json['author_name'] as String? ?? '';

    // Parse "Artist - Song Title" format
    final parts = fullTitle.split(' - ');
    final artistName = parts.isNotEmpty ? parts[0].trim() : author;
    final trackTitle = parts.length > 1 ? parts[1].trim() : fullTitle;

    return Track(
      title: _cleanTitle(trackTitle),
      artist: artistName,
      url: json['url'] as String? ?? '',
    );
  }

  static String _cleanTitle(String title) {
    // Remove common suffixes
    return title
        .replaceAll(RegExp(r'\s*\(Official.*?\)'), '')
        .replaceAll(RegExp(r'\s*\(4K.*?\)'), '')
        .replaceAll(RegExp(r'\s*\[Official.*?\]'), '')
        .trim();
  }

  @override
  String toString() => 'Track($title by $artist)';
}
```

- [ ] **Step 3: Create MetadataService stub**

```dart
import 'package:http/http.dart' as http;
import '../models/track.dart';

class MetadataService {
  static const _noembedUrl = 'https://noembed.com/embed';

  final http.Client _client;

  MetadataService({http.Client? client}) : _client = client ?? http.Client();

  Future<Track> fetchTrack(String url) async {
    final response = await _client.get(
      Uri.parse('$_noembedUrl?url=${Uri.encodeComponent(url)}'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch metadata: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Track.fromNoembed(json);
  }
}
```

- [ ] **Step 4: Create SpotifyService stub**

```dart
import 'package:url_launcher/url_launcher.dart';

class SpotifyService {
  Future<bool> openSearch(String title, String artist) async {
    final query = Uri.encodeComponent('$title $artist');
    final spotifyUri = Uri.parse('spotify:search:$query');

    // Try Spotify app first
    if (await canLaunchUrl(spotifyUri)) {
      return await launchUrl(spotifyUri, mode: LaunchMode.externalApplication);
    }

    // Fallback to web
    final webUrl = Uri.parse('https://open.spotify.com/search?q=$query');
    return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }
}
```

- [ ] **Step 5: Create placeholder main.dart**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const YtfyApp());
}

class YtfyApp extends StatelessWidget {
  const YtfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTFY',
      home: Scaffold(
        appBar: AppBar(title: const Text('YTFY')),
        body: const Center(child: Text('Share a YouTube Music link to convert')),
      ),
    );
  }
}
```

- [ ] **Step 6: Run flutter pub get**

```bash
cd ytfy && flutter pub get
```

Expected: Dependencies resolved successfully

---

## Task 2: Share Intent Handling

**Files:**
- Modify: `ytfy/lib/main.dart`

- [ ] **Step 1: Write test for share intent handling**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ytfy/models/track.dart';

void main() {
  group('Track.fromNoembed', () {
    test('parses standard artist - title format', () {
      final json = {
        'title': 'Rick Astley - Never Gonna Give You Up',
        'author_name': 'Rick Astley',
        'url': 'https://music.youtube.com/watch?v=dQw4w9WgXcQ',
      };

      final track = Track.fromNoembed(json);

      expect(track.artist, 'Rick Astley');
      expect(track.title, 'Never Gonna Give You Up');
    });

    test('removes official video suffix', () {
      final json = {
        'title': 'Artist - Song Title (Official Video)',
        'author_name': 'Artist',
        'url': 'https://music.youtube.com/watch?v=123',
      };

      final track = Track.fromNoembed(json);

      expect(track.title, 'Song Title');
    });

    test('handles missing author from title', () {
      final json = {
        'title': 'Artist Name - Song Title',
        'author_name': '',
        'url': 'https://music.youtube.com/watch?v=123',
      };

      final track = Track.fromNoembed(json);

      expect(track.artist, 'Artist Name');
      expect(track.title, 'Song Title');
    });

    test('falls back to author_name when no dash in title', () {
      final json = {
        'title': 'Single Track Title',
        'author_name': 'Some Artist',
        'url': 'https://music.youtube.com/watch?v=123',
      };

      final track = Track.fromNoembed(json);

      expect(track.artist, 'Some Artist');
      expect(track.title, 'Single Track Title');
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they pass**

```bash
cd ytfy && flutter test test/models/track_test.dart
```

Expected: All 4 tests pass

- [ ] **Step 3: Update main.dart with share intent handling**

```dart
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'services/metadata_service.dart';
import 'services/spotify_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YtfyApp());
}

class YtfyApp extends StatefulWidget {
  const YtfyApp({super.key});

  @override
  State<YtfyApp> createState() => _YtfyAppState();
}

class _YtfyAppState extends State<YtfyApp> {
  final _metadataService = MetadataService();
  final _spotifyService = SpotifyService();
  
  String? _statusMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _listenForShares();
  }

  void _listenForShares() {
    ReceiveSharingIntent.instance.getMediaStream().listen(_handleSharedUrl);
    ReceiveSharingIntent.instance.getInitialMedia().then(_handleSharedUrl);
  }

  Future<void> _handleSharedUrl(List<SharedMediaFile> files) async {
    if (files.isEmpty || _isProcessing) return;

    final file = files.first;
    final url = file.value;

    if (!url.contains('music.youtube.com')) {
      setState(() => _statusMessage = 'Not a YouTube Music link');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Fetching track info...';
    });

    try {
      final track = await _metadataService.fetchTrack(url);
      await _spotifyService.openSearch(track.title, track.artist);
      setState(() => _statusMessage = 'Opening Spotify: ${track.title}');
    } catch (e) {
      setState(() => _statusMessage = 'Error: Could not fetch track');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTFY',
      home: Scaffold(
        appBar: AppBar(title: const Text('YTFY')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note, size: 64),
              const SizedBox(height: 16),
              Text(
                _statusMessage ?? 'Share a YouTube Music link',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ReceiveSharingIntent.instance.reset();
    super.dispose();
  }
}
```

- [ ] **Step 4: Add import for jsonDecode**

Add at top of main.dart:
```dart
import 'dart:convert';
```

- [ ] **Step 5: Run flutter analyze to check for errors**

```bash
cd ytfy && flutter analyze
```

Expected: No errors

---

## Task 3: Error Handling & Polish

**Files:**
- Modify: `ytfy/lib/services/metadata_service.dart`
- Modify: `ytfy/lib/services/spotify_service.dart`
- Modify: `ytfy/lib/main.dart`

- [ ] **Step 1: Update MetadataService with better error handling**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';

class MetadataException implements Exception {
  final String message;
  const MetadataException(this.message);

  @override
  String toString() => 'MetadataException: $message';
}

class MetadataService {
  static const _noembedUrl = 'https://noembed.com/embed';

  final http.Client _client;

  MetadataService({http.Client? client}) : _client = client ?? http.Client();

  Future<Track> fetchTrack(String url) async {
    try {
      final response = await _client.get(
        Uri.parse('$_noembedUrl?url=${Uri.encodeComponent(url)}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw MetadataException('Server returned ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for noembed error
      if (json.containsKey('error')) {
        throw MetadataException(json['error'] as String);
      }

      return Track.fromNoembed(json);
    } on http.ClientException catch (e) {
      throw MetadataException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
```

- [ ] **Step 2: Update SpotifyService with fallback**

```dart
import 'package:url_launcher/url_launcher.dart';

class SpotifyException implements Exception {
  final String message;
  const SpotifyException(this.message);

  @override
  String toString() => 'SpotifyException: $message';
}

class SpotifyService {
  Future<bool> openSearch(String title, String artist) async {
    final query = Uri.encodeComponent('$title $artist');

    // Try Spotify app first
    try {
      final spotifyUri = Uri.parse('spotify:search:$query');
      final canLaunch = await canLaunchUrl(spotifyUri);

      if (canLaunch) {
        final result = await launchUrl(
          spotifyUri,
          mode: LaunchMode.externalApplication,
        );
        if (result) return true;
      }
    } catch (_) {
      // Fall through to web fallback
    }

    // Fallback to web browser
    final webUrl = Uri.parse('https://open.spotify.com/search?q=$query');
    return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }
}
```

- [ ] **Step 3: Update main.dart with error snackbar**

```dart
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:convert';
import 'services/metadata_service.dart';
import 'services/spotify_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YtfyApp());
}

class YtfyApp extends StatefulWidget {
  const YtfyApp({super.key});

  @override
  State<YtfyApp> createState() => _YtfyAppState();
}

class _YtfyAppState extends State<YtfyApp> {
  final _metadataService = MetadataService();
  final _spotifyService = SpotifyService();

  String? _statusMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _listenForShares();
  }

  void _listenForShares() {
    ReceiveSharingIntent.instance.getMediaStream().listen(_handleSharedUrl);
    ReceiveSharingIntent.instance.getInitialMedia().then(_handleSharedUrl);
  }

  Future<void> _handleSharedUrl(List<SharedMediaFile> files) async {
    if (files.isEmpty || _isProcessing) return;

    final file = files.first;
    final url = file.value;

    if (!url.contains('music.youtube.com')) {
      _showSnackbar('Not a YouTube Music link');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Fetching track info...';
    });

    try {
      final track = await _metadataService.fetchTrack(url);
      await _spotifyService.openSearch(track.title, track.artist);
      setState(() => _statusMessage = 'Opening: ${track.title}');
    } on MetadataException catch (e) {
      _showSnackbar('Could not fetch track info');
      setState(() => _statusMessage = null);
    } catch (e) {
      _showSnackbar('Something went wrong');
      setState(() => _statusMessage = null);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTFY',
      home: Scaffold(
        appBar: AppBar(title: const Text('YTFY')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isProcessing ? Icons.hourglass_empty : Icons.music_note,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage ?? 'Share a YouTube Music link',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _metadataService.dispose();
    ReceiveSharingIntent.instance.reset();
    super.dispose();
  }
}
```

- [ ] **Step 4: Run full test suite**

```bash
cd ytfy && flutter test
```

Expected: All tests pass, no analysis errors

---

## Task 4: Build Verification

**Files:**
- Create: `ytfy/android/app/src/main/AndroidManifest.xml` (add queries)

- [ ] **Step 1: Verify Android manifest for intent filters**

Check that AndroidManifest includes:
```xml
<intent-filter>
  <action android:name="android.intent.action.SEND" />
  <category android:name="android.intent.category.DEFAULT" />
  <data android:mimeType="text/plain" />
</intent-filter>
```

And Spotify scheme:
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="spotify" />
  </intent>
</queries>
```

- [ ] **Step 2: Build debug APK**

```bash
cd ytfy && flutter build apk --debug
```

Expected: `build/app/outputs/flutter-apk/app-debug.apk` created

---

## Success Criteria

- [ ] All tests pass
- [ ] No analysis errors
- [ ] Debug APK builds successfully
- [ ] Share intent handling implemented
- [ ] noembed metadata extraction works
- [ ] Spotify launch with fallback implemented