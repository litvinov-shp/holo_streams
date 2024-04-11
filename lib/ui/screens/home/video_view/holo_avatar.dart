import 'package:flutter/material.dart';
import 'package:holo_streams/utils/quick_theme.dart';

class HoloAvatar extends StatelessWidget {
  const HoloAvatar({super.key, this.image});

  final ImageProvider<Object>? image;

  static const double radius = 26.0;

  static const diameter = radius * 2;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: image,
      backgroundColor: context.colorScheme.primary,
    );
  }
}