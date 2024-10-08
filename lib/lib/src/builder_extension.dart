import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/material.dart';

import '../../dart_observable_builder.dart';

extension ObservableBuilderExtension<T> on Observable<T> {
  Widget build(final ValueBuilder<T> builder) {
    return ObservableBuilder<T>(
      this,
      builder: builder,
    );
  }
}
