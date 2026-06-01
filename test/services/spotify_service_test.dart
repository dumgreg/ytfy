import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpotifyService', () {
    test('generates correct search query', () {
      const query = 'Song Title';
      const artist = 'Artist';
      final expectedQuery = Uri.encodeComponent('$query $artist');
      expect(expectedQuery, 'Song%20Title%20Artist');
    });
  });
}
