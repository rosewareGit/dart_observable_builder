import 'package:dart_observable/dart_observable.dart';

import '../base_controller.dart';

class PinnedBottomLoggerController extends LoggerBaseController {
  PinnedBottomLoggerController() {
    ObservableGlobalLogger().disableLoggingForClass(this);
  }
  
  late final Rx<bool> _rxOpened = Rx<bool>(false);

  Observable<bool> get rxOpened => _rxOpened;

  void close() {
    _rxOpened.value = false;
  }

  void open() {
    _rxOpened.value = true;
  }
}
