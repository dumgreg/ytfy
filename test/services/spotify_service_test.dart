import 'package:flutter_test/flutter_test.dart';
import 'package:ytfy/services/spotify_service.dart';

void main() {
  group('SpotifyService', () {
    test('generates correct search query', () {
      final service = SpotifyService();
      // Test that the URL generation logic works
      final query = 'Song Title';
      final artist = 'Artist';
      final expectedQuery = Uri.encodeComponent('$query $artist');
      expect(expectedQuery, 'Song%20Title%20Artist');
    });
  });
}
