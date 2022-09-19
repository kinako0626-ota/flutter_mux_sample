const functions = require("firebase-functions");
const Mux = require("@mux/mux-node");
const dotenv = require("dotenv");

dotenv.config();

const {Video} = new Mux(process.env.MUX_TOKEN_ID, process.env.MUX_TOKEN_SECRET);

exports.createLiveStream = functions.https.onCall(async (data, context) => {
  try {
    const response = await Video.LiveStreams.create({
      playback_policy: "public",
      new_asset_settings: {playback_policy: "public"},
    });

    return response;
  } catch (err) {
    console.error(
      `Unable to start the live stream ${context.auth.uid}. 
        Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not create live stream",
    );
  }
});

exports.retrieveLiveStreams = functions.https.onCall(async (data, context) => {
  try {
    const liveStreams = await Video.LiveStreams.list();

    const responseList = liveStreams.map((liveStream) => ({
      id: liveStream.id,
      status: liveStream.status,
      playback_ids: liveStream.playback_ids,
      created_at: liveStream.created_at,
    }));

    return responseList;
  } catch (err) {
    console.error(
      `Unable to retrieve live streams. 
        Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not retrieve live streams",
    );
  }
});

exports.deleteLiveStream = functions.https.onCall(async (data, context) => {
  try {
    const liveStreamId = data.liveStreamId;
    const response = await Video.LiveStreams.del(liveStreamId);

    return response;
  } catch (err) {
    console.error(
      `Unable to delete live stream, id: ${data.liveStreamId}. 
      Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not delete live stream",
    );
  }
});

exports.getVideo = functions.https.onCall(async (data, context) => {
  try {
    const videos = await Video.Assets.list();
    const responseList = videos.map((video) => ({
      id: video.id,
      status: video.status,
      playback_ids: video.playback_ids,
      created_at: video.created_at,
    }));
    return responseList;
  } catch (err) {
    console.error(
      `Unable to retrieve video, id: ${data.videoId}. 
      Error ${err}`,
    );
    throw new functions.https.HttpsError("aborted", "Could not retrieve video");
  }
});
