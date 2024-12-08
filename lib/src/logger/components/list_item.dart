import '../../../../fl_observable.dart';

class LoggerListItem {
  LoggerListItem({
    required this.type,
    required this.name,
    required this.count,
  });

  final WidgetObservableLoggerType type;
  final String name;
  final int count;

  @override
  int get hashCode => key.hashCode ^ count;

  String get key {
    return '$type:$name';
  }

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    if (other is LoggerListItem) {
      return other.key == key && other.count == count;
    }
    return false;
  }
}
