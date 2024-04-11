import 'package:flutter/material.dart';
import 'package:holo_streams/utils/quick_theme.dart';
import 'package:intl/intl.dart';

class StreamDateHeader extends StatelessWidget {
  const StreamDateHeader({
    super.key,
    required this.date,
    required this.backgroundHeight,
  });

  final DateTime date;

  final double backgroundHeight;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.colorScheme.surface;
    final tintedColor =
        ElevationOverlay.applySurfaceTint(backgroundColor, context.colorScheme.surfaceTint, 3.0);
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: tintedColor)),
        if (backgroundHeight != 0.0)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: backgroundHeight,
                child: ColoredBox(color: backgroundColor),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 2.0),
          child: Text(DateFormat.MMMd().format(date)),
        ),
      ],
    );
  }
}
