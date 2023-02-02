import 'package:flutter/widgets.dart';

extension SnackbarExtensions on BuildContext {
  void snackbar(final String message) {
    print('message:$message');
  }
}
