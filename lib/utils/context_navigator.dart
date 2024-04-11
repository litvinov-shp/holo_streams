import 'package:flutter/material.dart';

extension ContextNavigator on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  NavigatorState? get maybeNavigator => Navigator.maybeOf(this);

  Future<T?> push<T extends Object?>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
  }) {
    return navigator.push<T>(
      MaterialPageRoute(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        allowSnapshotting: allowSnapshotting,
      ),
    );
  }

  Future<T?>? maybePush<T extends Object?>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
  }) {
    return maybeNavigator?.push<T>(
      MaterialPageRoute(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        allowSnapshotting: allowSnapshotting,
      ),
    );
  }

  void pop<T extends Object?>([T? result]) {
    return navigator.pop<T>(result);
  }

  Future<bool> maybePop<T extends Object?>([T? result]) {
    return maybeNavigator?.maybePop<T>(result) ?? Future.value(false);
  }
}
