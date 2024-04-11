import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:holo_streams/controllers/settings.dart';
import 'package:holo_streams/utils/quick_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Settings.to.themeMode.obs;
    final preferEnglishNames = Settings.to.preferEnglishNames.obs;
    final layoutMode = Settings.to.layoutMode.obs;
    return AlertDialog(
      title: const Text('Settings'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: context.theme.textTheme.bodyLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() {
                  return SettingsChoice<ThemeMode>(
                    value: ThemeMode.values[0],
                    groupValue: theme.value,
                    icon: Symbols.brightness_auto,
                    label: 'System',
                    onTap: (value) => theme.value = value,
                  );
                }),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Obx(() {
                  return SettingsChoice<ThemeMode>(
                    value: ThemeMode.values[1],
                    groupValue: theme.value,
                    icon: Symbols.sunny,
                    label: 'Light',
                    onTap: (value) => theme.value = value,
                  );
                }),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Obx(() {
                  return SettingsChoice<ThemeMode>(
                    value: ThemeMode.values[2],
                    groupValue: theme.value,
                    icon: Symbols.nights_stay,
                    label: 'Dark',
                    onTap: (value) => theme.value = value,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Prefer english names',
                  style: context.theme.textTheme.bodyLarge,
                ),
              ),
              Obx(() {
                return Switch(
                  value: preferEnglishNames.value,
                  onChanged: (value) => preferEnglishNames.value = value,
                );
              }),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Compact layout',
                  style: context.theme.textTheme.bodyLarge,
                ),
              ),
              Obx(() {
                return Switch(
                  value: layoutMode.value == LayoutMode.compact,
                  onChanged: (value) =>
                      layoutMode.value = value ? LayoutMode.compact : LayoutMode.standard,
                );
              }),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Settings.to.themeMode = theme.value;
            Settings.to.preferEnglishNames = preferEnglishNames.value;
            Settings.to.layoutMode = layoutMode.value;
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class SettingsChoice<T> extends StatelessWidget {
  const SettingsChoice({
    super.key,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final T value;
  final T groupValue;
  final IconData icon;
  final String label;
  final void Function(T) onTap;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var isSelected = value == groupValue;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, fill: isSelected ? 1.0 : 0.0),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
