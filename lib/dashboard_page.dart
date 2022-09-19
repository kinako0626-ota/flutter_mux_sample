import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mux/mux_service.dart';
import 'package:mux/video_tile.dart';

import 'domain/mux_live_data.dart';
import 'domain/mux_video_data.dart';
import 'live_stream_page.dart';
import 'res/strings.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final MuxService _muxClient;

  List<MuxLiveData>? _streams;
  List<MuxVideoData>? _videos;
  bool _isRetrieving = false;

  _getStreams() async {
    setState(() {
      _isRetrieving = true;
    });

    var streams = await _muxClient.getLiveStreams();

    setState(() {
      _streams = streams;

      _isRetrieving = false;
    });
  }

  _getVideos() async {
    setState(() {
      _isRetrieving = true;
    });

    var videos = await _muxClient.getVideos();

    setState(() {
      _videos = videos;
      _isRetrieving = false;
    });
    log('Videos: ${videos.length}');
  }

  @override
  void initState() {
    _muxClient = MuxService();
    _getStreams();
    _getVideos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ライブ配信アプリのサンプル',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // TODO (2): Display the list of streams
      body: RefreshIndicator(
        onRefresh: () {
          _getStreams();
          _getVideos();
          return Future.value();
        },
        child: !_isRetrieving && _streams != null
            ? _streams!.isEmpty
                ? const Center(
                    child: Text('Empty'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          'Live Streams',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _streams!.length,
                          itemBuilder: (context, index) {
                            DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                              int.parse(_streams![index].createdAt) * 1000,
                            );
                            DateFormat formatter = DateFormat('yyyy/M/d H:mm');
                            String dateTimeString = formatter.format(dateTime);

                            String currentStatus = _streams![index].status;
                            log('Current Status: $currentStatus');
                            bool isReady = currentStatus == 'active';

                            String? playbackId = isReady
                                ? _streams![index].playbackIds[0].id
                                : null;

                            String? thumbnailURL = isReady
                                ? '$muxImageBaseUrl/$playbackId/$imageTypeSize'
                                : null;

                            return VideoTile(
                              streamData: _streams![index],
                              thumbnailUrl: thumbnailURL,
                              isReady: isReady,
                              dateTimeString: dateTimeString,
                              onTap: (id) async {
                                await _muxClient.deleteLiveStream(
                                    liveStreamId: id);
                                _getStreams();
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(
                            height: 16.0,
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                        const Text(
                          'Videos',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _videos!.length,
                          itemBuilder: (context, index) {
                            DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                              int.parse(_videos![index].createdAt) * 1000,
                            );
                            DateFormat formatter = DateFormat('yyyy/M/d H:mm');
                            String dateTimeString = formatter.format(dateTime);

                            String currentStatus = _videos![index].status;
                            log('Current Status: $currentStatus');
                            bool isReady = currentStatus == 'ready';

                            String? playbackId = isReady
                                ? _videos![index].playbackIds[0].id
                                : null;

                            String? thumbnailURL = isReady
                                ? '$muxImageBaseUrl/$playbackId/$imageTypeSize'
                                : null;

                            return VideoMuxTile(
                              videoData: _videos![index],
                              thumbnailUrl: thumbnailURL,
                              isReady: isReady,
                              dateTimeString: dateTimeString,
                              onTap: (id) async {
                                await _muxClient.deleteLiveStream(
                                    liveStreamId: id);
                                _getVideos();
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(
                            height: 16.0,
                          ),
                        ),
                      ],
                    ),
                  )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LiveStreamPage(),
            ),
          );
        },
        child: const FaIcon(FontAwesomeIcons.video),
      ),
    );
  }
}
