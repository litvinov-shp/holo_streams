import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holo_streams/controllers/data/streams.dart';
import 'package:holo_streams/controllers/filters.dart';
import 'package:holo_streams/model/filter.dart';
import 'package:holo_streams/ui/screens/filter_edit/filter_edit_screen.dart';
import 'package:holo_streams/ui/screens/home/filter_tab_bar.dart';
import 'package:holo_streams/ui/screens/home/holo_refresh_indicator.dart';
import 'package:holo_streams/ui/screens/home/stream_group/stream_date_header.dart';
import 'package:holo_streams/ui/screens/home/stream_group/stream_group.dart';
import 'package:holo_streams/ui/screens/home/stream_group/stream_header.dart';
import 'package:holo_streams/ui/screens/home/streams_builder/streams_builder.dart';
import 'package:holo_streams/ui/screens/settings/settings_dialog.dart';
import 'package:holo_streams/ui/widgets/filter_dialog.dart';
import 'package:holo_streams/ui/widgets/holo_error.dart';
import 'package:holo_streams/ui/widgets/skeleton_layout.dart';
import 'package:holo_streams/utils/context_navigator.dart';
import 'package:holo_streams/utils/quick_theme.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StreamListView extends StatefulWidget {
  const StreamListView({super.key});

  @override
  State<StreamListView> createState() => _StreamListViewState();
}

class _StreamListViewState extends State<StreamListView> with TickerProviderStateMixin {
  final EasyRefreshController _refreshController = EasyRefreshController();

  final ScrollController _scrollController = ScrollController();

  TabController? _tabController;

  int get currentIndex => _tabController!.animation!.value.round();

  Future<void> _refresh() =>
      StreamsController.to.load(context: context, scrollController: _scrollController);

  void _updateTabController(int initialIndex) {
    _tabController?.dispose();
    _tabController = TabController(
      length: FiltersController.to.filters.length,
      initialIndex: initialIndex,
      animationDuration: _tabController?.animationDuration,
      vsync: this,
    );
    int lastIndex = initialIndex;
    _tabController!.animation!.addListener(() {
      if (currentIndex != lastIndex) {
        lastIndex = currentIndex;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      // Flutter's RefreshIndicator doesn't go back after it gets armed so we use EasyRefresh
      child: EasyRefresh(
        onRefresh: _refresh,
        controller: _refreshController,
        scrollController: _scrollController,
        triggerAxis: Axis.vertical,
        // edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight + kTextTabBarHeight,
        // notificationPredicate: (notification) => notification.depth == 2,
        header: HoloRefreshIndicator(
          edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight + kTextTabBarHeight,
        ),
        child: GetBuilder<FiltersController>(
          builder: (filtersController) {
            if (filtersController.filters.length != _tabController?.length) {
              final newIndex = _tabController?.index ?? 0;
              _updateTabController(newIndex < filtersController.filters.length ? newIndex : 0);
            }
            return GetBuilder<StreamsController>(
              builder: (streamsController) {
                return NestedScrollView(
                  controller: _scrollController,
                  physics: streamsController.status.isLoading
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar(
                        pinned: true,
                        forceElevated: innerBoxIsScrolled,
                        title: GestureDetector(
                          onTap: () => _scrollController.animateTo(
                            0.0,
                            duration: kTabScrollDuration,
                            curve: Curves.easeOutCubic,
                          ),
                          child: const Text('Hololive Streams'),
                        ),
                        actions: [
                          IconButton(
                            onPressed: streamsController.status.isLoading ? null : _refresh,
                            icon: const Icon(Symbols.refresh),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const SettingsDialog(),
                              );
                            },
                            icon: const Icon(Symbols.settings),
                          ),
                          IconButton(
                            onPressed: currentIndex == 0
                                ? null
                                : () async {
                                    final newFilter = await context.push<Filter>((context) =>
                                        FilterEditScreen(
                                            filter: filtersController.filters[currentIndex]));
                                    if (!context.mounted || newFilter == null) return;
                                    filtersController[currentIndex] = newFilter;
                                  },
                            icon: const Icon(Symbols.edit),
                          ),
                          IconButton(
                            onPressed: currentIndex == 0
                                ? null
                                : () async {
                                    final shouldDelete =
                                        await const FilterDialog.delete().show(context);
                                    if (!context.mounted || !shouldDelete) return;
                                    filtersController.deleteFilter(currentIndex);
                                    _updateTabController(0);
                                  },
                            icon: Icon(
                              Symbols.delete,
                              color: currentIndex == 0 ? null : context.colorScheme.error,
                            ),
                          ),
                        ],
                        bottom: FilterTabBar(
                          tabController: _tabController,
                          onTap: (value) => setState(() {}),
                          onFilterAdded: () =>
                              _updateTabController(filtersController.filters.length - 1),
                          onReorder: (newFilters) {
                            final oldFilter = filtersController.filters[currentIndex];
                            final newIndex = newFilters.indexOf(oldFilter) + 1;
                            filtersController.filters = newFilters;
                            if (newIndex == currentIndex) return;
                            _updateTabController(
                                newIndex < filtersController.filters.length ? newIndex : 0);
                          },
                        ),
                      ),
                    ),
                  ],
                  body: Builder(
                    builder: (context) {
                      return TabBarView(
                        controller: _tabController,
                        physics: streamsController.status.isLoading
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        children: filtersController.filters.map<Widget>((filter) {
                          return CustomScrollView(
                            key: PageStorageKey(filter),
                            physics: streamsController.status.isLoading
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            slivers: [
                              SliverOverlapInjector(
                                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                              ),
                              streamsController.obx(
                                (streams) {
                                  final streamsByDate = streamsController.getStreams(filter)!;
                                  if (streamsByDate.isEmpty) {
                                    return const SliverHoloError.noStreams();
                                  }

                                  return StreamGroup(
                                    slivers: streamsByDate.entries
                                        .map((streamGroup) {
                                          final date = streamGroup.key;
                                          final streams = streamGroup.value;
                                          return [
                                            StreamHeaderBuilder(
                                              offset: MediaQuery.of(context).padding.top +
                                                  kToolbarHeight +
                                                  kTextTabBarHeight,
                                              builder: (context, backgroundHeight) {
                                                return StreamDateHeader(
                                                  date: date,
                                                  backgroundHeight: backgroundHeight,
                                                );
                                              },
                                            ),
                                            SliverPadding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, right: 8.0, bottom: 8.0),
                                              sliver: StreamsBuilder(streams: streams),
                                            ),
                                          ];
                                        })
                                        .expand((slivers) => slivers)
                                        .toList(),
                                  );
                                },
                                onLoading: const SliverSkeletonizer(child: SkeletonLayout()),
                                onError: (error) =>
                                    SliverHoloError.error(onReload: _refresh),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
