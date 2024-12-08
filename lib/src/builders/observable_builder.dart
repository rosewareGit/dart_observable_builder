import 'package:dart_observable/dart_observable.dart';
import 'package:fl_observable/src/builders/observable_element.dart';
import 'package:fl_observable/src/extensions.dart';
import 'package:flutter/widgets.dart';

import 'base_builder.dart';

typedef ValueBuilder<T> = Widget Function(BuildContext context, T value);

/// A widget that listens to an [Observable] and rebuilds when the observable changes.
///
/// The [ObservableBuilder] takes an [Observable] and a [ValueBuilder] to build the widget.
/// Optionally, a [shouldRebuild] function can be provided to control when the widget should rebuild.
///
/// Example usage:
/// ```dart
/// final Rx<int> rxInt = Rx<int>(0);
/// ObservableBuilder<int>(
///   rxInt,
///   builder: (BuildContext context, int value) {
///     return Text(value.toString());
///   },
/// );
/// ```
///
/// If you want to listen to multiple observables, use [ObservableBuilder2] or other similar builders.
class ObservableBuilder<T> extends ObservableBuilderBase {
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
  List<Observable<dynamic>> get observables => <Observable<dynamic>>[observable];

  @override
  Widget build(final BuildContext context) {
    return builder(context, observable.value);
  }

  @override
  StatelessElement createElement() {
    return ObservableElement(
      observables: <Observable<T>>[observable],
      owner: this,
      shouldRebuild: shouldRebuild?.let((final bool Function(T current) shouldRebuild) {
        return (final List<dynamic> values) {
          final T first = values.first as T;
          return shouldRebuild(first);
        };
      }),
    );
  }
}
