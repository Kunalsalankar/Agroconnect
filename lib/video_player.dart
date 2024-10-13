import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Initialize the video player controller with a local or network video
    _controller = VideoPlayerController.network(
      'https://www.example.com/video.mp4', // Replace with your video URL or local path
    )..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized.
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Dispose the controller when not in use
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {
                    setState(() {
                      _controller.pause();
                      _controller.seekTo(Duration.zero);
                    });
                  },
                ),
              ],
            ),
          ],
        )
            : CircularProgressIndicator(), // Loading indicator while the video is being initialized
      ),
    );
  }
}
