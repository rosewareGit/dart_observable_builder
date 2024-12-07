import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ObserverListenerHandler<T> {
  const ObserverListenerHandler({
    required this.observable,
    required this.onChanged,
    this.shouldNotify,
    this.onError,
    this.notifyOnRegister = false,
  });

  final bool notifyOnRegister;
  final Observable<T> observable;
  final void Function(BuildContext context, T value) onChanged;
  final bool Function(T value)? shouldNotify;
  final void Function(BuildContext context, dynamic error)? onError;

  Disposable listen(final BuildContext context) {
    if (notifyOnRegister) {
      _onChanged(context, observable.value);
    }
    return observable.listen(
      onChange: (final T value) {
        _onChanged(context, value);
      },
      onError: (final dynamic error, final StackTrace stack) {
        final void Function(BuildContext context, dynamic error)? errorBuilder = onError;
        if (errorBuilder != null) {
          errorBuilder(context, error);
          return;
        }
        throw error;
      },
    );
  }

  void _onChanged(final BuildContext context, final T value) {
    final bool Function(T value)? shouldNotify = this.shouldNotify;
    if (shouldNotify != null && shouldNotify(value) == false) {
      return;
    }
    onChanged(context, value);
  }
}
