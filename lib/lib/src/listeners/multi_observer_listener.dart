import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/widgets.dart';

class ObserverListenerHandler<T> {
  const ObserverListenerHandler({
    required this.observable,
    required this.onChanged,
  });

  final void Function(BuildContext context) onChanged;
  final Observable<T> observable;
}

class MultiObserverListener extends StatelessWidget {
  const MultiObserverListener({
    required this.handlers,
    this.child,
    this.onError,
    super.key,
  });

  final void Function(BuildContext context, dynamic error)? onError;
  final List<ObserverListenerHandler<dynamic>> handlers;
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    return child ?? const SizedBox.shrink();
  }

  @override
  StatelessElement createElement() {
    return _Element(
      this,
      handlers: handlers,
      onError: onError,
    );
  }
}

class _Element extends StatelessElement {
  _Element(
    super.widget, {
    required this.handlers,
    this.onError,
  });

  final void Function(BuildContext context, dynamic error)? onError;
  final List<ObserverListenerHandler<dynamic>> handlers;

  final List<Disposable> _currentListeners = <Disposable>[];
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
    for (final Disposable listener in _currentListeners) {
      listener.dispose();
    }

    _currentListeners.clear();
    super.unmount();
  }

  void _registerListeners() {
    for (final ObserverListenerHandler<dynamic> handler in handlers) {
      _currentListeners.add(
        handler.observable.listen(
          onChange: (final _) {
            handler.onChanged(_parent);
          },
          onError: (final dynamic error, final StackTrace stack) {
            final void Function(BuildContext context, dynamic error)? errorHandler = onError;
            if (errorHandler != null) {
              errorHandler(_parent, error);
            }
            throw error;
          },
        ),
      );
    }
  }
}
