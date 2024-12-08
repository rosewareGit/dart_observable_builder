import 'package:fl_observable/fl_observable.dart';
import 'package:fl_observable/src/extensions.dart';
import 'package:flutter/widgets.dart';

import 'base_builder.dart';
import 'observable_element.dart';

/// Similar to [ObservableBuilder2], but with three observables.
class ObservableBuilder3<T, T2, T3> extends ObservableBuilderBase {
  const ObservableBuilder3(
    this.observable1,
    this.observable2,
    this.observable3, {
    required this.builder,
    this.shouldRebuild,
    super.key,
  });

  final Observable<T> observable1;
  final Observable<T2> observable2;
  final Observable<T3> observable3;
  final bool Function(T value1, T2 value2, T3 value3)? shouldRebuild;
  final Widget Function(BuildContext context, T value1, T2 value2, T3 value3) builder;

  @override
  List<Observable<dynamic>> get observables => <Observable<dynamic>>[observable1, observable2, observable3];

  @override
  Widget build(final BuildContext context) {
    return builder(context, observable1.value, observable2.value, observable3.value);
  }

  @override
  StatelessElement createElement() {
    return ObservableElement(
      observables: <Observable<dynamic>>[observable1, observable2, observable3],
      owner: this,
      shouldRebuild: shouldRebuild?.let((final bool Function(T val1, T2 val2, T3 val3) shouldRebuild) {
        return (final List<dynamic> values) {
          final T first = values[0] as T;
          final T2 second = values[1] as T2;
          final T3 third = values[2] as T3;
          return shouldRebuild(first, second, third);
        };
      }),
    );
  }
}
