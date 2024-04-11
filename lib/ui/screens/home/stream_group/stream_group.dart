import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:holo_streams/ui/screens/home/stream_group/stream_header.dart';

class StreamGroup extends SliverMainAxisGroup {
  const StreamGroup({super.key, required super.slivers});

  @override
  RenderSliverMainAxisGroup createRenderObject(BuildContext context) => RenderStreamGroup();
}

class RenderStreamGroup extends RenderSliverMainAxisGroup {
  @override
  void paint(PaintingContext context, Offset offset) {
    RenderSliver? child = firstChild;

    final headers = <RenderStreamHeaderBuilder>[];
    while (child != null) {
      if (child is! RenderStreamHeaderBuilder) {
        paintChild(context, offset, child);
      } else {
        headers.add(child);
      }
      child = childAfter(child);
    }

    for (final header in headers) {
      paintChild(context, offset, header);
    }
  }

  void paintChild(PaintingContext context, Offset offset, RenderSliver child) {
    final childParentData = child.parentData! as SliverPhysicalParentData;
    context.paintChild(child, offset + childParentData.paintOffset);
  }
}
