import 'package:dart_observable/dart_observable.dart';

import '../base_controller.dart';

class FloatingBottomLoggerController extends LoggerBaseController {
  FloatingBottomLoggerController() {
    ObservableGlobalLogger().disableLoggingForClass(this);
  }

  static const double floatingControlHeight = 50;

  late final RxDouble _rxDragPosition = RxDouble(0);
  late final RxBool _rxAnimate = RxBool(false);

  Observable<bool> get rxAnimate => _rxAnimate;

  Observable<double> get rxDragPosition => _rxDragPosition;

  void collapse() {
    _rxAnimate.value = true;
    _rxDragPosition.value = 0;
  }

  void expand({required final double upperBound}) {
    _rxAnimate.value = true;
    _rxDragPosition.value = upperBound - floatingControlHeight;
  }

  void updateDragPosition({
    required final double dy,
    required final double upperBound,
  }) {
    _rxAnimate.value = false;
    final double current = _rxDragPosition.value;
    _rxDragPosition.value = (current - dy).clamp(0, (upperBound - floatingControlHeight));
  }
}
