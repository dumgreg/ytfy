import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:ytfy/services/metadata_service.dart';

void main() {
  group('MetadataService', () {
    test('fetchTrack parses valid noembed response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.host, 'noembed.com');
        return http.Response(
          jsonEncode({
            'title': 'Artist - Song Title',
            'author_name': 'Artist',
            'url': 'https://music.youtube.com/watch?v=123',
          }),
          200,
        );
      });

      final service = MetadataService(client: mockClient);
      final track = await service.fetchTrack('https://music.youtube.com/watch?v=123');

      expect(track.artist, 'Artist');
      expect(track.title, 'Song Title');
    });

    test('fetchTrack throws MetadataException on error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":"No embed data found"}', 404);
      });

      final service = MetadataService(client: mockClient);
      
      expect(
        () => service.fetchTrack('https://music.youtube.com/watch?v=123'),
        throwsA(isA<MetadataException>()),
      );
    });
  });
}
