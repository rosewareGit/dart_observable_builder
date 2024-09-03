import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable_builder/lib/types.dart';
import 'package:flutter/widgets.dart';

class ObservableBuilder<T> extends StatelessWidget {
  const ObservableBuilder(
    this.observable, {
    required this.builder,
    this.shouldRebuild,
    super.key,
  });

  final Observable<T> observable;
  final bool Function(T current)? shouldRebuild;
  final ValueBuilder<T> builder;

  @override
  Widget build(final BuildContext context) {
    return builder(context, observable.value);
  }

  @override
  StatelessElement createElement() {
    return _Element<T>(
      observable: observable,
      owner: this,
      shouldRebuild: shouldRebuild,
    );
  }
}

class _Element<T> extends StatelessElement {
  _Element({
    required this.observable,
    required final StatelessWidget owner,
    this.shouldRebuild,
  }) : super(owner);
  final Observable<T> observable;

  final bool Function(T current)? shouldRebuild;
  late final Disposable _listener;

  bool needsRebuild = false;

  @override
  Widget build() {
    needsRebuild = false;
    return super.build();
  }

  @override
  void mount(final Element? parent, final Object? newSlot) {
    assert(parent != null);
    _listener = observable.listen(
      onChange: (final T value) {
        final bool? trigger = shouldRebuild?.call(value);
        if (trigger != false && needsRebuild == false) {
          scheduleMicrotask(() {
            if (dirty) {
              return;
            }

            if (mounted) {
              needsRebuild = true;
              markNeedsBuild();
            }
          });
        }
      },
    );

    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    _listener.dispose();
    super.unmount();
  }
}

extension ObservableBuilderExtension<T> on Observable<T> {
  Widget build(final ValueBuilder<T> builder) {
    return ObservableBuilder<T>(
      this,
      builder: builder,
    );
  }
}
