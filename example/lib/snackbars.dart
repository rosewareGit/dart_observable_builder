import 'package:flutter/material.dart';

extension SnackbarExtensions on BuildContext {
  void showSnackbar(final String message) {
    final ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(this);
    scaffoldMessengerState.clearSnackBars();
    scaffoldMessengerState.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
