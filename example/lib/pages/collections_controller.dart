import 'dart:collection';
import 'dart:math';

import 'package:dart_observable/dart_observable.dart';

enum CollectionViewType {
  list,
  set,
  map,
}

class PageCollectionsController {
  static const String characters = ' AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  late final RxList<String> _rxSourceList = RxList<String>();
  late final RxBool _rxSortedListActive = RxBool(false);
  late final Rx<CollectionViewType> _rxViewType = Rx<CollectionViewType>(CollectionViewType.list);

  late final Observable<bool> rxSortedListActive = _rxSortedListActive;
  late final Observable<CollectionViewType> rxViewType = _rxViewType;
  late final ObservableList<String> rxSourceList = _rxSourceList;
  late final ObservableSet<String> rxSorted = _rxSourceList.transformChangeAs.set(
    transform: _transformSorted,
    factory: (final Iterable<String>? items) {
      return SplayTreeSet<String>.of(
        (items ?? <String>[]),
        (final String a, final String b) => a.compareTo(b),
      );
    },
  )..onActivityChanged(
      onActive: (final _) {
        _rxSortedListActive.value = true;
      },
      onInactive: (final _) {
        _rxSortedListActive.value = false;
      },
    );
  late final ObservableMap<int, String> rxItemsByLength = _rxSourceList.transformChangeAs.map(
    transform: _transformItemsByLength,
    factory: (final Map<int, String>? items) {
      return SplayTreeMap<int, String>.of(
        items ?? <int, String>{},
        (final int a, final int b) => a.compareTo(b),
      );
    },
  );

  String getRandomName() {
    final Random random = Random();
    final int length = random.nextInt(20) + 10;
    return String.fromCharCodes(
      Iterable<int>.generate(
        length,
        (final _) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  void onAddNamePressed() {
    final List<String> names = <String>[];
    for (int i = 0; i < 100; i++) {
      names.add(getRandomName());
    }
    _rxSourceList.addAll(names);
  }

  void removeItemAt(final int index) {
    _rxSourceList.removeAt(index);
  }

  void updateViewType(final CollectionViewType value) {
    _rxViewType.value = value;
  }

  void _transformItemsByLength(
    final ObservableMap<int, String> current,
    final List<String> state,
    final ObservableListChange<String> change,
    final Emitter<ObservableMapUpdateAction<int, String>> updater,
  ) {
    final Map<int, String> added = change.added;
    final Map<int, String> removed = change.removed;
    final Map<int, ObservableItemChange<String>> updated = change.updated;

    updater(
      ObservableMapUpdateAction<int, String>(
        addItems: <int, String>{
          for (final MapEntry<int, String> entry in added.entries) entry.value.length: entry.value,
          for (final MapEntry<int, ObservableItemChange<String>> entry in updated.entries)
            entry.value.newValue.length: entry.value.newValue,
        },
        removeKeys: removed.values.map((final String item) => item.length).toSet(),
      ),
    );
  }

  void _transformSorted(
    final ObservableSet<String> current,
    final _,
    final ObservableListChange<String> change,
    final Emitter<ObservableSetUpdateAction<String>> updater,
  ) {
    final Map<int, String> added = change.added;
    final Map<int, String> removed = change.removed;
    final Map<int, ObservableItemChange<String>> updated = change.updated;

    updater(
      ObservableSetUpdateAction<String>(
        addItems: <String>{
          ...added.values,
          ...updated.values.map((final ObservableItemChange<String> change) {
            return change.newValue;
          }),
        },
        removeItems: removed.values.toSet(),
      ),
    );
  }
}
