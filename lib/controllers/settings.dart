import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holo_streams/controllers/shared_prefs.dart';

enum LayoutMode { compact, standard }

class Settings extends GetxController {
  static Settings get to => Get.find<Settings>();

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
    _loadPreferEnglishNames();
    _loadLayoutMode();
  }

  ThemeMode get themeMode => _themeMode.value;
  late final Rx<ThemeMode> _themeMode;
  set themeMode(ThemeMode value) {
    if (value == themeMode) return;
    _themeMode.value = value;
    SharedPrefs.prefs.setString('theme', value.name);
  }
  void _loadThemeMode() {
    final theme = SharedPrefs.prefs.getString('theme') ?? 'system';
    _themeMode = switch (theme) {
      'ThemeMode.light' || 'light' => ThemeMode.light,
      'ThemeMode.dark' || 'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    }.obs;
  }

  bool get preferEnglishNames => _preferEnglishNames.value;
  late final RxBool _preferEnglishNames;
  set preferEnglishNames(bool value) {
    if (value == preferEnglishNames) return;
    _preferEnglishNames.value = value;
    SharedPrefs.prefs.setBool('preferEnglishNames', value);
  }
  void _loadPreferEnglishNames() {
    final result = SharedPrefs.prefs.getBool('preferEnglishNames');
    _preferEnglishNames = (result ?? PlatformDispatcher.instance.locale.countryCode != 'JP').obs;
  }

  LayoutMode get layoutMode => _layoutMode.value;
  late final Rx<LayoutMode> _layoutMode;
  set layoutMode(LayoutMode value) {
    if (value == layoutMode) return;
    _layoutMode.value = value;
    SharedPrefs.prefs.setString('layoutMode', value.name);
  }
  void _loadLayoutMode() {
    final mode = SharedPrefs.prefs.getString('layoutMode');
    _layoutMode = (mode == 'compact' ? LayoutMode.compact : LayoutMode.standard).obs;
  }
}
