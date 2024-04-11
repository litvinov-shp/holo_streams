import 'package:flutter/material.dart';
import 'package:holo_streams/utils/context_navigator.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({
    super.key,
    required this.title,
    required this.description,
    required this.cancelText,
    required this.okText,
  });

  const FilterDialog.discard({super.key})
      : title = 'Discard Changes?',
        description = 'If you discard changes, they won\'t be saved.',
        cancelText = 'Cancel',
        okText = 'Discard';

  const FilterDialog.clear({super.key})
      : title = 'Clear Items?',
        description = 'Are you sure you want to clear all filters?',
        cancelText = 'Cancel',
        okText = 'Clear';
  
  const FilterDialog.delete({super.key})
      : title = 'Delete filter?',
        description = 'Deleting a filter can\'t be undone',
        cancelText = 'Cancel',
        okText = 'Delete';

  final String title;

  final String description;

  final String cancelText;

  final String okText;

  Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => this,
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: Text(okText),
        ),
      ],
    );
  }
}
