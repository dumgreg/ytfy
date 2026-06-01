class SpotifyException implements Exception {
  final String message;
  const SpotifyException(this.message);

  @override
  String toString() => 'SpotifyException: $message';
}

class SpotifyService {
  static const _searchBase = 'https://open.spotify.com/search/';


  String buildSearchUrl(String title, String artist) {
    final raw = '$title $artist'.trim();
    if (raw.isEmpty) {
      throw const SpotifyException('Cannot build search URL from empty query');
    }
    final encoded = Uri.encodeComponent(raw).replaceAll('%20', '+');
    return '$_searchBase$encoded';
  }
}
