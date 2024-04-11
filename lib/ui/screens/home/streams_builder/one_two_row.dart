import 'package:flutter/material.dart';
import 'package:holo_streams/model/cross_axis_count.dart';

class OneTwoRow extends StatelessWidget {
  const OneTwoRow({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (context.crossAxisCount == 1) {
      return children.first;
    }

    if (children.length == 1) {
      return OneTwoRowSingleItem(child: children.single);
    }

    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 8.0),
        Expanded(child: children[1]),
      ],
    );
  }
}

class OneTwoRowSingleItem extends StatelessWidget {
  const OneTwoRowSingleItem({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: child,
    );
  }
}
