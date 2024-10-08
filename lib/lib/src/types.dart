import 'package:flutter/widgets.dart';

typedef EmptyBuilder = Widget Function(BuildContext context);
typedef ValueBuilder<T> = Widget Function(BuildContext context, T value);
