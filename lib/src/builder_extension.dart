import 'package:flutter/material.dart';

import '../fl_observable.dart';

extension ObservableBuilderExtension<T> on Observable<T> {
  Widget build({
    required final ValueBuilder<T> builder,
    final bool Function(T current)? shouldRebuild,
  }) {
    return ObservableBuilder<T>(
      this,
      builder: builder,
      shouldRebuild: shouldRebuild,
    );
  }
}
