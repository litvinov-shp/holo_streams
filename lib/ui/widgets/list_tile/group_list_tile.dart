import 'package:flutter/material.dart';
import 'package:holo_streams/ui/widgets/list_tile/outlined_list_tile.dart';
import 'package:holo_streams/utils/quick_theme.dart';

class GroupListTile extends StatelessWidget {
  const GroupListTile({
    super.key,
    this.value,
    this.onChanged,
    required this.title,
    this.borderRadius = 16.0,
    this.color,
    this.tristate = false,
    this.child,
  });

  final bool? value;

  final ValueChanged<bool?>? onChanged;

  final String title;

  final double borderRadius;

  final Color? color;

  final bool tristate;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colorScheme.primary;
    final titleText = Text(
      title,
      style: TextStyle(color: effectiveColor),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 24.0),
          child: onChanged == null
              ? titleText
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    titleText,
                    Checkbox(
                      value: value,
                      onChanged: onChanged,
                      tristate: tristate,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
        ),
        OutlinedListTile(
          borderRadius: borderRadius,
          color: effectiveColor,
          child: child,
        ),
      ],
    );
  }
}
