import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/material.dart';

import 'base_builder.dart';

class ObservableElement extends StatelessElement {
  ObservableElement({
    required this.observables,
    required final ObservableBuilderBase owner,
    this.shouldRebuild,
  }) : super(owner);
  List<Observable<dynamic>> observables;

  final List<Disposable> _listeners = <Disposable>[];
  final bool Function(List<dynamic> values)? shouldRebuild;

  @override
  void mount(final Element? parent, final Object? newSlot) {
    assert(parent != null);
    _initListeners();
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    _disposeListeners();
    super.unmount();
  }

  @override
  void update(final ObservableBuilderBase newWidget) {
    final List<Observable<dynamic>> oldObservables = (widget as ObservableBuilderBase).observables;
    final List<Observable<dynamic>> newObservables = newWidget.observables;
    final bool didChangeObservables;

    if (oldObservables.length != newObservables.length) {
      didChangeObservables = true;
    } else {
      didChangeObservables = oldObservables.any((final Observable<dynamic> observable) {
        return !newObservables.contains(observable);
      });
    }

    if (didChangeObservables) {
      // Dispose old and listen to new observables
      _disposeListeners();
      observables = newObservables;
      _initListeners();
    }

    super.update(newWidget);
  }

  void _disposeListeners() {
    for (final Disposable listener in _listeners) {
      listener.dispose();
    }
    _listeners.clear();
  }

  bool rebuildScheduled = false;

  void _initListeners() {
    for (final Observable<dynamic> observable in observables) {
      _listeners.add(
        observable.listen(
          onChange: (final _) {
            if (shouldRebuild?.call(
                  observables
                      .map(
                        (final Observable<dynamic> observable) => observable.value,
                      )
                      .toList(),
                ) !=
                false) {
              if (mounted && rebuildScheduled == false) {
                rebuildScheduled = true;
                scheduleMicrotask(() {
                  if (mounted) {
                    markNeedsBuild();
                  }
                  rebuildScheduled = false;
                });
              }
            }
          },
        ),
      );
    }
  }
}
