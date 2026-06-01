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
    final String artistName;
    final String trackTitle;
    if (parts.length > 1) {
      artistName = parts[0].trim();
      trackTitle = parts[1].trim();
    } else {
      artistName = author;
      trackTitle = fullTitle;
    }

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
