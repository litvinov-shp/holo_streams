import 'package:flutter/material.dart';
import 'package:holo_streams/utils/quick_theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonLayout extends StatelessWidget {
  const SkeletonLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          if (isPortrait) {
            return const SkeletonWidget();
          }
          return const Row(
            children: [
              Expanded(child: SkeletonWidget()),
              SizedBox(width: 8.0),
              Expanded(child: SkeletonWidget()),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      ),
    );
  }
}

class SkeletonWidget extends StatelessWidget {
  const SkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorScheme.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        leading: const Skeleton.shade(
          child: CircleAvatar(radius: 26.0),
        ),
        title: Text('\u2800' * 100, maxLines: 1),
        subtitle: Text('\u2800' * 100, maxLines: 2),
      ),
    );
  }
}
