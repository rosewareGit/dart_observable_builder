import 'package:flutter/material.dart';

import '../fl_observable.dart';

extension ObservableBuilderExtension<T> on Observable<T> {
  Widget build({
    required final ValueWidgetBuilder<T> builder,
    final bool Function(T current)? shouldRebuild,
    final Widget? child,
  }) {
    return ObservableBuilder<T>(
      this,
      builder: builder,
      shouldRebuild: shouldRebuild,
      child: child,
    );
  }
}
