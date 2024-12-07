import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable_builder/src/logger/types/floating_bottom.dart';
import 'package:dart_observable_builder/src/logger/types/pinned_bottom.dart';
import 'package:flutter/material.dart';

import 'types/draggable.dart';

/// Used to visualize the changes of observables in a Flutter application logged to the `ObservableGlobalLogger`.
///
/// The `WidgetObservableLogger` widget provides a way to display the state of observables
/// in different visual formats. It supports three view types: `pinnedBottom`, `floatingBottom`, and `draggable`.
///
/// Example usage:
///
/// ```dart
/// WidgetObservableLogger(
///   viewType: WidgetObservableLoggerViewType.draggable,
///   child: MyApp(),
/// );
/// ```
///
/// The `viewType` parameter determines the display style of the logger:
/// - `pinnedBottom`: The logger is pinned to the bottom of the parent content.
/// - `floatingBottom`: The logger floats above the content at the bottom.
/// - `draggable`: The logger can be dragged around within the parent content.
///
/// The `buttonStyle` parameter allows customization of the button style used within the logger.
class WidgetObservableLogger extends StatefulWidget {
  const WidgetObservableLogger({
    this.child,
    super.key,
    this.viewType = WidgetObservableLoggerViewType.draggable,
    this.bottomExpandedHeight = 250,
    this.buttonStyle,
  });

  final Widget? child;
  final WidgetObservableLoggerViewType viewType;
  final double bottomExpandedHeight;
  final ButtonStyle? buttonStyle;

  @override
  State<WidgetObservableLogger> createState() => _WidgetObservableLoggerState();
}

enum WidgetObservableLoggerType {
  active,
  inactive,
  dispose,
  notify,
  ;

  @override
  String toString() {
    return name;
  }
}

enum WidgetObservableLoggerViewType {
  pinnedBottom,
  floatingBottom,
  draggable,
}

class _WidgetObservableLoggerState extends State<WidgetObservableLogger> {
  @override
  Widget build(final BuildContext context) {
    final WidgetObservableLoggerViewType viewType = widget.viewType;
    final Widget? child = widget.child;

    switch (viewType) {
      case WidgetObservableLoggerViewType.pinnedBottom:
        return WidgetPinnedBottomLogger(
          expandedHeight: widget.bottomExpandedHeight,
          buttonStyle: widget.buttonStyle,
          child: child,
        );
      case WidgetObservableLoggerViewType.floatingBottom:
        return WidgetFloatingBottomLogger(
          buttonStyle: widget.buttonStyle,
          child: child,
        );
      case WidgetObservableLoggerViewType.draggable:
        return WidgetDraggableLogger(
          buttonStyle: widget.buttonStyle,
          child: child,
        );
    }
  }

  @override
  void initState() {
    ObservableGlobalLogger().disableLoggingForClass(this);
    super.initState();
  }
}
