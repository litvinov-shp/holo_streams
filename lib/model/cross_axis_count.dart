import 'package:flutter/material.dart';

extension CrossAxisCount on BuildContext {
  int get crossAxisCount {
    return MediaQuery.of(this).size.width < 600 ? 1 : 2;
  }
}
