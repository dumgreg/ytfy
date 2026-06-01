import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'services/metadata_service.dart';
import 'services/spotify_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YtfyApp());
}

class YtfyApp extends StatefulWidget {
  const YtfyApp({super.key});

  @override
  State<YtfyApp> createState() => _YtfyAppState();
}

class _YtfyAppState extends State<YtfyApp> {
  final _metadataService = MetadataService();
  final _spotifyService = SpotifyService();

  String? _statusMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _listenForShares();
  }

  void _listenForShares() {
    ReceiveSharingIntent.instance.getMediaStream().listen(_handleSharedUrl);
    ReceiveSharingIntent.instance.getInitialMedia().then(_handleSharedUrl);
  }

  Future<void> _handleSharedUrl(List<SharedMediaFile> files) async {
    if (files.isEmpty || _isProcessing) return;

    final file = files.first;
    final url = file.path;

    if (!url.contains('music.youtube.com')) {
      _showSnackbar('Not a YouTube Music link');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Fetching track info...';
    });

    try {
      final track = await _metadataService.fetchTrack(url);
      await _spotifyService.openSearch(track.title, track.artist);
      setState(() => _statusMessage = 'Opening: ${track.title}');
    } on MetadataException {
      _showSnackbar('Could not fetch track info');
      setState(() => _statusMessage = null);
    } catch (e) {
      _showSnackbar('Something went wrong');
      setState(() => _statusMessage = null);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTFY',
      home: Scaffold(
        appBar: AppBar(title: const Text('YTFY')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isProcessing ? Icons.hourglass_empty : Icons.music_note,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage ?? 'Share a YouTube Music link',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _metadataService.dispose();
    ReceiveSharingIntent.instance.reset();
    super.dispose();
  }
}