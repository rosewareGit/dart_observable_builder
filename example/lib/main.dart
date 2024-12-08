import 'dart:collection';
import 'dart:math';

import 'package:fl_observable/fl_observable.dart';
import 'package:fl_observable_example/components/info_row.dart';
import 'package:fl_observable_example/components/list_item.dart';
import 'package:fl_observable_example/snackbars.dart';
import 'package:fl_observable_example/styles/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/number_with_controls.dart';
import 'components/segmented_item.dart';

void main() {
  // Automatically tracks any update on the observables,
  // to visualize the event you can use the [WidgetObservableLogger] widget
  ObservableGlobalLogger.enableGlobalLogger();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Observable example',
      theme: AppTheme().of(context),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Contains a home screen to switch between the pages
class _MyHomePageState extends State<MyHomePage> {
  late final Rx<WidgetObservableLoggerViewType> _rxViewType = Rx<WidgetObservableLoggerViewType>(
    WidgetObservableLoggerViewType.pinnedBottom,
  );

  @override
  Widget build(final BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Observable example'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                _showLoggerSettingsDialog(context);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Simple'),
              Tab(text: 'Collections'),
            ],
          ),
        ),
        body: _rxViewType.build(
          builder: (
            final BuildContext context,
            final WidgetObservableLoggerViewType viewType,
          ) {
            return WidgetObservableLogger(
              viewType: viewType,
              child: const TabBarView(
                children: <Widget>[
                  _PageSimple(),
                  _PageCollections(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLoggerSettingsDialog(final BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text('Logger settings'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('You can change the logger position and behavior'),
              const SizedBox(height: 15),
              _buildLabeledText(
                label: 'Draggable',
                message: 'You can drag the logger around the screen within the widget bounds',
              ),
              const SizedBox(height: 8),
              _buildLabeledText(
                label: 'Pinned bottom',
                message:
                    'The logger will be pinned to the bottom of the screen, the content is above the logger. The logger is NOT draggable',
              ),
              const SizedBox(height: 8),
              _buildLabeledText(
                label: 'Floating bottom',
                message:
                    'The logger will be pinned to the bottom of the screen, the content is below the logger. The logger is draggable',
              ),
              const SizedBox(height: 15),
              Center(
                child: _rxViewType.build(
                  builder: (
                    final BuildContext context,
                    final WidgetObservableLoggerViewType viewType,
                  ) {
                    return SegmentedButton<WidgetObservableLoggerViewType>(
                      segments: const <ButtonSegment<WidgetObservableLoggerViewType>>[
                        ButtonSegment<WidgetObservableLoggerViewType>(
                          value: WidgetObservableLoggerViewType.draggable,
                          label: WidgetSegmentedItem(text: 'Drag'),
                        ),
                        ButtonSegment<WidgetObservableLoggerViewType>(
                          value: WidgetObservableLoggerViewType.pinnedBottom,
                          label: WidgetSegmentedItem(text: 'Pinned'),
                        ),
                        ButtonSegment<WidgetObservableLoggerViewType>(
                          value: WidgetObservableLoggerViewType.floatingBottom,
                          label: WidgetSegmentedItem(text: 'Floating'),
                        ),
                      ],
                      selected: <WidgetObservableLoggerViewType>{_rxViewType.value},
                      onSelectionChanged: (final Set<WidgetObservableLoggerViewType> value) {
                        if (value.isNotEmpty) {
                          _rxViewType.value = value.first;
                        }
                      },
                      showSelectedIcon: false,
                    );
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabeledText({
    required final String label,
    required final String message,
  }) {
    return RichText(
      text: TextSpan(
        style: context.textStyles.info,
        children: <InlineSpan>[
          TextSpan(
            text: '$label: ',
            style: context.textStyles.infoHighlighted,
          ),
          TextSpan(text: message),
        ],
      ),
    );
  }
}

class _PageSimple extends StatefulWidget {
  const _PageSimple();

  @override
  State<_PageSimple> createState() => _PageSimpleState();
}

class _PageSimpleState extends State<_PageSimple> {
  // Create a separate controller to manage the UI logic
  // You can use any architecture you prefer
  late final _PageSimpleController _controller = _PageSimpleController();
  late final ScrollController _scrollController = ScrollController();

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey<String>('simple'),
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Listen to the counter changes and show a snackbar every 5th change
          ObservableListener<int>(
            observable: _controller.rxCounter,
            shouldNotify: (final int counter) => counter % 5 == 0,
            onChanged: (final BuildContext context, final int counter) {
              context.showSnackbar('Counter: $counter');
            },
          ),

          const SizedBox(height: 12),
          _buildCounter(),
          Text('Operators', style: context.textStyles.title),
          const SizedBox(height: 12),
          _buildOddValue(),
          const Divider(),
          _buildMappedValue(),
          const Divider(),
          _buildMappedFilteredValue(),
          const Divider(),
          _buildCombinedValue(),
          const Divider(),
          _buildStreamValue(),
          const Divider(),
          Text('SwitchMap', style: context.textStyles.subtitle),
          const SizedBox(height: 10),
          Text(
            'You can switch and listen to a different observable based on a condition',
            style: context.textStyles.hint,
          ),
          const SizedBox(height: 20),
          _buildSwitchMapEven(),
          _buildSwitchMapOdd(),
          const SizedBox(height: 10),
          _buildSwitchMapSelector(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCounter() {
    return WidgetNumberWithControls(
      onIncrement: _controller.onCounterIncreasePressed,
      onReduce: _controller.onCounterReducePressed,
      rxNumber: _controller.rxCounter,
      title: 'Counter',
    );
  }

  Widget _buildMappedValue() {
    return _controller.rxCounterMapped.build(
      builder: (final BuildContext context, final int value) {
        return WidgetInfoRow(
          info: 'Counter * 3',
          title: 'Map',
          value: '$value',
        );
      },
    );
  }

  Widget _buildOddValue() {
    return _controller.rxFilterOddNumbers.build(
      builder: (final BuildContext context, final int? value) {
        return WidgetInfoRow(
          title: 'Filter',
          info: 'Last Odd number',
          value: value?.toString() ?? 'N/A',
        );
      },
    );
  }

  Widget _buildMappedFilteredValue() {
    return _controller.rxMappedFiltered.build(
      builder: (final BuildContext context, final String? value) {
        return WidgetInfoRow(
          title: 'Filter + Map',
          info: 'Filter the mapped value that contains 3 or 6, and transforms it to text',
          value: value ?? 'N/A',
        );
      },
    );
  }

  Widget _buildStreamValue() {
    return _controller.fromStream.build(
      builder: (final BuildContext context, final int value) {
        return WidgetInfoRow(
          title: 'From stream',
          info: 'The observable is updated from the stream. The stream is updated every second',
          value: value.toString(),
        );
      },
    );
  }

  Widget _buildSwitchMapSelector() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Switch to', style: context.textStyles.subtitle),
          _controller.rxSwitchMapSource.build(
            builder: (final BuildContext context, final bool useOdd) {
              return SegmentedButton<bool>(
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: false,
                    label: SizedBox(
                      width: 50,
                      child: Center(child: Text('Even')),
                    ),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: SizedBox(
                      width: 50,
                      child: Center(child: Text('Odd')),
                    ),
                  ),
                ],
                selected: <bool>{useOdd},
                onSelectionChanged: (final Set<bool> value) {
                  final bool useOdd = value.first;
                  _controller.onSwitchMapSelectorChanged(useOdd);
                },
                showSelectedIcon: false,
              );
            },
          ),
          const SizedBox(width: 10),
          _controller.rxSwitchMap.build(
            builder: (final BuildContext context, final int value) {
              return Text(
                'Value:  $value',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchMapEven() {
    return WidgetNumberWithControls(
      onIncrement: _controller.onEvenIncreasePressed,
      onReduce: _controller.onEvenReducePressed,
      rxNumber: _controller.rxEven,
      title: 'Even',
    );
  }

  Widget _buildSwitchMapOdd() {
    return WidgetNumberWithControls(
      onIncrement: _controller.onOddIncreasePressed,
      onReduce: _controller.onOddReducePressed,
      rxNumber: _controller.rxOdd,
      title: 'Odd',
    );
  }

  Widget _buildCombinedValue() {
    return _controller.rxCombined.build(
      builder: (final BuildContext context, final String value) {
        return WidgetInfoRow(
          title: 'CombineWith',
          value: value,
          info: '''The combined value of the odd and mapped filtered value
The observable only notifies when the value is updated and not on every change in the source observables
update count: ${_controller.rxCombined.updateCount}''',
        );
      },
    );
  }
}

class _PageSimpleController {
  late final RxInt _rxCounter = RxInt(0);
  late final RxBool _rxSwitchMapSource = RxBool(true);
  late final RxInt _rxEven = RxInt(0);
  late final RxInt _rxOdd = RxInt(1);

  // You can use getters to expose the immutable states
  Observable<int> get rxCounter => _rxCounter;

  Observable<int> get rxEven => _rxEven;

  Observable<int> get rxOdd => _rxOdd;

  Observable<bool> get rxSwitchMapSource => _rxSwitchMapSource;

  // For computes states don't use getter otherwise a new instance will be created each time
  late final Observable<int> rxCounterMapped = _getMapObservable();
  late final Observable<int?> rxFilterOddNumbers = _getOddFilterObservable();
  late final Observable<String?> rxMappedFiltered = _getMappedFilterObservable();
  late final Observable<String> rxCombined = _getFilteredCombinedObservable();
  late final Observable<int> fromStream = _getStreamObservable();
  late final Observable<int> rxSwitchMap = _getSwitchMapObservable();

  Observable<int> _getStreamObservable() {
    return Observable<int>.fromStream(
      stream: Stream<int>.periodic(
        const Duration(seconds: 1),
        (final int count) => count,
      ),
      initial: 0,
    );
  }

  Observable<int?> _getOddFilterObservable() {
    return _rxCounter.filter(
      (final int value) => value % 2 == 1,
    );
  }

  Observable<int> _getMapObservable() {
    return _rxCounter.map(
      (final int value) => value * 3,
    );
  }

  Observable<String?> _getMappedFilterObservable() {
    return rxCounterMapped.filter((final int value) {
      final String valueString = value.toString();
      return valueString.contains('3') || valueString.contains('6');
    }).map(
      (final int? value) {
        if (value == null) {
          return 'N/A';
        }
        return 'U:$value';
      },
    );
  }

  void onCounterIncreasePressed() {
    _rxCounter.value++;
  }

  void onCounterReducePressed() {
    _rxCounter.value--;
  }

  void onSwitchMapSelectorChanged(final bool useOddSource) {
    _rxSwitchMapSource.value = useOddSource;
  }

  Observable<int> _getSwitchMapObservable() {
    return _rxSwitchMapSource.switchMap(
      (final bool useOdd) {
        return useOdd ? _rxOdd : _rxEven;
      },
    );
  }

  void onEvenIncreasePressed() {
    _rxEven.value += 2;
  }

  void onEvenReducePressed() {
    _rxEven.value -= 2;
  }

  void onOddIncreasePressed() {
    _rxOdd.value += 2;
  }

  void onOddReducePressed() {
    _rxOdd.value -= 2;
  }

  Observable<String> _getFilteredCombinedObservable() {
    return rxFilterOddNumbers.combineWith(
      other: rxMappedFiltered,
      combiner: (final int? odd, final String? mapped) {
        return 'Odd: ${odd ?? 'N/A'}, Mapped: ${mapped ?? 'N/A'}';
      },
    );
  }
}

class _PageCollections extends StatefulWidget {
  const _PageCollections();

  @override
  State<_PageCollections> createState() => _PageCollectionsState();
}

class _PageCollectionsState extends State<_PageCollections> {
  final PageCollectionsController _controller = PageCollectionsController();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(child: _buildTypeSelector()),
          Expanded(
            child: _buildViewForType(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _controller.rxSourceList.build(
          builder: (final BuildContext context, final List<String> sourceList) {
            final int length = sourceList.length;
            final bool show = length >= 50000;

            return AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton(
                onPressed: () {
                  if (show) {
                    _controller.clearAll();
                  }
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: () {
            _controller.onRemovePressed();
          },
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: () {
            _controller.onAddNamePressed();
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Center(
      child: _controller.rxViewType.build(
        builder: (final BuildContext context, final CollectionViewType buildType) {
          return CupertinoSegmentedControl<CollectionViewType>(
            groupValue: buildType,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: <CollectionViewType, Widget>{
              CollectionViewType.list: CollectionViewType.list.buildSelectorItem(),
              CollectionViewType.set: CollectionViewType.set.buildSelectorItem(),
              CollectionViewType.map: CollectionViewType.map.buildSelectorItem(),
            },
            onValueChanged: (final CollectionViewType? value) {
              if (value != null) {
                _controller.updateViewType(value);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildViewForType() {
    return _controller.rxViewType.build(
      builder: (final BuildContext context, final CollectionViewType viewType) {
        switch (viewType) {
          case CollectionViewType.list:
            return _buildListContent();
          case CollectionViewType.set:
            return _buildSetView();
          case CollectionViewType.map:
            return _buildMapView();
        }
      },
    );
  }

  Widget _buildListSource() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '''This is the source list, the set and the map are computed from this list
- button will remove the first ${PageCollectionsController.addCount} items
+ button will add ${PageCollectionsController.addCount} random text
The list performance will not degrade with a large number of items''',
            style: context.textStyles.hint,
          ),
        ),
        const SizedBox(height: 10),
        _controller.rxSourceListLength.build(
          builder: (final BuildContext context, final String length) {
            return _buildLengthView(length);
          },
        ),
        Expanded(
          child: _controller.rxSourceList.build(
            builder: (
              final BuildContext context,
              final List<String> items,
            ) {
              if (items.isEmpty) {
                return const Center(child: Text('No items'));
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: items.length,
                separatorBuilder: (final BuildContext context, final int index) {
                  return const Divider(
                    height: 0,
                    indent: 16,
                  );
                },
                itemBuilder: (final BuildContext context, final int index) {
                  final String item = items[index];
                  return WidgetListItem(
                    title: '$index.: $item',
                    item: item,
                    onDeletePressed: () {
                      _controller.removeItemAt(index);
                    },
                    controller: _controller,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListContent() {
    return _controller.rxListType.build(
      builder: (final BuildContext context, final ListType listType) {
        final Widget content;
        switch (listType) {
          case ListType.source:
            content = _buildListSource();
            break;
          case ListType.filter:
            content = _buildListFiltered();
            break;
          case ListType.mapped:
            content = _buildListMapped();
            break;
        }
        return Column(
          children: <Widget>[
            SegmentedButton<ListType>(
              segments: const <ButtonSegment<ListType>>[
                ButtonSegment<ListType>(
                  value: ListType.source,
                  label: WidgetSegmentedItem(
                    text: 'Source',
                    width: 80,
                  ),
                ),
                ButtonSegment<ListType>(
                  value: ListType.filter,
                  label: WidgetSegmentedItem(
                    text: 'Filtered',
                    width: 80,
                  ),
                ),
                ButtonSegment<ListType>(
                  value: ListType.mapped,
                  label: WidgetSegmentedItem(
                    text: 'Mapped',
                    width: 80,
                  ),
                ),
              ],
              selected: <ListType>{listType},
              onSelectionChanged: (final Set<ListType> value) {
                if (value.isNotEmpty) {
                  _controller.updateListType(value.first);
                }
              },
              showSelectedIcon: false,
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }

  Widget _buildSetView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '''The set is updated automatically when the source list changes
When the source list is updated, only the change is re-sorted and not the entire set''',
            style: context.textStyles.hint,
          ),
        ),
        const SizedBox(height: 10),
        _controller.rxSetLength.build(
          builder: (final BuildContext context, final String length) {
            return _buildLengthView(length);
          },
        ),
        Expanded(
          child: _controller.rxSortedSet.build(
            builder: (final BuildContext context, final Set<String> value) {
              final List<String> items = value.toList();
              if (items.isEmpty) {
                return const Center(child: Text('No items'));
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: items.length,
                separatorBuilder: (final BuildContext context, final int index) {
                  return const Divider(
                    height: 0,
                    indent: 16,
                  );
                },
                itemBuilder: (final BuildContext context, final int index) {
                  final String item = items[index];
                  return WidgetListItem(
                    title: item,
                    item: item,
                    onDeletePressed: () {
                      _controller.removeItem(item);
                    },
                    controller: _controller,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '''Shows the count of items grouped by their length
The map is updated automatically when the source list changes
When the source list is updated, the numbers are re-calculated based on the change and not the entire list''',
            style: context.textStyles.hint,
          ),
        ),
        Expanded(
          child: _controller.rxItemCountByLength.build(
            builder: (
              final BuildContext context,
              final Map<int, int> value,
            ) {
              final List<MapEntry<int, int>> items = value.entries.toList();
              if (items.isEmpty) {
                return const Center(child: Text('No items'));
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: items.length,
                separatorBuilder: (final BuildContext context, final int index) {
                  return const Divider(
                    height: 0,
                    indent: 16,
                  );
                },
                itemBuilder: (final BuildContext context, final int index) {
                  final MapEntry<int, int> entry = items[index];
                  return ListTile(
                    title: Text(
                      '${entry.key}: ${entry.value}',
                      style: context.textStyles.listItem.copyWith(fontSize: 16),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListFiltered() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '''The source list is filtered to show only items that contain at least 3 numbers
The list sorted alphabetically automatically when the source list changes''',
            style: context.textStyles.hint,
          ),
        ),
        const SizedBox(height: 10),
        _controller.rxFilteredListLength.build(
          builder: (final BuildContext context, final String length) {
            return _buildLengthView(length);
          },
        ),
        Expanded(
          child: _controller.rxFilteredList.build(
            builder: (
              final BuildContext context,
              final List<String> items,
            ) {
              if (items.isEmpty) {
                return const Center(child: Text('No items'));
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: items.length,
                separatorBuilder: (final BuildContext context, final int index) {
                  return const Divider(
                    height: 0,
                    indent: 16,
                  );
                },
                itemBuilder: (final BuildContext context, final int index) {
                  final String item = items[index];
                  return WidgetListItem(
                    title: '$index.: $item',
                    item: item,
                    onDeletePressed: () {
                      _controller.removeItem(item);
                    },
                    controller: _controller,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListMapped() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '''The source list items are mapped based on the length
The key is the length, the value is the number of items with that length''',
            style: context.textStyles.hint,
          ),
        ),
        const SizedBox(height: 10),
        _controller.rxMappedListLength.build(
          builder: (final BuildContext context, final String length) {
            return _buildLengthView(length);
          },
        ),
        Expanded(
          child: _controller.rxMappedList.build(
            builder: (
              final BuildContext context,
              final List<String> items,
            ) {
              if (items.isEmpty) {
                return const Center(child: Text('No items'));
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: items.length,
                separatorBuilder: (final BuildContext context, final int index) {
                  return const Divider(
                    height: 0,
                    indent: 16,
                  );
                },
                itemBuilder: (final BuildContext context, final int index) {
                  final String item = items[index];
                  return WidgetListItem(
                    title: '$index.: $item',
                    item: item,
                    controller: _controller,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLengthView(final String length) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: RichText(
          text: TextSpan(
            text: 'Length: ',
            style: context.textStyles.info,
            children: <TextSpan>[
              TextSpan(text: length, style: context.textStyles.infoHighlighted),
            ],
          ),
        ),
      ),
    );
  }
}

class PageCollectionsController {
  static const int addCount = 10000;
  static const String characters = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  late final RxList<String> _rxSourceList = RxList<String>();
  late final Rx<CollectionViewType> _rxViewType = Rx<CollectionViewType>(CollectionViewType.list);
  late final Rx<ListType> _rxListType = Rx<ListType>(ListType.source);
  late final RxSet<String> _rxEditingItems = RxSet<String>();

  // For computes states don't use getter otherwise a new instance will be created each time
  late final Observable<String> rxSourceListLength = _createSourceLengthObservable();
  late final ObservableList<String> rxFilteredList = _createFilteredList();
  late final Observable<String> rxFilteredListLength = _createFilteredListLengthObservable();
  late final ObservableList<String> rxMappedList = _createMappedList();
  late final Observable<String> rxMappedListLength = _createMappedListLengthObservable();

  late final ObservableSet<String> rxSortedSet = _createSortedSet();
  late final Observable<String> rxSetLength = _createSetLengthObservable();
  late final ObservableMap<int, int> rxItemCountByLength = _createCountGroupedByLengthMap();

  // You can use getters to expose the immutable states
  ObservableList<String> get rxSourceList => _rxSourceList;

  Observable<ListType> get rxListType => _rxListType;

  Observable<CollectionViewType> get rxViewType => _rxViewType;

  ObservableSet<String> get rxEditingItems => _rxEditingItems;

  void clearAll() {
    _rxSourceList.clear();
  }

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
    for (int i = 0; i < addCount; i++) {
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

  ObservableMap<int, int> _createCountGroupedByLengthMap() {
    return _rxSourceList.transformChangeAs.map(
      transform: _transformItemsByLength,
      factory: (final Map<int, int>? items) {
        return SplayTreeMap<int, int>.of(
          items ?? <int, int>{},
          (final int a, final int b) => a.compareTo(b),
        );
      },
    );
  }

  Observable<String> _createSetLengthObservable() {
    return rxSortedSet.map((final Set<String> items) => _formatNumber(items.length));
  }

  ObservableSet<String> _createSortedSet() {
    return _rxSourceList.transformChangeAs.set(
      transform: _transformSorted,
      factory: (final Iterable<String>? items) {
        return SplayTreeSet<String>.of(
          (items ?? <String>[]),
          (final String a, final String b) => a.compareTo(b),
        );
      },
    );
  }

  Observable<String> _createSourceLengthObservable() {
    return _rxSourceList.map((final List<String> items) => _formatNumber(items.length));
  }

  String _formatNumber(final int value) {
    // Format the number with commas
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (final Match match) => '${match[1]},',
        );
  }

  void _transformItemsByLength(
    final ObservableMap<int, int> current,
    final List<String> state,
    final ObservableListChange<String> change,
    final Emitter<ObservableMapUpdateAction<int, int>> updater,
  ) {
    final Map<int, String> removed = change.removed;
    final Iterable<String> added = change.added.values;
    final Map<int, int> changeByLength = <int, int>{};
    for (final String item in added) {
      final int length = item.length;
      changeByLength[length] = (changeByLength[length] ?? 0) + 1;
    }

    for (final String item in removed.values) {
      final int length = item.length;
      changeByLength[length] = (changeByLength[length] ?? 0) - 1;
    }

    final Map<int, int> addedItems = <int, int>{};
    final Set<int> removedKeys = <int>{};
    final UnmodifiableMapView<int, int> currentMap = current.value;

    for (final MapEntry<int, int> entry in changeByLength.entries) {
      final int key = entry.key;
      final int value = entry.value;
      final int newValue = (currentMap[key] ?? 0) + value;
      if (newValue > 0) {
        addedItems[key] = newValue;
      } else {
        removedKeys.add(key);
      }
    }

    updater(
      ObservableMapUpdateAction<int, int>(
        addItems: <int, int>{
          ...addedItems,
        },
        removeKeys: removedKeys,
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
        removeItems: <String>{
          ...removed.values,
          ...updated.values.map((final ObservableItemChange<String> change) {
            return change.oldValue;
          }),
        },
      ),
    );
  }

  void removeItem(final String item) {
    _rxSourceList.remove(item);
  }

  void onRemovePressed() {
    final int listLength = _rxSourceList.length;
    if (listLength == 0) {
      return;
    }

    final int removeCount = min(addCount, listLength);
    // Remove first N random items
    _rxSourceList.removeIndexes(
      Iterable<int>.generate(
        removeCount,
        (final int index) => index,
      ),
    );
  }

  void toggleEditingItem(final String item) {
    if (_rxEditingItems.contains(item)) {
      _rxEditingItems.remove(item);
    } else {
      _rxEditingItems.add(item);
    }
  }

  void updateItem({
    required final String original,
    required final String updated,
  }) {
    if (original == updated) {
      return;
    }

    final int index = _rxSourceList.value.indexOf(original);
    if (index != -1) {
      _rxSourceList[index] = updated;
    }
  }

  ObservableList<String> _createFilteredList() {
    // Show items that has at least 3 number in it, and sorted alphabetically
    return _rxSourceList
        .filterItem(
          (final String item) => item.contains(RegExp(r'[0-9]{3}')),
        )
        .sorted(
          (final String a, final String b) => a.compareTo(b),
        );
  }

  ObservableList<String> _createMappedList() {
    return _rxSourceList.mapItem(
      (final String item) => item.replaceAll(RegExp(r'[0-9]'), ''),
    );
  }

  Observable<String> _createFilteredListLengthObservable() {
    return rxFilteredList.map((final List<String> items) => _formatNumber(items.length));
  }

  Observable<String> _createMappedListLengthObservable() {
    return rxMappedList.map((final List<String> items) => _formatNumber(items.length));
  }

  void updateListType(final ListType type) {
    _rxListType.value = type;
  }
}

extension ExtensionCollectionViewType on CollectionViewType {
  Widget _buildSelectorItem(final String text) {
    return WidgetSegmentedItem(text: text);
  }

  Widget buildSelectorItem() {
    switch (this) {
      case CollectionViewType.list:
        return _buildSelectorItem('List');
      case CollectionViewType.set:
        return _buildSelectorItem('Set');
      case CollectionViewType.map:
        return _buildSelectorItem('Map');
    }
  }
}

enum CollectionViewType {
  list,
  set,
  map,
}

enum ListType {
  source,
  filter,
  mapped,
}
