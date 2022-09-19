import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';

import 'domain/mux_live_data.dart';
import 'domain/mux_video_data.dart';

class MuxService {
  FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<MuxLiveData> createLiveStream() async {
    // TODO: Create a live stream session

    final callable = functions.httpsCallable('createLiveStream');
    final response = await callable();
    final muxLiveData = MuxLiveData.fromJson(response.data);
    return muxLiveData;
  }

  Future<List<MuxLiveData>> getLiveStreams() async {
    // TODO: Get the list of live streams
    final callable = functions.httpsCallable('retrieveLiveStreams');
    final response = await callable();
    log(response.data.toString());
    Iterable l = response.data;
    log(l.toString());

    List<MuxLiveData> streamList = List<MuxLiveData>.from(
      l.map(
        (model) => MuxLiveData.fromJson(
          Map<String, dynamic>.from(model),
        ),
      ),
    );
    log(streamList.toString());
    return streamList;
  }

  Future<void> deleteLiveStream({required String liveStreamId}) async {
    final callable = functions.httpsCallable('deleteLiveStream');
    await callable.call({
      'liveStreamId': liveStreamId,
    });
  }

  Future<List<MuxVideoData>> getVideos() async {
    final callable = functions.httpsCallable('getVideo');
    final response = await callable();
    log(response.data.toString());
    Iterable l = response.data;
    log(l.toString());
    List<MuxVideoData> videoList = List<MuxVideoData>.from(
      l.map(
        (model) => MuxVideoData.fromJson(
          Map<String, dynamic>.from(model),
        ),
      ),
    );
    log(videoList.toString());
    return videoList;
  }
}
