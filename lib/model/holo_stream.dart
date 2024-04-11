import 'package:collection/collection.dart';
import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/foundation.dart';
import 'package:holo_streams/utils/start_date.dart';

class HoloStream {
  HoloStream({required List<VideoFull> videos})
      : _videos = videos,
        _mentions = computeMentions(videos),
        assert(videos.isNotEmpty);

  static Set<String> computeMentions(Iterable<VideoFull> videos) =>
      videos.expand((video) => video.mentions.map((channel) => channel.id)).toSet();

  List<VideoFull> get videos => List.of(_videos);
  final List<VideoFull> _videos;

  Set<String> get mentions => Set.of(_mentions);
  final Set<String> _mentions;

  VideoFull? get video => _videos.singleOrNull;

  bool get isSingle => _videos.length <= 1;

  bool get isCollab => !isSingle;

  DateTime get startDate => _videos.first.startDate;

  DateTime get localStartDate => startDate.toLocal();

  DateTime get lastStartDate => _videos.last.startDate;

  DateTime get localLastStartDate => lastStartDate.toLocal();

  VideoFull operator [](int index) => _videos[index];

  void add(VideoFull video) {
    _videos.add(video);
    _mentions.addAll(video.mentions.map((channel) => channel.id));
  }

  @override
  bool operator ==(other) => other is HoloStream && listEquals(videos, other.videos);
  
  @override
  int get hashCode => videos.hashCode;
}
