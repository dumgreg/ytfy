# YTFY — YouTube to Spotify Converter

**Date:** 2026-06-01  
**Status:** Draft  
**Author:** Zoro

---

## Overview

YTFY is a Flutter mobile app that converts YouTube Music links to Spotify. When a user shares a YouTube Music URL, the app extracts the track metadata via noembed API and opens Spotify with a pre-filled search query.

**Goal:** Replace manual search with a one-tap flow.

---

## Architecture

```
[Share Intent] → [Metadata Service] → [Spotify Service] → [Spotify App]
     URL              noembed API          url_launcher      Opens Search
```

### Components

| File | Responsibility |
|------|----------------|
| `lib/main.dart` | App entry, share intent handling |
| `lib/services/metadata_service.dart` | Call noembed, parse title/artist |
| `lib/services/spotify_service.dart` | Build query, open Spotify |
| `lib/models/track.dart` | Track data model |

### Data Flow

1. App receives share intent with YouTube Music URL
2. `MetadataService` calls `noembed.com/embed?url=<URL>`
3. Response parsed to extract `title` and `author_name`
4. `SpotifyService` encodes query as `spotify:search:<title> <artist>`
5. `url_launcher` opens Spotify app with pre-filled search
6. User confirms the correct track in Spotify

---

## Services

### MetadataService

```dart
Future<Track> fetchTrack(String url) async {
  final response = await http.get(
    Uri.parse('https://noembed.com/embed?url=$url')
  );
  final json = jsonDecode(response.body);
  return Track.fromNoembed(json);
}
```

**Noembed Response:**
```json
{
  "title": "Artist Name - Song Title",
  "author_name": "Artist Name"
}
```

**Parsing Strategy:**
- Split title by `" - "` (first occurrence)
- First part = artist name (cleaned)
- Second part = track title (cleaned of suffixes like "(Official Video)", "(4K)", etc.)

### SpotifyService

```dart
Future<void> openSearch(String title, String artist) async {
  final query = Uri.encodeComponent('$title $artist');
  final spotifyUrl = Uri.parse('spotify:search:$query');
  await launchUrl(spotifyUrl, mode: LaunchMode.externalApplication);
}
```

**Fallback:** If Spotify not installed, open `open.spotify.com/search?q=<query>` in browser.

---

## Models

### Track

```dart
class Track {
  final String title;
  final String artist;
  final String url;
}
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| noembed fails | Show snackbar "Could not fetch track info" |
| Spotify not installed | Fallback to web browser |
| Parse fails | Show raw title in Spotify search |
| No internet | Show offline message |

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  url_launcher: ^6.2.0
  receive_sharing_intent: ^1.8.0
```

---

## Scope (MVP)

- ✅ Receive YouTube Music URLs via share intent
- ✅ Extract metadata via noembed
- ✅ Open Spotify with search query
- ✅ Handle errors gracefully
- ❌ Spotify API integration (future)
- ❌ Playlist conversion (future)
- ❌ History/favorites (future)

---

## Success Criteria

1. Sharing a YT Music URL opens Spotify with correct track pre-searched
2. Works with majority of standard YT Music link formats
3. Handles errors without crashing
4. Clean, minimal UI with one-tap flow