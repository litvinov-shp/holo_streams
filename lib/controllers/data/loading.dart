import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:holo_streams/utils/quick_theme.dart';

typedef SuccessCallback<T> = void Function(
    BuildContext? context, ScrollController? scrollController, T?);

// [ErrorCallback] but with void instead of bool
typedef ErrorVideoCallback = void Function(BuildContext? context,
    ScrollController? scrollController, Object exception, StackTrace stackTrace);

abstract class LoadingController<T> extends GetxController with StateMixin<T> {
  LoadingController({required this.holodexClient});

  final HolodexClient holodexClient;

  @override
  void onInit() {
    super.onInit();
    load(ignoreLoading: true);
  }

  Future<T> loadData();

  Future<void> load({
    BuildContext? context,
    ScrollController? scrollController,
    SuccessCallback<T>? onSuccess,
    ErrorVideoCallback? onError,
    bool ignoreLoading = false,
  }) async {
    if (!ignoreLoading && status.isLoading) {
      return;
    }
    scrollController?.animateTo(
      0.0,
      duration: kTabScrollDuration,
      curve: Curves.easeOutCubic,
    );
    change(state, status: RxStatus.loading());
    try {
      change(await loadData(), status: RxStatus.success());
      (onSuccess ?? defaultOnSuccess).call(context, scrollController, state);
    } catch (exception, stackTrace) {
      if (state == null) {
        change(state, status: RxStatus.error(exception.toString()));
      } else {
        // Display previously loaded data anyway
        change(state, status: RxStatus.success());
      }
      onError?.call(context, scrollController, exception, stackTrace);
    }
  }

  static void defaultOnSuccess<T>(
    BuildContext? context,
    ScrollController? scrollController,
    T data,
  ) {
    if (scrollController != null) {
      scrollController.animateTo(
        0.0,
        duration: kTabScrollDuration,
        curve: Curves.easeOutCubic,
      );
    }
    if (context!.mounted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data updated'),
          backgroundColor: context.colorScheme.primary,
          duration: const Duration(milliseconds: 750),
        ),
      );
    }
  }

  static void defaultOnError(
    BuildContext? context,
    ScrollController? controller,
    Object exception,
    StackTrace stackTrace,
  ) {
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to load data',
          style: TextStyle(color: context.colorScheme.onError),
        ),
        backgroundColor: context.colorScheme.error,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
