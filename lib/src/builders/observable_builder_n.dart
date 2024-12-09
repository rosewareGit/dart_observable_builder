import 'package:dart_observable/dart_observable.dart';
import 'package:fl_observable/src/builders/observable_element.dart';
import 'package:flutter/widgets.dart';

import 'base_builder.dart';

/// Similar to [ObservableBuilder3], but with an arbitrary number of observables.
class ObservableBuilderN extends ObservableBuilderBase {
  const ObservableBuilderN(
    this.observables, {
    required this.builder,
    this.shouldRebuild,
    this.child,
    super.key,
  });

  @override
  final List<Observable<dynamic>> observables;
  final bool Function(List<dynamic> values)? shouldRebuild;
  final Widget Function(BuildContext context, List<dynamic> values, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    final List<dynamic> values = <dynamic>[];
    for (final Observable<dynamic> observable in observables) {
      values.add(observable.value);
    }
    return builder(context, values, child);
  }

  @override
  StatelessElement createElement() {
    return ObservableElement(
      observables: observables,
      owner: this,
      shouldRebuild: shouldRebuild,
    );
  }
}
