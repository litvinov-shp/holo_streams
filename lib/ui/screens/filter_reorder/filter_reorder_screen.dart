import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holo_streams/controllers/filters.dart';
import 'package:holo_streams/ui/widgets/filter_dialog.dart';
import 'package:holo_streams/utils/context_navigator.dart';
import 'package:material_symbols_icons/symbols.dart';

class FilterReorderScreen extends StatefulWidget {
  const FilterReorderScreen({super.key});

  @override
  State<FilterReorderScreen> createState() => _FilterReorderScreenState();
}

class _FilterReorderScreenState extends State<FilterReorderScreen> {
  late final filters = controller.filters.sublist(1).obs;

  FiltersController get controller => FiltersController.to;

  Future<void> discardPop([bool didPop = false]) async {
    if (didPop) {
      return;
    }
    final shouldDiscard = listEquals(filters, controller.filters.sublist(1)) ||
        await const FilterDialog.discard().show(context);
    if (context.mounted && shouldDiscard) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: discardPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: discardPop,
            icon: const Icon(Symbols.close),
          ),
          title: const Text('Reorder filters'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () => context.pop(filters),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
        body: ReorderableListView.builder(
          physics: const ClampingScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex == newIndex) return;
            if (newIndex > oldIndex) newIndex--;
            final filter = filters.removeAt(oldIndex);
            filters.insert(newIndex, filter);
          },
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            return ReorderableDragStartListener(
              key: ValueKey(filter),
              index: index,
              child: ListTile(title: Text('${"${index + 1}.".padRight(5)} ${filter.effectiveName}')),
            );
          },
        ),
      ),
    );
  }
}
