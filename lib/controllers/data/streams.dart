import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holo_streams/controllers/data/loading.dart';
import 'package:holo_streams/model/filter.dart';
import 'package:holo_streams/model/holo_stream.dart';
import 'package:holo_streams/utils/start_date.dart';

typedef VideoFilterCallback = bool Function(VideoFull video);

class StreamsController extends LoadingController<Map<DateTime, List<HoloStream>>> {
  StreamsController({required super.holodexClient});

  static StreamsController get to => Get.find<StreamsController>();

  static const Duration videoDelta = Duration(hours: 1, minutes: 6, seconds: 6);

  static const VideoFilter defaultFilter = VideoFilter(
    organization: Organization.Hololive,
    includes: [
      Includes.liveInfo,
      Includes.refers,
      Includes.mentions,
      Includes.description,
    ],
    status: [
      VideoStatus.live,
      VideoStatus.upcoming,
    ],
    sort: [VideoSort.startScheduled],
    order: Order.ascending,
    type: VideoType.stream,
    limit: 50,
    maxUpcomingHours: 72,
  );

  Map<DateTime, List<HoloStream>>? where({
    required Map<DateTime, List<HoloStream>>? data,
    required VideoFilterCallback test,
  }) {
    return data?.map((date, streams) {
      return MapEntry(
        date,
        streams.where((stream) => stream.videos.firstWhereOrNull(test) != null).toList(),
      );
    })
      ?..removeWhere((key, value) => value.isEmpty);
  }

  Map<DateTime, List<HoloStream>>? getStreams(Filter filter) {
    if (filter.isAll) {
      return state;
    }
    return where(
      data: state,
      test: (video) => filter.data.contains(video.channel?.id),
    );
  }

  Map<DateTime, List<HoloStream>> groupByDate(List<HoloStream> streams) {
    return streams.groupListsBy<DateTime>((stream) => DateUtils.dateOnly(stream.localStartDate));
  }

  List<HoloStream> toStreams(List<VideoFull> videos) {
    final List<HoloStream> streams = [];
    for (int i = 0; i < videos.length; i++) {
      final video = videos[i];
      if (video.channel == null) {
        continue;
      }
      bool shouldCreateNewStream = true;
      for (int j = streams.length - 1; j >= 0; j--) {
        final stream = streams[j];
        if (video.startDate.difference(stream.lastStartDate) > videoDelta) {
          break;
        }
        late final streamChannelIds = stream.videos.map((s) => s.channel!.id).toSet();
        late final mentionChannelIds = video.mentions.map((channel) => channel.id).toSet();
        if (stream.mentions.contains(video.channel!.id) ||
            mentionChannelIds.intersection(stream.mentions).isNotEmpty ||
            mentionChannelIds.intersection(streamChannelIds).isNotEmpty) {
          stream.add(video);
          shouldCreateNewStream = false;
          break;
        }
      }
      if (shouldCreateNewStream) {
        streams.add(HoloStream(videos: [video]));
      }
    }
    return streams;
  }

  @override
  Future<Map<DateTime, List<HoloStream>>> loadData() async {
    final response =
        await holodexClient.getEndpoint(HolodexEndpoint.live, params: defaultFilter.toJson());
    if (response.statusCode ~/ 100 != 2) {
      throw HolodexException(response.reasonPhrase, response.statusCode, response);
    }

    final streams = <VideoFull>[];
    final List streamList = jsonDecode(response.body);
    for (final streamData in streamList) {
      try {
        if (streamData['status'] == 'missing') {
          continue;
        }
        final stream = VideoFull.fromJson(streamData);
        streams.add(stream);
      } catch (_) {}
    }
    return groupByDate(toStreams(streams));
  }
}
