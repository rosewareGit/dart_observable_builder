import 'package:dart_observable/dart_observable.dart';
import 'package:fl_observable/src/extensions.dart';
import 'package:flutter/widgets.dart';

import 'base_builder.dart';
import 'observable_element.dart';

/// A widget that listens to two [Observable]s and rebuilds when either observable changes.
///
/// The [ObservableBuilder2] takes two [Observable]s and a builder function to build the widget.
/// Optionally, a [shouldRebuild] function can be provided to control when the widget should rebuild.
///
/// Example usage:
/// ```dart
/// final Rx<int> rxInt = Rx<int>(0);
/// final RxString rxString = RxString('');
/// ObservableBuilder2<int, String>(
///   rxInt,
///   rxString,
///   builder: (BuildContext context, int number, String text, Widget? child) {
///     return Text('$number: $text');
///   },
/// );
/// ```
class ObservableBuilder2<T, T2> extends ObservableBuilderBase {
  const ObservableBuilder2(
    this.observable1,
    this.observable2, {
    required this.builder,
    this.shouldRebuild,
    this.child,
    super.key,
  });

  final Observable<T> observable1;
  final Observable<T2> observable2;
  final bool Function(T value1, T2 value2)? shouldRebuild;
  final Widget Function(BuildContext context, T value1, T2 value2, Widget? child) builder;
  final Widget? child;

  @override
  List<Observable<dynamic>> get observables => <Observable<dynamic>>[observable1, observable2];

  @override
  Widget build(final BuildContext context) {
    return builder(context, observable1.value, observable2.value, child);
  }

  @override
  StatelessElement createElement() {
    return ObservableElement(
      observables: <Observable<dynamic>>[observable1, observable2],
      owner: this,
      shouldRebuild: shouldRebuild?.let((final bool Function(T val1, T2 val2) shouldRebuild) {
        return (final List<dynamic> values) {
          final T first = values[0] as T;
          final T2 second = values[1] as T2;
          return shouldRebuild(first, second);
        };
      }),
    );
  }
}
