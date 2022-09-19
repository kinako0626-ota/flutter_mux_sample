import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'domain/mux_live_data.dart';
import 'res/strings.dart';

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({
    Key? key,
    required this.streamData,
  }) : super(key: key);

  final MuxLiveData streamData;

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  late final VideoPlayerController _videoController;
  late final MuxLiveData _streamData;

  @override
  void initState() {
    // Let's initialize a controller for the video playback inside the initState().
    // For the playback, you have to use the https://stream.mux.com URL along with the playback ID and the video extension (.m3u8).
    // TODO (1): Initialize the video player controller
    super.initState();

    _streamData = widget.streamData;
    String playbackId = _streamData.playbackIds[0].id;

    _videoController = VideoPlayerController.network(
        '$muxStreamBaseUrl/$playbackId.$videoExtension')
      ..initialize().then((value) => setState(() {}));
    // The play() method is called on the video controller to start the video playback as soon as the initialization is complete.
    _videoController.play();
  }

  @override
  void dispose() {
    // TODO (2): Dispose the video player controller
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO (3): Show the video playback
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_streamData.playbackIds[0].id),
      ),
      body: SafeArea(
        child: _videoController.value.isInitialized
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
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
