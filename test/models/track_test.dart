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
