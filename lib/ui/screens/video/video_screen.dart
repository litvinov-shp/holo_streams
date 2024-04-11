import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:holo_streams/model/holo_stream.dart';
import 'package:holo_streams/ui/screens/home/stream_group/stream_header.dart';
import 'package:holo_streams/ui/screens/home/streams_builder/collab_view.dart';
import 'package:holo_streams/ui/screens/home/video_view/video_full_view.dart';
import 'package:holo_streams/ui/screens/home/video_view/video_view.dart';
import 'package:holo_streams/utils/context_navigator.dart';
import 'package:holo_streams/utils/holo_url_launcher.dart';
import 'package:holo_streams/utils/quick_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({
    super.key,
    required this.stream,
    required this.videoIndex,
  });

  final HoloStream stream;

  final int videoIndex;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final headerStyle = theme.textTheme.titleMedium;

    final video = stream[videoIndex];
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => watchVideo(stream[videoIndex].id),
        label: const Text('Watch on YouTube'),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                onPressed: context.pop,
                icon: const Icon(Symbols.arrow_back),
              ),
            ),
            SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: 'https://i.ytimg.com/vi/${video.id}/maxresdefault.jpg',
                  fit: BoxFit.fitHeight,
                  placeholder: (context, url) {
                    return ColoredBox(color: theme.colorScheme.secondaryContainer);
                  },
                ),
              ),
            ),
            StreamHeaderBuilder(
              offset: 0.0,
              builder: (context, backgroundHeight) {
                final topPadding = MediaQuery.of(context).padding.top;

                late final backgroundColor = context.colorScheme.surface;
                late final tintedColor = ElevationOverlay.applySurfaceTint(
                    backgroundColor, context.colorScheme.surfaceTint, 3.0);
                return ColoredBox(
                  color: backgroundHeight == 0 ? tintedColor : backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.only(top: math.max(topPadding - backgroundHeight / 2, 0.0)),
                    child: VideoFullView(
                      stream: stream,
                      videoIndex: videoIndex,
                      isClickable: false,
                    ),
                  ),
                );
              },
            ),
            if (stream.isCollab) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Text('Collabing with:', style: headerStyle),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                sliver: CollabView(
                  stream: stream,
                  ignoreIndex: videoIndex,
                  listViewPadding: EdgeInsets.zero,
                  wrapInBlueBox: false,
                ),
              ),
            ],
            if (video.refers.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Text('Other videos:', style: headerStyle),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                sliver: CollabView(
                  stream:
                      HoloStream(videos: video.refers.map((refer) => refer.toVideoFull()).toList()),
                  listViewPadding: EdgeInsets.zero,
                  wrapInBlueBox: false,
                  videoBuilder: (context, refer, child) {
                    return VideoView(video: refer);
                  },
                ),
              ),
            ],
            if (video.description != null)
              SliverPadding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                sliver: SliverList.list(
                  children: [
                    Text('Description:', style: headerStyle),
                    Linkify(
                      text: video.description!,
                      options: const LinkifyOptions(removeWww: true),
                      linkStyle: const TextStyle(decoration: TextDecoration.none),
                      onOpen: (link) => launchHoloUrl(link.url),
                    ),
                  ],
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 72.0)),
          ],
        ),
      ),
    );
  }
}
