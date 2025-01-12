import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerScreen extends StatefulWidget {
  const YouTubePlayerScreen({Key? key}) : super(key: key);

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  TextEditingController _urlController = TextEditingController();
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
  }

  void _loadVideo() {
    String url = _urlController.text.trim();
    if (url.isNotEmpty) {
      String? videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        setState(() {
          _controller.load(videoId);
        });
      } else {
        _showErrorDialog('Invalid YouTube URL!');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Player')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input for YouTube URL
            const Text('Enter YouTube Video URL:'),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'e.g. https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Button to load video
            Center(
              child: ElevatedButton(
                onPressed: _loadVideo,
                child: const Text('Play Video'),
              ),
            ),
            SizedBox(height: 20),
            // Youtube Player to display video
            Expanded(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                onReady: () {
                  print('Player is ready.');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
