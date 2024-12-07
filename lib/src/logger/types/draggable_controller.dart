import 'dart:math';

import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/material.dart';

import '../base_controller.dart';

class DraggableLoggerController extends LoggerBaseController {
  DraggableLoggerController() {
    ObservableGlobalLogger().disableLoggingForClass(this);
  }

  static const Offset defaultOffset = Offset(0, 0);
  static const double _minWidth = 200;
  static const double headerHeight = 40;
  static const double bottomHeight = 40;

  final ScrollController scrollController = ScrollController();

  late final Rx<Offset> _rxTopLeftOffset = Rx<Offset>(defaultOffset);
  late final Rx<Offset> _rxBottomRightOffset = Rx<Offset>(Offset.zero);
  late final Rx<bool> _rxOpened = Rx<bool>(false);

  late final Rx<bool> _rxShowBelowContent = Rx<bool>(false);
  double _maxHeight = 0;
  double _maxWidth = 0;

  set maxHeight(final double value) {
    _maxHeight = max(0, value);
  }

  set maxWidth(final double value) {
    _maxWidth = max(0, value);
  }

  Observable<Offset> get rxBottomRightOffset => _rxBottomRightOffset;

  Observable<bool> get rxOpened => _rxOpened;

  Observable<bool> get rxShowBelowContent => _rxShowBelowContent;

  Observable<Offset> get rxTopLeftOffset => _rxTopLeftOffset;

  void close() {
    _rxOpened.value = false;
  }

  void open() {
    _rxOpened.value = true;
  }

  void resetPosition() {
    _rxTopLeftOffset.value = defaultOffset;
  }

  void toggleZPosition() {
    _rxShowBelowContent.value = !_rxShowBelowContent.value;
  }

  void updateBottomRightDragOffsetBy(final Offset delta) {
    if (_maxHeight == 0 || _maxWidth == 0) {
      return;
    }

    final Offset current = _rxBottomRightOffset.value;
    final Offset topLeft = rxOpened.value ? _rxTopLeftOffset.value : Offset.zero;

    final double dx = (current.dx - delta.dx).clamp(0, _maxWidth - topLeft.dx - _minWidth);
    final double dy = (current.dy - delta.dy).clamp(
      0,
      _maxHeight - topLeft.dy - headerHeight - bottomHeight,
    );

    _rxBottomRightOffset.value = Offset(dx, dy);
  }

  void updateDrag(final Offset delta) {
    updateTopLeftDragOffsetBy(delta);
    updateBottomRightDragOffsetBy(delta);
  }

  void updateTopLeftDragOffsetBy(final Offset delta) {
    if (_maxHeight == 0 || _maxWidth == 0) {
      return;
    }

    final Offset current = _rxTopLeftOffset.value;
    final Offset bottomRight = rxOpened.value ? _rxBottomRightOffset.value : Offset.zero;
    final double dx = (current.dx + delta.dx).clamp(0, _maxWidth - bottomRight.dx - _minWidth);
    final double dy = (current.dy + delta.dy).clamp(0, _maxHeight - bottomRight.dy - headerHeight - bottomHeight);

    _rxTopLeftOffset.value = Offset(dx, dy);
    if (rxOpened.value == false) {
      updateBottomRightDragOffsetBy(delta);
    }
  }
}
