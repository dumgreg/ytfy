import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';
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
      setState(() => _statusMessage = 'Not a YouTube Music link');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Fetching track info...';
    });

    try {
      final track = await _metadataService.fetchTrack(url);
      final spotifyUrl = _spotifyService.buildSearchUrl(track.title, track.artist);
      if (!mounted) return;
      setState(() => _statusMessage = 'Choose where to open');

      final result = await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(spotifyUrl), subject: track.title),
      );

      if (!mounted) return;
      if (result.status == ShareResultStatus.success) {
        await SystemNavigator.pop();
      } else if (result.status == ShareResultStatus.dismissed) {
        setState(() => _statusMessage = 'Share cancelled');
      } else {
        setState(() => _statusMessage = 'Share unavailable');
      }
    } on MetadataException {
      if (mounted) setState(() => _statusMessage = 'Could not fetch track info');
    } catch (e) {
      if (mounted) setState(() => _statusMessage = 'Something went wrong');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
              SizedBox(
                width: 120,
                height: 120,
                child: _isProcessing
                    ? const CircularProgressIndicator(strokeWidth: 3)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/icon_home.png',
                          fit: BoxFit.cover,
                        ),
                      ),
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