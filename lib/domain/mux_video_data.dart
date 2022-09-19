import 'dart:convert';

class MuxVideoData {
  MuxVideoData({
    required this.status,
    required this.id,
    required this.createdAt,
    required this.playbackIds,
  });

  String status;
  String id;
  String createdAt;
  List<PlaybackId> playbackIds;

  factory MuxVideoData.fromRawJson(String str) =>
      MuxVideoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MuxVideoData.fromJson(Map<String, dynamic> json) => MuxVideoData(
        status: json["status"],
        playbackIds: List<PlaybackId>.from(json["playback_ids"]
            .map((x) => PlaybackId.fromJson(Map<String, dynamic>.from(x)))),
        id: json["id"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "playback_ids": List<dynamic>.from(playbackIds.map((x) => x.toJson())),
        "id": id,
        "created_at": createdAt,
      };
}

class PlaybackId {
  PlaybackId({
    required this.policy,
    required this.id,
  });

  String policy;
  String id;

  factory PlaybackId.fromRawJson(String str) =>
      PlaybackId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PlaybackId.fromJson(Map<String, dynamic> json) => PlaybackId(
        policy: json["policy"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "policy": policy,
        "id": id,
      };
}
