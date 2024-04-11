import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class VideoSubtitleTextPainter extends TextPainter {
  VideoSubtitleTextPainter({
    super.text,
    super.textAlign,
    super.textDirection,
    super.textScaleFactor,
    super.maxLines,
    super.ellipsis,
    super.locale,
    super.strutStyle,
    super.textWidthBasis = TextWidthBasis.parent,
    super.textHeightBehavior,
  });

  ui.Offset paintOffset = ui.Offset.zero;

  @override
  void paint(ui.Canvas canvas, ui.Offset offset) {
    super.paint(canvas, offset + paintOffset);
  }
}

class VideoSubtitleParentData extends TextParentData {
  @override
  ui.Offset? get offset => _offset;
  ui.Offset? _offset;
}

class VideoSubtitle extends MultiChildRenderObjectWidget {
  VideoSubtitle({
    super.key,
    required this.name,
    required this.time,
    required this.timeDifference,
    required this.liveViewers,
    this.textDirection,
  }) : super(
          children: [
            ...WidgetSpan.extractFromInlineSpan(name, TextScaler.noScaling),
            ...WidgetSpan.extractFromInlineSpan(time, TextScaler.noScaling),
            ...WidgetSpan.extractFromInlineSpan(timeDifference, TextScaler.noScaling),
            if (liveViewers != null) ...WidgetSpan.extractFromInlineSpan(liveViewers, TextScaler.noScaling),
          ],
        );

  final InlineSpan name;

  final InlineSpan time;

  final InlineSpan timeDifference;

  final InlineSpan? liveViewers;

  final TextDirection? textDirection;

  @override
  RenderVideoSubtitle createRenderObject(BuildContext context) {
    return RenderVideoSubtitle(
      name: name,
      time: time,
      timeDifference: timeDifference,
      liveViewers: liveViewers,
      textDirection: textDirection ?? Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderVideoSubtitle renderObject) {
    renderObject.name = name;
    renderObject.time = time;
    renderObject.timeDifference = timeDifference;
    renderObject.liveViewers = liveViewers;
    renderObject.textDirection = textDirection ?? Directionality.of(context);
  }
}

class RenderVideoSubtitle extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TextParentData>,
        RenderInlineChildrenContainerDefaults,
        RelayoutWhenSystemFontsChangeMixin {
  RenderVideoSubtitle({
    required InlineSpan name,
    required InlineSpan time,
    required InlineSpan timeDifference,
    required InlineSpan? liveViewers,
    required TextDirection textDirection,
  }) {
    _textDirection = textDirection;
    _nameTextPainter = _createTextPainter(name);
    _timeTextPainter = _createTextPainter(time);
    _timeDifferenceTextPainter = _createTextPainter(timeDifference);
    _liveViewersTextPainter = _createTextPainter(liveViewers);
  }

  late VideoSubtitleTextPainter _nameTextPainter;
  late VideoSubtitleTextPainter _timeTextPainter;
  late VideoSubtitleTextPainter _timeDifferenceTextPainter;
  late VideoSubtitleTextPainter _liveViewersTextPainter;

  List<VideoSubtitleTextPainter> get _textPainters => [
        _nameTextPainter,
        _timeTextPainter,
        _timeDifferenceTextPainter,
        _liveViewersTextPainter,
      ];

  bool _hasAdditionalLine = false;
  bool _paintLiveViewers = true;

  VideoSubtitleTextPainter _createTextPainter(InlineSpan? text) {
    return VideoSubtitleTextPainter(
      text: text,
      textDirection: _textDirection,
    );
  }

  void _updateTextPainter(TextPainter textPainter, InlineSpan? value) {
    if (value == null) {
      if (textPainter.text != null) {
        textPainter.text = value;
        markNeedsLayout();
      }
      return;
    }

    switch (textPainter.text?.compareTo(value)) {
      case RenderComparison.identical:
        return;
      case RenderComparison.metadata:
        markNeedsSemanticsUpdate();
      case RenderComparison.paint:
        markNeedsSemanticsUpdate();
        markNeedsPaint();
      case RenderComparison.layout:
      case null:
        markNeedsLayout();
    }

    textPainter.text = value;
  }

  set name(InlineSpan value) => _updateTextPainter(_nameTextPainter, value);

  set time(InlineSpan value) => _updateTextPainter(_timeTextPainter, value);

  set timeDifference(InlineSpan value) => _updateTextPainter(_timeDifferenceTextPainter, value);

  set liveViewers(InlineSpan? value) => _updateTextPainter(_liveViewersTextPainter, value);

  TextDirection get textDirection => _textDirection;
  late TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = textDirection;
    for (final textPainter in _textPainters) {
      textPainter.textDirection = _textDirection;
    }
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  @override
  void systemFontsDidChange() {
    super.systemFontsDidChange();
    for (final textPainter in _textPainters) {
      textPainter.markNeedsLayout();
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! VideoSubtitleParentData) {
      child.parentData = VideoSubtitleParentData();
    }
  }

  @override
  void dispose() {
    for (final textPainter in _textPainters) {
      textPainter.dispose();
    }
    super.dispose();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return computeMaxIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return super.computeMaxIntrinsicHeight(width);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return layoutText(constraints.maxWidth);
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth, 'StreamSubtitle must have a bounded width');
    layoutInlineChildren(constraints.maxWidth, ChildLayoutHelper.layoutChild);
    final unconstrainedSize = layoutText();
    positionText();
    positionInlineChildren();
    size = constraints.constrain(unconstrainedSize);
  }

  (List<PlaceholderDimensions>, RenderBox?) layoutChildren(
      double maxWidth, ChildLayouter layoutChild, TextPainter textPainter, RenderBox? child) {
    List<PlaceholderDimensions> dimensions = [];
    if (textPainter.text == null) {
      return (dimensions, child);
    }
    for (final _ in WidgetSpan.extractFromInlineSpan(textPainter.text!, TextScaler.noScaling)) {
      if (child == null) {
        break;
      }
      final VideoSubtitleParentData parentData = child.parentData! as VideoSubtitleParentData;
      PlaceholderSpan? span = parentData.span;
      PlaceholderDimensions dimension = span == null
          ? PlaceholderDimensions.empty
          : PlaceholderDimensions(
              size: layoutChild(child, BoxConstraints(maxWidth: maxWidth)),
              alignment: span.alignment,
              baseline: span.baseline,
              baselineOffset: switch (span.alignment) {
                ui.PlaceholderAlignment.baseline => child.getDistanceToBaseline(span.baseline!),
                _ => null,
              },
            );
      dimensions.add(dimension);
      child = childAfter(child);
    }
    textPainter.setPlaceholderDimensions(dimensions);
    return (dimensions, child);
  }

  @override
  List<PlaceholderDimensions> layoutInlineChildren(double maxWidth, ChildLayouter layoutChild) {
    List<PlaceholderDimensions> placeholderDimensions = [];
    RenderBox? child = firstChild;
    for (final textPainter in _textPainters) {
      List<PlaceholderDimensions> dimensions;
      (dimensions, child) = layoutChildren(maxWidth, ChildLayoutHelper.layoutChild, textPainter, child);
      placeholderDimensions.addAll(dimensions);
    }
    return placeholderDimensions;
  }

  RenderBox? positionChildren(VideoSubtitleTextPainter textPainter, RenderBox? child) {
    for (final ui.TextBox box in textPainter.inlinePlaceholderBoxes ?? []) {
      if (child == null) {
        break;
      }
      final VideoSubtitleParentData textParentData = child.parentData! as VideoSubtitleParentData;
      textParentData._offset = textPainter.paintOffset + Offset(box.left, box.top);
      child = childAfter(child);
    }
    return child;
  }

  @override
  void positionInlineChildren([List<ui.TextBox>? boxes]) {
    if (boxes != null) {
      super.positionInlineChildren(boxes);
    }
    RenderBox? child = firstChild;
    for (final textPainter in _textPainters) {
      child = positionChildren(textPainter, child);
    }
  }

  Size layoutText([double? maxWidth]) {
    maxWidth ??= constraints.maxWidth;

    _nameTextPainter.layout(maxWidth: maxWidth);
    final nameTextMetrics = _nameTextPainter.computeLineMetrics();
    _nameTextPainter.inlinePlaceholderBoxes;

    _timeTextPainter.layout();
    _timeDifferenceTextPainter.layout();

    _paintLiveViewers = _liveViewersTextPainter.text != null;
    if (_paintLiveViewers) _liveViewersTextPainter.layout();
    final liveViewersHeight = _paintLiveViewers ? _liveViewersTextPainter.height : 0.0;

    _hasAdditionalLine = nameTextMetrics.last.width + 8.0 + _timeDifferenceTextPainter.width > maxWidth;

    if (!_hasAdditionalLine) {
      return Size(
        maxWidth,
        max(
          _nameTextPainter.height + _timeTextPainter.height,
          _timeDifferenceTextPainter.height + liveViewersHeight,
        ),
      );
    }

    return Size(
      maxWidth,
      _nameTextPainter.height +
          max(
            _timeTextPainter.height,
            _timeDifferenceTextPainter.height + liveViewersHeight,
          ),
    );
  }

  void positionText() {
    final nameTextMetrics = _nameTextPainter.computeLineMetrics();

    _nameTextPainter.paintOffset = Offset.zero;
    _timeTextPainter.paintOffset = Offset(0, _nameTextPainter.height);

    double rightSideY = _nameTextPainter.height;
    if (!_hasAdditionalLine) {
      rightSideY -= nameTextMetrics.last.height;
      if (!_paintLiveViewers) {
        rightSideY += (nameTextMetrics.last.height + _timeTextPainter.height - _timeDifferenceTextPainter.height) / 2;
      }
    }
    _timeDifferenceTextPainter.paintOffset = Offset(
      constraints.maxWidth - _timeDifferenceTextPainter.width,
      rightSideY,
    );

    if (_paintLiveViewers) {
      _liveViewersTextPainter.paintOffset =
          Offset(constraints.maxWidth - _liveViewersTextPainter.width, rightSideY + _timeDifferenceTextPainter.height);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final textPainter in _textPainters) {
      if (textPainter.text != null) {
        textPainter.paint(context.canvas, offset);
      }
    }
    paintInlineChildren(context, offset);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final parentData = child.parentData as VideoSubtitleParentData;
    final offset = parentData._offset!;
    transform.translate(offset.dx, offset.dy);
  }
}
