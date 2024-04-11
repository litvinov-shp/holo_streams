import 'package:flutter/material.dart';
import 'package:holo_streams/utils/quick_theme.dart';

class OutlinedListTile extends StatelessWidget {
  const OutlinedListTile({
    super.key,
    this.borderRadius = 16.0,
    this.color,
    this.child,
  });

  final double borderRadius;

  final Color? color;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? context.colorScheme.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
