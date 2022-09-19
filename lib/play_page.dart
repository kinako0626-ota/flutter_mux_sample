import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mux/domain/mux_video_data.dart';
import 'package:video_player/video_player.dart';

import 'res/strings.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  final MuxVideoData videoData;

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late final VideoPlayerController _videoController;
  late final ChewieController _chewieController;
  late final MuxVideoData _videoData;

  @override
  void initState() {
    // Let's initialize a controller for the video playback inside the initState().
    // For the playback, you have to use the https://stream.mux.com URL along with the playback ID and the video extension (.m3u8).
    // TODO (1): Initialize the video player controller
    super.initState();
    _videoData = widget.videoData;
    String playbackId = _videoData.playbackIds[0].id;

    _videoController = VideoPlayerController.network(
        '$muxStreamBaseUrl/$playbackId.$videoExtension')
      ..initialize().then((_) => setState(() {}));
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
    );
    _chewieController.play();
  }

  @override
  void dispose() {
    // TODO (2): Dispose the video player controller
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO (3): Show the video playback
    return Scaffold(
      appBar: AppBar(
        title: Text(_videoData.playbackIds[0].id),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController,
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.pink,
                  ),
                  strokeWidth: 2,
                ),
              ),
      ),
    );
  }
}
