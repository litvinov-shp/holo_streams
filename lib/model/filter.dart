import 'package:get/get.dart';

class Filter {
  Filter({
    required this.name,
    required this.data,
  }) : isAll = false;

  Filter._all()
      : name = 'All',
        data = const {},
        isAll = true;

  static final all = Filter._all();

  factory Filter.fromJson(Map json) {
    return Filter(
      name: json['name'],
      data: Set.from(json['data']),
    );
  }

  Map toJson() {
    return {
      'name': name,
      'data': List.from(data),
    };
  }

  final String name;

  final Set<String> data;

  final bool isAll;

  bool operator [](String channelId) => data.contains(channelId);

  void operator []=(String channelId, bool contains) {
    if (contains) {
      data.add(channelId);
    } else {
      data.remove(channelId);
    }
  }

  Filter copyWith({
    String? name,
    Set<String>? data,
  }) {
    if (isAll) {
      return this;
    }
    return Filter(
      name: name ?? this.name,
      data: data ?? Set.of(this.data),
    );
  }
}

class RxFilter extends Rx<Filter> {
  RxFilter(super.initial);

  String get name => value.name;

  Set<String> get data => value.data;

  bool operator [](String channelId) => data.contains(channelId);

  void operator []=(String channelId, bool contains) {
    value[channelId] = contains;
    refresh();
  }
}

class RxnFilter extends Rxn<Filter> {
  RxnFilter(super.initial);

  String? get name => value?.name;

  Set<String>? get data => value?.data;

  bool? operator [](String channelId) => data?.contains(channelId);

  void operator []=(String channelId, bool contains) {
    if (value == null) return;
    value?[channelId] = contains;
    refresh();
  }
}

extension FilterExtension on Filter {
  RxFilter get obs => RxFilter(this);
}

extension FilternExtension on Filter? {
  RxnFilter get obs => RxnFilter(this);
}
