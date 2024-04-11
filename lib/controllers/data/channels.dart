import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:get/get.dart';
import 'package:holo_streams/controllers/data/loading.dart';
import 'package:holo_streams/utils/effective_channel_name.dart';

class ChannelsController extends LoadingController<List<Channel>> {
  ChannelsController({required super.holodexClient});

  static ChannelsController get to => Get.find();

  static const defaultFilter = ChannelFilter(
    limit: 50,
    type: ChannelType.vtuber,
    organization: Organization.Hololive,
  );

  bool get hasMore => _hasMore;
  bool _hasMore = true;

  String getBranch(String generationName) {
    final name = generationName.trim().toLowerCase();
    if (name.contains('holostars')) return 'HOLOSTARS';
    if (name.contains('indonesia')) return 'Indonesia';
    if (name.contains('english')) return 'English';
    if (name.contains('dev_is')) return 'DEV_IS';
    if (name.contains('china') || name == 'cn 1st generation') return 'China';
    if (name.contains('generation') || name == 'gamers') return 'Japan';
    return 'Other';
  }

  Map<String, Map<String, List<Channel>>> get branches {
    final channels = value?.sorted((a, b) {
      if (a.group == null || b.group == null) {
        if (a.group != null) return -1;
        if (b.group != null) return 1;
        return 0;
      }
      return a.group!.compareTo(b.group!);
    });

    final generations = channels?.groupListsBy((channel) => channel.group ?? 'Other') ?? {};
    for (final channels in generations.values) {
      channels.sortBy((channel) => channel.effectiveName);
    }
    final fubuki = channels?.firstWhereOrNull((channel) => channel.name == 'Shirakami Fubuki');
    if (fubuki != null) {
      generations['GAMERS']?.add(fubuki);
    }

    final branches = Map<String, Map<String, List<Channel>>>.fromIterable(
      ['Japan', 'DEV_IS', 'English', 'Indonesia', 'China', 'HOLOSTARS', 'Other'],
      value: (_) => {},
    );
    for (final generationEntry in generations.entries) {
      branches[getBranch(generationEntry.key)]![generationEntry.key] = generationEntry.value;
    }
    return branches;
  }

  Future<List<Channel>> loadChannels(int page) async {
    int retryCount = 0;
    HolodexException? exception;
    while (retryCount < 3) {
      final response = await holodexClient.getEndpoint(
        HolodexEndpoint.channels,
        params: defaultFilter.copyWith(offset: page * 50).toJson(),
      );
      if (response.statusCode ~/ 100 != 2) {
        exception = HolodexException(response.reasonPhrase, response.statusCode, response);
        if (++retryCount >= 2) {
          throw exception;
        }
      }

      final channels = <Channel>[];
      final channelList = jsonDecode(response.body) as List;
      if (channelList.length < 50) {
        _hasMore = false;
      }
      for (final channelData in channelList) {
        try {
          final channel = Channel.fromJson(channelData);
          channels.add(channel);
        } catch (_) {}
      }
      return channels;
    }
    throw exception ?? const HttpException('Error: max retries exceeded');
  }

  @override
  Future<List<Channel>> loadData() async {
    final channelsByPages = await Future.wait([
      loadChannels(0),
      loadChannels(1),
    ]);
    int page = 2;
    while (_hasMore) {
      channelsByPages.add(await loadChannels(page++));
    }
    return channelsByPages.expand((channelsPage) => channelsPage).toList();
  }
}
