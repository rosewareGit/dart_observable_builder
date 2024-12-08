import 'package:dart_observable/dart_observable.dart';
import 'package:fl_observable/src/logger/widget_observable_logger.dart';

import 'components/list_item.dart';

class LoggerBaseController {
  LoggerBaseController() {
    ObservableGlobalLogger().disableLoggingForClass(this);
  }

  late final Rx<bool> _rxDarkMode = Rx<bool>(true);
  late final RxSet<WidgetObservableLoggerType> _rxSelectedTypes = RxSet<WidgetObservableLoggerType>(
    initial: <WidgetObservableLoggerType>{
      ...WidgetObservableLoggerType.values,
    },
  );

  late final ObservableMap<String, LoggerListItem> rxItems = _createMergedMap();

  Observable<bool> get rxDarkMode => _rxDarkMode;

  ObservableSet<WidgetObservableLoggerType> get rxSelectedTypes => _rxSelectedTypes;

  void clear() {
    ObservableGlobalLogger().clearAll();
  }

  void toggleColorMode() {
    _rxDarkMode.value = !_rxDarkMode.value;
  }

  void toggleLoggerType(final WidgetObservableLoggerType type) {
    final bool contains = _rxSelectedTypes.value.contains(type);
    if (contains) {
      _rxSelectedTypes.value.remove(type);
    } else {
      _rxSelectedTypes.value.add(type);
    }
  }

  ObservableMap<String, LoggerListItem> _createListItemObservableForType(
    final WidgetObservableLoggerType type,
  ) {
    return switch (type) {
      WidgetObservableLoggerType.active => _mapSourceToListItem(type, ObservableGlobalLogger().rxActives),
      WidgetObservableLoggerType.inactive => _mapSourceToListItem(type, ObservableGlobalLogger().rxInactives),
      WidgetObservableLoggerType.dispose => _mapSourceToListItem(type, ObservableGlobalLogger().rxDisposes),
      WidgetObservableLoggerType.notify => _mapSourceToListItem(type, ObservableGlobalLogger().rxNotifies),
    };
  }

  ObservableMap<String, LoggerListItem> _createMergedMap() {
    return _rxSelectedTypes.switchMapAs.map<String, LoggerListItem>(
      mapper: (final Set<WidgetObservableLoggerType> items) {
        return ObservableMap<String, LoggerListItem>.merged(
          collections: items.map<ObservableMap<String, LoggerListItem>>((final WidgetObservableLoggerType type) {
            return _createListItemObservableForType(type);
          }).toList(),
        );
      },
      factory: (final Map<String, LoggerListItem>? items) {
        return SortedMap<String, LoggerListItem>(
          (final LoggerListItem left, final LoggerListItem right) {
            return right.count.compareTo(left.count);
          },
          initial: items,
        );
      },
    );
  }

  ObservableMap<String, LoggerListItem> _mapSourceToListItem(
    final WidgetObservableLoggerType type,
    final ObservableMap<String, List<DateTime>> source,
  ) {
    return source.transformChangeAs.map<String, LoggerListItem>(
      transform: (
        final ObservableMap<String, LoggerListItem> current,
        final Map<String, List<DateTime>> state,
        final ObservableMapChange<String, List<DateTime>> change,
        final Emitter<ObservableMapUpdateAction<String, LoggerListItem>> updater,
      ) {
        final Map<String, List<DateTime>> added = change.added;
        final Map<String, ObservableItemChange<List<DateTime>>> updated = change.updated;

        final Map<String, LoggerListItem> addItems = <String, LoggerListItem>{};
        final Set<String> removedItems = <String>{};

        for (final MapEntry<String, List<DateTime>> entry in added.entries) {
          final LoggerListItem listItem = LoggerListItem(
            type: type,
            name: entry.key,
            count: entry.value.length,
          );
          addItems[listItem.key] = listItem;
        }

        for (final MapEntry<String, ObservableItemChange<List<DateTime>>> entry in updated.entries) {
          final LoggerListItem listItem = LoggerListItem(
            type: type,
            name: entry.key,
            count: entry.value.newValue.length,
          );
          addItems[listItem.key] = listItem;
        }

        for (final MapEntry<String, List<DateTime>> entry in change.removed.entries) {
          final LoggerListItem listItem = LoggerListItem(
            type: type,
            name: entry.key,
            count: entry.value.length,
          );
          removedItems.add(listItem.key);
        }

        updater(
          ObservableMapUpdateAction<String, LoggerListItem>(
            addItems: addItems,
            removeKeys: removedItems,
          ),
        );
      },
    );
  }
}
