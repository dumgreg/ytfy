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
