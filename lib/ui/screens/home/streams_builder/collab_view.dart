import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/material.dart';
import 'package:holo_streams/model/cross_axis_count.dart';
import 'package:holo_streams/model/holo_stream.dart';
import 'package:holo_streams/ui/screens/home/streams_builder/one_two_row.dart';
import 'package:holo_streams/ui/screens/home/video_view/video_full_view.dart';
import 'package:holo_streams/ui/widgets/list_tile/group_list_tile.dart';
import 'package:holo_streams/utils/quick_theme.dart';

class CollabView extends StatefulWidget {
  const CollabView({
    super.key,
    required this.stream,
    this.ignoreIndex,
    this.crossAxisCount,
    this.listViewPadding,
    this.wrapInBlueBox = true,
    this.videoBuilder,
  }) : assert(crossAxisCount == null || crossAxisCount == 1 || crossAxisCount == 2);

  final HoloStream stream;

  final int? ignoreIndex;

  final int? crossAxisCount;

  final EdgeInsets? listViewPadding;

  final bool wrapInBlueBox;

  final ValueWidgetBuilder<VideoFull>? videoBuilder;

  @override
  State<CollabView> createState() => _CollabViewState();
}

class _CollabViewState extends State<CollabView> {
  // With keepScrollOffset CustomScrollView constanly flicks when scrolling back up
  final _scrollController = ScrollController(keepScrollOffset: false);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;
    final crossAxisCount = widget.crossAxisCount ?? context.crossAxisCount;
    final effectiveListLength = widget.stream.videos.length - (widget.ignoreIndex == null ? 0 : 1);

    final collabSliverList = SliverPadding(
      padding: widget.listViewPadding ?? const EdgeInsets.all(8.0),
      sliver: SliverList.separated(
        itemCount: (effectiveListLength - 1) ~/ crossAxisCount + 1,
        itemBuilder: (context, index) {
          final startingIndex = index * crossAxisCount;
          final indexOffset = widget.ignoreIndex == null || index < widget.ignoreIndex! ? 0 : 1;
          return OneTwoRow(
            children: [
              for (int jndex = 0;
                  jndex < crossAxisCount && startingIndex + jndex < effectiveListLength;
                  jndex++)
                widget.videoBuilder?.call(context, widget.stream[startingIndex + jndex + indexOffset], null) ??
                    VideoFullView(
                      stream: widget.stream,
                      videoIndex: startingIndex + jndex + indexOffset,
                    ),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      ),
    );

    if (!widget.wrapInBlueBox) {
      return collabSliverList;
    }

    return GroupListTile(
      title: 'Collab',
      color: primaryColor,
      child: CustomScrollView(
        controller: _scrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        slivers: [collabSliverList],
      ),
    );
  }
}
