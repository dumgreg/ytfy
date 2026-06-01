import 'package:flutter_test/flutter_test.dart';
import 'package:ytfy/services/spotify_service.dart';

void main() {
  group('SpotifyService.buildSearchUrl', () {
    final service = SpotifyService();

    test('uses path-based spotify search URL with + for spaces', () {
      final url = service.buildSearchUrl('Never Gonna Give You Up', 'Rick Astley');
      expect(
        url,
        'https://open.spotify.com/search/Never+Gonna+Give+You+Up+Rick+Astley',
      );
    });

    test('encodes special characters', () {
      final url = service.buildSearchUrl('Caf\u00e9 del Mar', 'Jos\u00e9 Padilla');
      expect(url, startsWith('https://open.spotify.com/search/'));
      expect(url, isNot(contains(' ')));
    });

    test('throws on empty title and artist', () {
      expect(
        () => service.buildSearchUrl('   ', '   '),
        throwsA(isA<SpotifyException>()),
      );
    });
  });
}
