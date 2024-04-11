import 'dart:convert';

import 'package:get/get.dart';
import 'package:holo_streams/controllers/shared_prefs.dart';
import 'package:holo_streams/model/filter.dart';

class FiltersController extends GetxController {
  static FiltersController get to => Get.find();

  List<Filter> get filters => [Filter.all, ..._filters];
  final _filters = <Filter>[];
  set filters(List<Filter> value) {
    _filters.clear();
    _filters.addAll(value);
    update();
  }

  Filter operator [](int index) => filters[index];

  operator []=(int index, Filter value) {
    throwIfZero(index);
    _filters[index - 1] = value;
    update();
  }

  void addFilter() {
    _filters.add(Filter(name: 'New Filter', data: {}));
    update();
  }

  void deleteFilter(int index) {
    throwIfZero(index);
    _filters.removeAt(index - 1);
    update();
  }

  void throwIfZero(int index) {
    if (index == 0) {
      throw RangeError.range(0, 1, _filters.length, null, 'Can\'t replace or delete the "All" filter');
    }
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    save();
    super.update(ids, condition);
  }

  Future<bool> save() {
    final strings = <String>[];
    for (final filter in _filters) {
      try {
        strings.add(jsonEncode(filter.toJson()));
      } catch (_) {}
    }
    return SharedPrefs.prefs.setStringList('filters', strings);
  }

  void _load() {
    if (!SharedPrefs.prefs.containsKey('filters')) {
      _filters.add(Filter(name: 'Favorite', data: {}));
      save();
      return;
    }

    _filters.clear();
    final jsonList = SharedPrefs.prefs.getStringList('filters') ?? [];
    for (final jsonFilter in jsonList) {
      try {
        _filters.add(Filter.fromJson(jsonDecode(jsonFilter)));
      } catch (_) {}
    }
  }
}
