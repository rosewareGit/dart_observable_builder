import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/widgets.dart';

class ObservableBuilder2<T, T2> extends StatelessWidget {
  const ObservableBuilder2(
    this.observable1,
    this.observable2, {
    required this.builder,
    this.shouldRebuild,
    super.key,
  });

  final Observable<T> observable1;
  final Observable<T2> observable2;
  final bool Function(T value1, T2 value2)? shouldRebuild;
  final Widget Function(BuildContext context, T value1, T2 value2) builder;

  @override
  Widget build(final BuildContext context) {
    return builder(context, observable1.value, observable2.value);
  }

  @override
  StatelessElement createElement() {
    return _Element<T, T2>(
      observable1: observable1,
      observable2: observable2,
      owner: this,
      shouldRebuild: shouldRebuild,
    );
  }
}

class _Element<T, T2> extends StatelessElement {
  _Element({
    required this.observable1,
    required this.observable2,
    required final StatelessWidget owner,
    this.shouldRebuild,
  }) : super(owner);

  final Observable<T> observable1;
  final Observable<T2> observable2;

  late final Disposable _listener1;
  late final Disposable _listener2;

  final bool Function(T value1, T2 value2)? shouldRebuild;

  @override
  void mount(final Element? parent, final Object? newSlot) {
    assert(parent != null);
    _listener1 = observable1.listen(
      onChange: (final _) {
        if (shouldRebuild?.call(observable1.value, observable2.value) != false) {
          markNeedsBuild();
        }
      },
    );
    _listener2 = observable2.listen(
      onChange: (final _) {
        if (shouldRebuild?.call(observable1.value, observable2.value) != false) {
          markNeedsBuild();
        }
      },
    );

    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    _listener1.dispose();
    _listener2.dispose();
    super.unmount();
  }
}
