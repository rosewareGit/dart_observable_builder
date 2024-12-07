import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable_builder/dart_observable_builder.dart';
import 'package:flutter/widgets.dart';

import 'listener_handler.dart';

/// A widget that listens to changes in an [Observable] and triggers a callback
/// when the observable changes.
///
/// The [ObserverListener] widget listens to an [Observable] and calls the
/// [onChanged] callback whenever the observable's value changes. It can also
/// optionally call the [onError] callback if an error occurs, and the
/// [shouldNotify] callback to determine whether to notify on changes.
///
/// The [notifyOnRegister] flag determines whether the [onChanged] callback
/// should be called immediately with the current value of the observable when
/// the listener is registered.
///
/// Example usage:
/// ```dart
/// ObserverListener<int>(
///   observable: myObservable,
///   onChanged: (context, value) {
///     print('Observable value changed: $value');
///   },
///   onError: (context, error) {
///     print('Error occurred: $error');
///   },
///   shouldNotify: (value) => value > 0,
///   notifyOnRegister: true,
///   child: Text('Listening to observable'),
/// );
/// ```
class ObserverListener<T> extends StatelessWidget {
  const ObserverListener({
    required this.observable,
    required this.onChanged,
    this.shouldNotify,
    this.child,
    this.onError,
    this.notifyOnRegister = false,
    super.key,
  });

  final void Function(BuildContext context, T value) onChanged;
  final void Function(BuildContext context, dynamic error)? onError;
  final bool Function(T value)? shouldNotify;
  final bool notifyOnRegister;
  final Observable<T> observable;
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    return MultiObserverListener(
      handlers: <ObserverListenerHandler<T>>[
        ObserverListenerHandler<T>(
          observable: observable,
          onChanged: onChanged,
          onError: onError,
          shouldNotify: shouldNotify,
          notifyOnRegister: notifyOnRegister,
        ),
      ],
      child: child,
    );
  }
}
