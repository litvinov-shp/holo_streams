import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holo_streams/controllers/filters.dart';
import 'package:holo_streams/model/filter.dart';
import 'package:holo_streams/ui/screens/filter_reorder/filter_reorder_screen.dart';
import 'package:holo_streams/utils/context_navigator.dart';
import 'package:material_symbols_icons/symbols.dart';

class FilterTabBar extends GetView<FiltersController> implements PreferredSizeWidget {
  const FilterTabBar({
    super.key,
    this.tabController,
    this.onTap,
    this.onFilterAdded,
    this.onReorder,
  });

  final TabController? tabController;

  final ValueChanged<int>? onTap;

  final VoidCallback? onFilterAdded;

  final void Function(List<Filter> newFilters)? onReorder;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: [
            IconButton(
              onPressed: FiltersController.to.filters.length <= 2
                  ? null
                  : () async {
                      final newFilters = await context
                          .push<List<Filter>>((context) => const FilterReorderScreen());
                      if (!context.mounted || newFilters == null) return;
                      if (onReorder == null) {
                        FiltersController.to.filters = newFilters;
                      } else {
                        onReorder?.call(newFilters);
                      }
                    },
              icon: const Icon(Symbols.tune),
            ),
            TabBar(
              controller: tabController,
              onTap: onTap,
              isScrollable: true,
              physics: const NeverScrollableScrollPhysics(),
              tabAlignment: TabAlignment.start,
              indicator: const BoxDecoration(),
              indicatorWeight: double.minPositive,
              dividerHeight: 0.0,
              tabs: controller.filters.map((filter) {
                return Tab(
                  text: filter.name,
                  height: kTextTabBarHeight,
                );
              }).toList(),
            ),
            IconButton(
              onPressed: () {
                controller.addFilter();
                onFilterAdded?.call();
              },
              icon: const Icon(Symbols.add),
            ),
          ],
        ),
      ),
    );
  }
}
