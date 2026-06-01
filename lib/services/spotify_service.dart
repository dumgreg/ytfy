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
    final rawQuery = '$title $artist';
    final pathQuery = Uri.encodeComponent(rawQuery).replaceAll('%20', '+');
    final webUrl = Uri.parse('https://open.spotify.com/search/$pathQuery');
    return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }
}
