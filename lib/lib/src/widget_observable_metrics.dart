import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable_builder/dart_observable_builder.dart';
import 'package:flutter/material.dart';

class WidgetObservableMetrics extends StatefulWidget {
  const WidgetObservableMetrics({
    this.child,
    super.key,
    this.offset,
  });

  final Offset? offset;
  final Widget? child;

  @override
  State<WidgetObservableMetrics> createState() => _WidgetObservableMetricsState();
}

enum WidgetObservableMetricsType {
  active,
  inactive,
  dispose,
  notify,
  ;

  @override
  String toString() {
    return name;
  }
}

class _Controller {
  _Controller({
    final Offset? offset,
  }) : _rxOffset = Rx<Offset>(offset ?? Offset.zero) {
    DartObservableGlobalMetrics().ignoreMetrics();
  }

  late final RxSet<WidgetObservableMetricsType> _rxSelectedTypes = RxSet<WidgetObservableMetricsType>(
    initial: <WidgetObservableMetricsType>{
      ...WidgetObservableMetricsType.values,
    },
  );

  late final Rx<Offset> _rxOffset;
  late final Rx<bool> _rxOpened = Rx<bool>(false);
  late final Rx<double> _rxOpacity = Rx<double>(0.4);
  late final Rx<bool> _rxTransparentBackground = Rx<bool>(true);
  late final ObservableMap<String, _ListItem> rxItems = _rxSelectedTypes.switchMapAs.map<String, _ListItem>(
    mapper: (final ObservableSetState<WidgetObservableMetricsType> value) {
      final UnmodifiableSetView<WidgetObservableMetricsType> items = value.setView;

      return ObservableMap<String, _ListItem>.merged(
        collections: items.map<ObservableMap<String, _ListItem>>((final WidgetObservableMetricsType type) {
          return _createListItemObservableForType(type);
        }).toList(),
      );
    },
  );

  void clear() {
    DartObservableGlobalMetrics().clearAll();
  }

  void shiftOpacity() {
    _rxOpacity.value = _rxOpacity.value == 0.4 ? 1.0 : 0.4;
  }

  void switchBackgroundColor() {
    _rxTransparentBackground.value = !_rxTransparentBackground.value;
  }

  ObservableMap<String, _ListItem> _createListItemObservableForType(
    final WidgetObservableMetricsType type,
  ) {
    return switch (type) {
      WidgetObservableMetricsType.active => _mapSourceToListItem(type, DartObservableGlobalMetrics().rxActives),
      WidgetObservableMetricsType.inactive => _mapSourceToListItem(type, DartObservableGlobalMetrics().rxInactives),
      WidgetObservableMetricsType.dispose => _mapSourceToListItem(type, DartObservableGlobalMetrics().rxDisposes),
      WidgetObservableMetricsType.notify => _mapSourceToListItem(type, DartObservableGlobalMetrics().rxNotifies),
    };
  }

  ObservableMap<String, _ListItem> _mapSourceToListItem(
    final WidgetObservableMetricsType type,
    final ObservableMap<String, List<DateTime>> source,
  ) {
    return source.transformChangeAs.map<String, _ListItem>(
      transform: (
        final ObservableMap<String, _ListItem> state,
        final ObservableMapChange<String, List<DateTime>> change,
        final Emitter<ObservableMapUpdateAction<String, _ListItem>> updater,
      ) {
        final Map<String, List<DateTime>> added = change.added;
        final Map<String, ObservableItemChange<List<DateTime>>> updated = change.updated;

        final Map<String, _ListItem> addItems = <String, _ListItem>{};
        final Set<String> removedItems = <String>{};

        for (final MapEntry<String, List<DateTime>> entry in added.entries) {
          final _ListItem listItem = _ListItem(
            type: type,
            name: entry.key,
            count: entry.value.length,
          );
          addItems[listItem.key] = listItem;
        }

        for (final MapEntry<String, ObservableItemChange<List<DateTime>>> entry in updated.entries) {
          final _ListItem listItem = _ListItem(
            type: type,
            name: entry.key,
            count: entry.value.newValue.length,
          );
          addItems[listItem.key] = listItem;
        }

        for (final MapEntry<String, List<DateTime>> entry in change.removed.entries) {
          final _ListItem listItem = _ListItem(
            type: type,
            name: entry.key,
            count: entry.value.length,
          );
          removedItems.add(listItem.key);
        }

        updater(
          ObservableMapUpdateAction<String, _ListItem>(
            addItems: addItems,
            removeItems: removedItems,
          ),
        );
      },
    );
  }
}

class _ListItem {
  _ListItem({
    required this.type,
    required this.name,
    required this.count,
  });

  final WidgetObservableMetricsType type;

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
    if (other is _ListItem) {
      return other.key == key && other.count == count;
    }
    return false;
  }
}

class _WidgetObservableMetricsState extends State<WidgetObservableMetrics> {
  late final _Controller _controller = _Controller(offset: widget.offset);

  @override
  void initState() {
    DartObservableGlobalMetrics().ignoreMetrics();
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final Widget? child = widget.child;
    return Stack(
      children: <Widget>[
        ObservableBuilder2<bool, Offset>(
          _controller._rxOpened,
          _controller._rxOffset,
          builder: (
            final BuildContext context,
            final bool opened,
            final Offset offset,
          ) {
            return Positioned(
              top: offset.dy,
              left: offset.dx,
              right: opened ? 0 : null,
              child: Builder(
                builder: (final BuildContext context) {
                  if (opened) {
                    return _buildOpened(context);
                  }
                  return LongPressDraggable<Object>(
                    delay: const Duration(milliseconds: 100),
                    onDragUpdate: (final DragUpdateDetails details) {
                      _controller._rxOffset.value = details.globalPosition;
                    },
                    feedback: const SizedBox.shrink(),
                    child: IconButton(
                      onPressed: () {
                        _controller._rxOpened.value = true;
                      },
                      icon: const Icon(
                        Icons.analytics,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (child != null) Positioned.fill(child: child),
      ],
    );
  }

  Widget _buildOpened(final BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double topPadding = mediaQuery.padding.top;
    final double maxHeight = screenHeight - topPadding;
    return _controller._rxTransparentBackground.build(
      (final BuildContext context, final bool isTransparent) {
        return Material(
          color: isTransparent ? Colors.transparent : Colors.black54,
          child: _controller._rxSelectedTypes.build(
            (
              final BuildContext context,
              final ObservableSetState<WidgetObservableMetricsType> state,
            ) {
              final UnmodifiableSetView<WidgetObservableMetricsType> types = state.setView;
              final String typeString;
              if (types.isEmpty) {
                typeString = 'None';
              } else if (types.length == 1) {
                typeString = types.first.toString();
              } else {
                typeString = '${types.length} types';
              }

              return Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Drag button
                        LongPressDraggable<Object>(
                          delay: const Duration(milliseconds: 100),
                          onDragUpdate: (final DragUpdateDetails details) {
                            _controller._rxOffset.value = details.globalPosition;
                          },
                          feedback: const SizedBox.shrink(),
                          child: IconButton(
                            onPressed: () {
                              _controller._rxOpened.value = true;
                            },
                            icon: const Icon(
                              Icons.drag_handle,
                              size: 24,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showSelectTypeDialog(context);
                          },
                          child: Text(typeString),
                        ),
                        IconButton(
                          onPressed: () {
                            _controller.shiftOpacity();
                          },
                          icon: const Icon(Icons.opacity),
                        ),
                        IconButton(
                          onPressed: () {
                            _controller.switchBackgroundColor();
                          },
                          icon: const Icon(Icons.format_color_fill),
                        ),
                        IconButton(
                          onPressed: () {
                            _controller._rxOpened.value = false;
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Expanded(
                      child: _controller._rxOpacity.build(
                        (final BuildContext context, final double opacity) {
                          return Opacity(
                            opacity: opacity,
                            child: Builder(
                              builder: (final BuildContext context) {
                                final int selectedCount = types.length;
                                if (selectedCount == 0) {
                                  return const SizedBox.shrink();
                                }

                                return _controller.rxItems.build((
                                  final BuildContext context,
                                  final ObservableMapState<String, _ListItem> state,
                                ) {
                                  final List<_ListItem> items = state.mapView.values.toList();
                                  items.sort(
                                    (final _ListItem a, final _ListItem b) => b.count.compareTo(a.count),
                                  );
                                  return ListView.builder(
                                    itemCount: items.length + 1,
                                    itemBuilder: (
                                      final BuildContext context,
                                      final int index,
                                    ) {
                                      if (index == 0) {
                                        // Clear button
                                        return TextButton(
                                          style: ButtonStyle(
                                            minimumSize: WidgetStateProperty.all<Size>(
                                              const Size(0, 0),
                                            ),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () {
                                            _controller.clear();
                                          },
                                          child: const Text(
                                            'Clear',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        );
                                      }
                                      final int itemIndex = index - 1;
                                      final _ListItem item = items[itemIndex];
                                      final String name = item.name;
                                      return Row(
                                        children: <Widget>[
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  reverse: true,
                                                  child: Text(
                                                    name,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                                Text(
                                                  item.type.toString(),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.end,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(item.count.toString()),
                                          const SizedBox(width: 8),
                                        ],
                                      );
                                    },
                                  );
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSelectTypeDialog(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Select types'),
          content: _controller._rxSelectedTypes.build(
            (
              final BuildContext context,
              final ObservableSetState<WidgetObservableMetricsType> state,
            ) {
              final UnmodifiableSetView<WidgetObservableMetricsType> selectedTypes = state.setView;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final WidgetObservableMetricsType type in WidgetObservableMetricsType.values)
                    CheckboxListTile(
                      value: selectedTypes.contains(type),
                      onChanged: (final bool? value) {
                        if (value == true) {
                          _controller._rxSelectedTypes.add(type);
                        } else {
                          _controller._rxSelectedTypes.remove(type);
                        }
                      },
                      title: Text(type.toString()),
                    ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
