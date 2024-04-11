import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HoloRefreshIndicator extends MaterialHeader {
  const HoloRefreshIndicator({required this.edgeOffset});

  final double edgeOffset;

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return Padding(
      padding: EdgeInsets.only(top: edgeOffset),
      child: ClipRect(
        child: super.build(context, state),
      ),
    );
  }
}

class HoloRefreshClipper extends CustomClipper<Rect> {
  const HoloRefreshClipper(this.edgeOffset);

  final double edgeOffset;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, edgeOffset);
  }

  @override
  bool shouldReclip(HoloRefreshClipper oldClipper) {
    return edgeOffset != oldClipper.edgeOffset;
  }
}
