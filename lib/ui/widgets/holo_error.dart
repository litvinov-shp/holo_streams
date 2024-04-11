import 'package:flutter/material.dart';

class HoloError extends StatelessWidget {
  const HoloError({
    super.key,
    this.onReload,
    required this.text,
    this.isError = false,
    this.center = true,
  });

  const HoloError.noStreams({
    super.key,
    this.center = true,
  })  : onReload = null,
        text = 'No streams for now',
        isError = false;

  const HoloError.error({
    required this.onReload,
    super.key,
    this.center = true,
  })  : text = 'Unable to load data',
        isError = true;

  final String text;

  final bool isError;

  final bool center;

  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    Widget child = Text(text);
    Widget centerIfNeeded() {
      if (!center) return child;
      return Center(child: child);
    }

    if (!isError) return centerIfNeeded();

    child = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        child,
        FilledButton(
          onPressed: onReload,
          child: const Text('Reload'),
        ),
      ],
    );
    return centerIfNeeded();
  }
}

class SliverHoloError extends HoloError {
  const SliverHoloError({
    super.key,
    super.onReload,
    required super.text,
    super.isError,
    super.center,
  });

  const SliverHoloError.noStreams({
    super.key,
    super.center,
  }) : super.noStreams();

  const SliverHoloError.error({
    super.key,
    required super.onReload,
    super.center,
  }) : super.error();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: super.build(context),
    );
  }
}
