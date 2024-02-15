import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  final String id;
  final String nameOfVideo;
  const VideoScreen({super.key, required this.id, required this.nameOfVideo});

  @override
  State<VideoScreen> createState() => _MyVideoScreenState();
}

class _MyVideoScreenState extends State<VideoScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blue[900],
        progressColors: ProgressBarColors(
          playedColor: Colors.blue[900],
          handleColor: Colors.blue[900],
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(widget.nameOfVideo),
          ),
          body: Center(child: player),
        );
      },
    );
  }
}
