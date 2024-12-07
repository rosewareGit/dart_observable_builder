import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/widgets.dart';

import 'listener_handler.dart';


/// A widget that listens to multiple [Observable]s and triggers
/// their callbacks when the observables change.
///
/// Example usage:
/// ```dart
/// MultiObserverListener(
///   handlers: [
///     ObserverListenerHandler<int>(
///       observable: myObservable1,
///       onChanged: (context, value) {
///         print('Observable 1 value changed: $value');
///       },
///     ),
///     ObserverListenerHandler<String>(
///       observable: myObservable2,
///       onChanged: (context, value) {
///         print('Observable 2 value changed: $value');
///       },
///     ),
///   ],
///   child: Text('Listening to multiple observables'),
/// );
/// ```
class MultiObserverListener extends StatelessWidget {
  const MultiObserverListener({
    required this.handlers,
    this.child,
    super.key,
  });

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
    );
  }
}

class _Element extends StatelessElement {
  _Element(
    super.widget, {
    required this.handlers,
  });

  List<ObserverListenerHandler<dynamic>> handlers;

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
  void update(final MultiObserverListener newWidget) {
    final List<ObserverListenerHandler<dynamic>> oldHandlers = (widget as MultiObserverListener).handlers;
    final List<ObserverListenerHandler<dynamic>> newHandlers = newWidget.handlers;
    final bool didChangeObservables;

    if (oldHandlers.length != newHandlers.length) {
      didChangeObservables = true;
    } else {
      didChangeObservables = oldHandlers.any((final ObserverListenerHandler<dynamic> handler) {
        return !newHandlers.contains(handler);
      });
    }

    if (didChangeObservables) {
      // Dispose old and listen to new handlers
      _disposeListeners();
      handlers = newHandlers;
      _registerListeners();
    }

    super.update(newWidget);
  }

  @override
  void unmount() {
    _disposeListeners();
    super.unmount();
  }

  void _disposeListeners() {
    for (final Disposable listener in _currentListeners) {
      listener.dispose();
    }
    _currentListeners.clear();
  }

  void _registerListeners() {
    for (final ObserverListenerHandler<dynamic> handler in handlers) {
      _currentListeners.add(
        handler.listen(_parent),
      );
    }
  }
}
