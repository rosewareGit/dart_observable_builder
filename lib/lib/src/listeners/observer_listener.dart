import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/widgets.dart';

class ObserverListener<T> extends StatelessWidget {
  const ObserverListener({
    required this.observable,
    required this.onChanged,
    this.child,
    this.onError,
    super.key,
  });

  final void Function(BuildContext context, T value) onChanged;
  final void Function(BuildContext context, dynamic error)? onError;
  final Observable<T> observable;
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    return child ?? const SizedBox.shrink();
  }

  @override
  StatelessElement createElement() {
    return _Element<T>(
      this,
      onChanged: onChanged,
      observable: observable,
      onError: onError,
    );
  }
}

class _Element<T> extends StatelessElement {
  _Element(
    super.widget, {
    required this.onChanged,
    required this.observable,
    this.onError,
  });

  final void Function(BuildContext context, T value) onChanged;
  final void Function(BuildContext context, dynamic error)? onError;
  final Observable<T> observable;

  Disposable? _currentListener;
  late final Element _parent;

  @override
  void mount(final Element? parent, final Object? newSlot) {
    assert(parent != null);
    _parent = parent!;

    _registerListeners();
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    _currentListener?.dispose();
    super.unmount();
  }

  void _registerListeners() {
    _currentListener = observable.listen(
      onChange: (final T value) {
        onChanged(_parent, value);
      },
      onError: (final dynamic error, final StackTrace stack) {
        final void Function(BuildContext context, dynamic error)? errorBuilder = onError;
        if (errorBuilder != null) {
          errorBuilder(_parent, error);
          return;
        }
        throw error;
      },
    );
  }
}
