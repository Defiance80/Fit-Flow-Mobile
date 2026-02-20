// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:collection';

import 'package:elms/common/models/blueprints.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Quality {
  final String name;
  final String url;
  Quality({
    required this.name,
    required this.url,
  });

  factory Quality.notSpecified() {
    return Quality(name: '', url: '');
  }
}

class HostedVideo extends VideoSource {
  final String url;
  HostedVideo(this.url);

  @override
  FutureOr<String> getSource() {
    return url;
  }
}

class YoutubeVideo extends VideoSource {
  final String videoId;
  YoutubeVideo(this.videoId);
  static final YoutubeExplode yt = YoutubeExplode();
  List<Quality> _videoQualities = [];

  @override
  FutureOr<String> getSource() async {
    final UnmodifiableListView<MuxedStreamInfo> muxed =
        (await yt.videos.streamsClient.getManifest(videoId, ytClients: [
      YoutubeApiClient.androidVr,
      YoutubeApiClient.ios,
    ]))
            .muxed;

    _videoQualities = muxed.map(
      (quality) {
        return Quality(name: quality.qualityLabel, url: quality.url.toString());
      },
    ).toList();

    return muxed.withHighestBitrate().url.toString();
  }

  @override
  List<Quality> getQualities() {
    return _videoQualities;
  }
}
