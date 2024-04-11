import 'dart:async';

import 'package:get/get.dart';

enum TimeUnit implements Comparable<TimeUnit> {
  year,
  month,
  day,
  hour,
  minute,
  second,
  millisecond,
  microsecond;

  @override
  int compareTo(TimeUnit other) => other.index.compareTo(index);

  operator <(TimeUnit other) => compareTo(other) == -1;

  operator <=(TimeUnit other) => compareTo(other) <= 0;

  operator >(TimeUnit other) => compareTo(other) == 1;

  operator >=(TimeUnit other) => compareTo(other) >= 0;
}

extension TimeFloor on DateTime {
  DateTime floorTo(TimeUnit unit) {
    return DateTime(
      year,
      unit <= TimeUnit.month ? month : 1,
      unit <= TimeUnit.day ? day : 1,
      unit <= TimeUnit.hour ? hour : 0,
      unit <= TimeUnit.minute ? minute : 0,
      unit <= TimeUnit.second ? second : 0,
      unit <= TimeUnit.millisecond ? millisecond : 0,
      unit <= TimeUnit.microsecond ? microsecond : 0,
    );
  }
}

class TimeController extends GetxController {
  static TimeController get to => Get.find<TimeController>();

  DateTime get now => _now;
  DateTime _now = DateTime.now();

  late Timer _timer;

  void _start() {
    final left = 1e6.toInt() - (now.millisecond * 1000 + now.microsecond);
    _timer = Timer(
      Duration(milliseconds: left ~/ 1000, microseconds: left % 1000),
      () {
        _now = DateTime.now();
        update();
        _start();
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}
