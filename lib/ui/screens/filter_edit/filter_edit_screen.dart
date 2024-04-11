import 'dart:async';

import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holo_streams/controllers/data/channels.dart';
import 'package:holo_streams/model/filter.dart';
import 'package:holo_streams/ui/widgets/filter_dialog.dart';
import 'package:holo_streams/ui/widgets/holo_error.dart';
import 'package:holo_streams/ui/widgets/list_tile/group_list_tile.dart';
import 'package:holo_streams/utils/context_navigator.dart';
import 'package:holo_streams/utils/effective_channel_name.dart';
import 'package:material_symbols_icons/symbols.dart';

class FilterEditScreen extends StatefulWidget {
  const FilterEditScreen({
    super.key,
    required this.filter,
  });

  final Filter filter;

  @override
  State<FilterEditScreen> createState() => _FilterEditScreenState();
}

class _FilterEditScreenState extends State<FilterEditScreen> {
  late final filter = widget.filter.copyWith().obs;

  late final _textController = TextEditingController(text: filter.name);

  final _scrollController = ScrollController();

  Future<void> _refresh() =>
      ChannelsController.to.load(context: context, scrollController: _scrollController);

  Future<void> discardPop([bool didPop = false]) async {
    if (didPop) {
      return;
    }
    final shouldDiscard =
        (setEquals(widget.filter.data, filter.data) && filter.name == _textController.text) ||
            await const FilterDialog.discard().show(context);
    if (context.mounted && shouldDiscard) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: discardPop,
      child: GetBuilder<ChannelsController>(builder: (controller) {
        return DefaultTabController(
          length: controller.branches.length,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: discardPop,
                icon: const Icon(Symbols.close),
              ),
              title: TextField(controller: _textController),
              actions: [
                TextButton(
                  onPressed: () async {
                    final shouldClear = await const FilterDialog.clear().show(context);
                    if (!context.mounted || !shouldClear) return;
                    filter.value.data.clear();
                    filter.refresh();
                  },
                  child: const Text('Clear'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () => context.pop(filter.value.copyWith(name: _textController.text)),
                    child: const Text('Save'),
                  ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: controller.branches.keys
                    .map((generationName) => Tab(text: generationName))
                    .toList(),
              ),
            ),
            body: TabBarView(
              children: controller.branches.values.map((generation) {
                return controller.obx(
                  (state) {
                    return ListView.separated(
                      key: PageStorageKey(generation),
                      padding: const EdgeInsets.all(8.0),
                      itemCount: generation.length,
                      itemBuilder: (context, index) {
                        final generationEntry = generation.entries.elementAt(index);
                        return Obx(() {
                          final generationValues = generationEntry.value
                              .map((channel) => filter.data.contains(channel.id))
                              .toSet();
                          final groupValue =
                              generationValues.length == 1 ? generationValues.single : null;
                          return GroupListTile(
                            value: groupValue,
                            onChanged: (value) {
                              for (final channel in generationEntry.value) {
                                filter[channel.id] = value ?? false;
                              }
                            },
                            tristate: true,
                            title: generationEntry.key,
                            child: GenerationView(generationEntry: generationEntry, filter: filter),
                          );
                        });
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                    );
                  },
                  onLoading: const Center(child: CircularProgressIndicator()),
                  onError: (error) => HoloError.error(onReload: _refresh),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}

class GenerationView extends StatefulWidget {
  const GenerationView({
    super.key,
    required this.generationEntry,
    required this.filter,
  });

  final MapEntry<String, List<Channel>> generationEntry;

  final RxFilter filter;

  @override
  State<GenerationView> createState() => _GenerationViewState();
}

class _GenerationViewState extends State<GenerationView> {
  final _scrollController = ScrollController(keepScrollOffset: false);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.generationEntry.value.length,
      itemBuilder: (context, index) {
        final channel = widget.generationEntry.value[index];
        return Obx(() {
          return CheckboxListTile(
            value: widget.filter[channel.id],
            onChanged: (value) => widget.filter[channel.id] = value!,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? const Radius.circular(16.0) : Radius.zero,
                bottom: index == widget.generationEntry.value.length - 1
                    ? const Radius.circular(16.0)
                    : Radius.zero,
              ),
            ),
            title: Text(channel.effectiveName),
          );
        });
      },
    );
  }
}
