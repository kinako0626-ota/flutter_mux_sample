import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mux/mux_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_stream/camera.dart';
import 'package:wakelock/wakelock.dart';

import 'domain/mux_live_data.dart';
import 'main.dart';
import 'res/strings.dart';

class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({Key? key}) : super(key: key);

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  CameraController? _controller;
  late final MuxService _muxClient;

  MuxLiveData? _sessionData;

  /// For showing the camera preview, check if the permission is granted and the camera is initialized, then you can use the CameraPreview widget:
  bool _isCameraPermissionGranted = false;
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  bool _isStreaming = false;
  bool _isFrontCamSelected = true;

  Timer? _timer;
  String? _durationString;
  final _stopwatch = Stopwatch();

  _getPermissionStatus() async {
    // TODO (1): Get the camera permission, if granted start initializing it
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      // with front camera
      // camera[0]: Back camera of the device.
      // camera[1]: Front camera of the device.
      _onNewCameraSelected(cameras[1]);
    } else {
      log('Camera Permission: DENIED');
    }
  }

  _onNewCameraSelected(CameraDescription cameraDescription) async {
    // TODO (2): Initialize a new camera
    // A new CameraController object is created.
    // A listener is attached to the camera controller for tracking the current state.
    // While the live stream is in progress, enable Wakelock to prevent the device from going to sleep.
    //Finally, the camera preview is started by calling the initialize() method on the camera controller.
    setState(() {
      _isCameraInitialized = false;
    });

    final previousCameraController = _controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
      androidUseOpenGL: true,
    );

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    _controller!.addListener(() {
      _isStreaming = _controller!.value.isStreamingVideoRtmp;
      _isCameraInitialized = _controller!.value.isInitialized;

      if (_isStreaming) {
        _startTimer();
        Wakelock.enable();
      } else {
        _stopTimer();
        Wakelock.disable();
      }

      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      log('Error initializing camera: $e');
    }
  }

  _startVideoStreaming() async {
    // TODO (3): Create the streaming session using the MuxClient
    //          and start the live video stream

    await _createSession();

    String url = streamBaseURL + _sessionData!.streamKey!;

    try {
      await _controller!.startVideoStreaming(url, androidUseOpenGL: false);
    } on CameraException catch (e) {
      log(e.toString());
    }
  }

  _stopVideoStreaming() async {
    // TODO (4): Stop the live video stream
    try {
      await _controller!.stopVideoStreaming();
    } on CameraException catch (e) {
      log(e.toString());
    }
  }

  _startTimer() {
    // TODO (5): Start duration timer
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _durationString = _getDurationString(_stopwatch.elapsed);
        });
      }
    });
  }

  _stopTimer() {
    // TODO (6): Stop duration timer..
    _stopwatch.stop();
    _stopwatch.reset();
    _durationString = _getDurationString(_stopwatch.elapsed);

    _timer?.cancel();
  }

  /// The _createSession() method will be used for creating the live stream by calling the respective method of the MuxClient:
  _createSession() async {
    setState(() {
      _isInitializing = true;
    });

    final sessionData = await _muxClient.createLiveStream();

    setState(() {
      _sessionData = sessionData;
      _isInitializing = false;
    });
  }

  /// To get the Duration object as a String, you can use this method:
  String _getDurationString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    _muxClient = MuxService();
    _getPermissionStatus();

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _stopwatch.stop();
    _timer?.cancel();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _onNewCameraSelected(_controller!.description!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO (7): Display the __buildCameraPreview and _flipCameraButton and _streamDuration

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
      ),
      body: Stack(
        children: [
          _buildCameraPreview(),
          _flipCameraButton(),
          _streamDuration(),
        ],
      ),
      floatingActionButton: _isCameraInitialized
          ? _isStreaming
              ? FloatingActionButton(
                  onPressed: _stopVideoStreaming,
                  child: const Icon(Icons.stop),
                )
              : FloatingActionButton(
                  onPressed: _startVideoStreaming,
                  child: const Icon(Icons.play_arrow),
                )
          : null,
    );
  }

  Widget _buildCameraPreview() {
    return _isCameraPermissionGranted
        ? _isCameraInitialized
            ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              )
        : const Center(
            child: Text('Camera Permission Denied'),
          );
  }

  Widget _flipCameraButton() {
    return InkWell(
      onTap: () {
        _isFrontCamSelected
            ? _onNewCameraSelected(cameras[0])
            : _onNewCameraSelected(cameras[1]);

        setState(() {
          _isFrontCamSelected = !_isFrontCamSelected;
        });
      },
      child: const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.black54,
        child: Center(
          child: Icon(
            Icons.flip_camera_android,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _streamDuration() {
    return _isStreaming
        ? Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 16.0,
              right: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  _durationString ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
