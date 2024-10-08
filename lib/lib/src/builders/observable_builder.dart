import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable_builder/lib/src/builders/observable_element.dart';
import 'package:dart_observable_builder/lib/src/extensions.dart';
import 'package:dart_observable_builder/lib/src/types.dart';
import 'package:flutter/widgets.dart';

import 'base_builder.dart';

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
