import 'package:flutter/material.dart';

class IconSpan extends WidgetSpan {
  IconSpan(
    IconData icon, {
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    String? semanticLabel,
    TextDirection? textDirection,
    super.alignment = PlaceholderAlignment.middle,
    super.baseline,
    super.style,
  })  : assert(fill == null || (0.0 <= fill && fill <= 1.0)),
        assert(weight == null || (0.0 < weight)),
        assert(opticalSize == null || (0.0 < opticalSize)),
        super(
          child: Icon(
            icon,
            size: size ?? style?.fontSize,
            fill: fill,
            weight: weight ?? style?.fontWeight?.value.toDouble(),
            grade: grade,
            opticalSize: opticalSize,
            color: color ?? style?.color,
            shadows: shadows ?? style?.shadows,
            semanticLabel: semanticLabel,
            textDirection: textDirection,
          ),
        );
}
