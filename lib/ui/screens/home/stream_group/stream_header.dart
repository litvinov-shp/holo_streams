import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef HeaderBuilder = Widget? Function(BuildContext context, double backgroundHeight);

typedef HeaderCallback = void Function(double backgroundHeight);

class StreamHeaderBuilder extends RenderObjectWidget {
  const StreamHeaderBuilder({
    super.key,
    required this.offset,
    required this.builder,
  });

  final double offset;

  final HeaderBuilder builder;

  @override
  RenderObjectElement createElement() => StreamHeaderBuilderElement(this);

  @override
  RenderStreamHeaderBuilder createRenderObject(BuildContext context) {
    return RenderStreamHeaderBuilder(offset: offset);
  }

  @override
  void updateRenderObject(BuildContext context, RenderStreamHeaderBuilder renderObject) {
    renderObject.offset = offset;
  }
}

class StreamHeaderBuilderElement extends RenderObjectElement {
  StreamHeaderBuilderElement(StreamHeaderBuilder super.widget);

  @override
  StreamHeaderBuilder get widget => super.widget as StreamHeaderBuilder;

  @override
  RenderStreamHeaderBuilder get renderObject => super.renderObject as RenderStreamHeaderBuilder;

  Element? child;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject._rebuildElement = _build;
    child = updateChild(
      child,
      widget.builder(this, 0.0),
      null,
    );
  }

  @override
  void unmount() {
    renderObject._lastBackgroundColor = 0.0;
    renderObject._rebuildElement = null;
    renderObject.child = null;
    super.unmount();
  }

  @override
  void performRebuild() {
    super.performRebuild();
    renderObject.markNeedsLayout();
  }

  void _build(double backgroundHeight) {
    owner!.buildScope(this, () {
      child = updateChild(
        child,
        widget.builder(this, backgroundHeight),
        null,
      );
      renderObject.child = child?.renderObject as RenderBox?;
    });
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (child != null) {
      visitor(child!);
    }
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, Object? slot) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void forgetChild(Element child) {
    assert(child == this.child);
    this.child = null;
    super.forgetChild(child);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, Object? slot) {
    renderObject.child = null;
  }
}

class RenderStreamHeaderBuilder extends RenderSliverToBoxAdapter {
  RenderStreamHeaderBuilder({
    super.child,
    required double offset,
  }) : _offset = offset;

  double _offset;
  set offset(double value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsLayout();
  }

  HeaderCallback? _rebuildElement;

  double _lastBackgroundColor = 0.0;

  SliverPhysicalParentData get childParentData => (child!.parentData! as SliverPhysicalParentData);

  @override
  set child(RenderBox? value) {
    final oldParentData = child?.parentData;
    super.child = value;
    if (oldParentData != null) {
      value?.parentData = oldParentData;
    }
  }

  @override
  void performLayout() {
    final isFirst = constraints.precedingScrollExtent + constraints.remainingPaintExtent <=
        constraints.viewportMainAxisExtent;
    final remainingPaintExtent = math.max(0.0, constraints.remainingPaintExtent - constraints.overlap);
    final screenPosition = constraints.viewportMainAxisExtent - remainingPaintExtent;
    final paintOffset = math.max(_offset - screenPosition, 0.0);
    childParentData.paintOffset = Offset(0.0, paintOffset);
    final backgroundColor = isFirst ? double.infinity : math.max(screenPosition - _offset, 0.0);

    if (_lastBackgroundColor != backgroundColor) {
      _lastBackgroundColor = backgroundColor;
      invokeLayoutCallback((constraints) {
        _rebuildElement?.call(backgroundColor);
      });
    }

    child?.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final childHeight = child?.size.height ?? 0.0;
    if (childHeight == 0.0) {
      geometry = SliverGeometry.zero;
      return;
    }
    
    // Taken from [RenderSliverPinnedPersistentHeader.performLayout]
    final layoutExtent = clampDouble(childHeight - constraints.scrollOffset, 0.0, remainingPaintExtent);
    geometry = SliverGeometry(
      scrollExtent: childHeight,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childHeight, constraints.remainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: childHeight,
      maxScrollObstructionExtent: childHeight,
      cacheExtent: layoutExtent > 0.0 ? -constraints.cacheOrigin + layoutExtent : layoutExtent,
      hasVisualOverflow: true,
    );
  }
}
