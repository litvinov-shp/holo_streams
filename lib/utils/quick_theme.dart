import 'package:flutter/material.dart';

extension QuickTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;
}