import 'package:flutter/material.dart';
import 'package:holo_streams/model/cross_axis_count.dart';
import 'package:holo_streams/model/holo_stream.dart';
import 'package:holo_streams/ui/screens/home/streams_builder/collab_view.dart';
import 'package:holo_streams/ui/screens/home/streams_builder/one_two_row.dart';
import 'package:holo_streams/ui/screens/home/video_view/video_full_view.dart';

class StreamsBuilder extends StatelessWidget {
  const StreamsBuilder({
    super.key,
    required this.streams,
  });

  final List<HoloStream> streams;

  Widget computeChild(HoloStream stream, [int? crossAxisCount]) {
    if (stream.isSingle) {
      return VideoFullView(stream: stream, videoIndex: 0);
    }
    return CollabView(stream: stream, crossAxisCount: crossAxisCount);
  }

  int computeRow(List<Widget> result, int streamIndex, int crossAxisCount) {
    final HoloStream stream1 = streams[streamIndex];
    if (crossAxisCount == 1) {
      Widget child = computeChild(stream1);
      result.add(child);
      return 1;
    }

    late final HoloStream stream2;
    if (streamIndex == streams.length - 1 ||
        stream1.isSingle != (stream2 = streams[streamIndex + 1]).isSingle) {
      Widget child = computeChild(stream1);
      if (stream1.isSingle) {
        child = OneTwoRow(children: [child]);
      }
      result.add(child);
      return 1;
    }

    final child1 = computeChild(stream1, 1);
    final child2 = computeChild(stream2, 1);
    result.add(OneTwoRow(children: [child1, child2]));
    return 2;
  }

  List<Widget> computeChildren(int crossAxisCount) {
    List<Widget> result = [];
    int index = 0;
    while (index < streams.length) {
      index += computeRow(result, index, crossAxisCount);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final children = computeChildren(context.crossAxisCount);
    return SliverList.separated(
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) {
        if (children[index + 1] is CollabView) {
          return const SizedBox.shrink();
        }
        return const SizedBox(height: 8.0);
      },
    );
  }
}
