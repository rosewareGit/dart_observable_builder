import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable_builder/lib/src/builders/observable_element.dart';
import 'package:flutter/widgets.dart';

import 'base_builder.dart';

class ObservableBuilderN extends ObservableBuilderBase {
  const ObservableBuilderN(
    this.observables, {
    required this.builder,
    this.shouldRebuild,
    super.key,
  });

  @override
  final List<Observable<dynamic>> observables;
  final bool Function(List<dynamic> values)? shouldRebuild;
  final Widget Function(BuildContext context, List<dynamic> values) builder;

  @override
  Widget build(final BuildContext context) {
    return builder(context, observables.map((final Observable<dynamic> observable) => observable.value).toList());
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
