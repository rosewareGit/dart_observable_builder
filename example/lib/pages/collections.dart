import 'package:dart_observable_builder/dart_observable_builder.dart';
import 'package:dart_observable_builder_example/pages/collections_controller.dart';
import 'package:dart_observable_builder_example/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PageCollections extends StatefulWidget {
  const PageCollections({super.key});

  @override
  State<PageCollections> createState() => _PageCollectionsState();
}

class _PageCollectionsState extends State<PageCollections> {
  final PageCollectionsController _controller = PageCollectionsController();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Collections'),
      ),
      body: SafeArea(
        child: ObserverListener<bool>(
          observable: _controller.rxSortedListActive,
          onChanged: (
            final BuildContext context,
            final bool active,
          ) {
            SchedulerBinding.instance.addPostFrameCallback((final _) {
              if (active) {
                context.snackbar('Sorted list is active');
              } else {
                context.snackbar('Sorted list is inactive');
              }
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildTypeSelector(),
              Expanded(
                child: _buildViewForType(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _controller.onAddNamePressed();
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _buildTypeSelector() {
    return Center(
      child: _controller.rxViewType.build(
        (final BuildContext context, final CollectionViewType buildType) {
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
      (final BuildContext context, final CollectionViewType viewType) {
        switch (viewType) {
          case CollectionViewType.list:
            return _buildListView();
          case CollectionViewType.set:
            return _buildSetView();
          case CollectionViewType.map:
            return _buildMapView();
        }
      },
    );
  }

  Widget _buildListView() {
    return _controller.rxSourceList.build((
      final BuildContext context,
      final List<String> items,
    ) {
      if (items.isEmpty) {
        return const Center(child: Text('No items'));
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (final BuildContext context, final int index) {
          return ListTile(
            title: Text(items[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _controller.removeItemAt(index);
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildSetView() {
    return _controller.rxSorted.build(
      (final BuildContext context, final Set<String> value) {
        final List<String> items = value.toList();
        if (items.isEmpty) {
          return const Center(child: Text('No items'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (final BuildContext context, final int index) {
            return ListTile(
              title: Text(items[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildMapView() {
    return _controller.rxItemsByLength.build(
      (
        final BuildContext context,
        final Map<int, String> value,
      ) {
        final List<MapEntry<int, String>> items = value.entries.toList();
        if (items.isEmpty) {
          return const Center(child: Text('No items'));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (final BuildContext context, final int index) {
            final MapEntry<int, String> entry = items[index];
            return ListTile(
              title: Text('${entry.key}: ${entry.value}'),
            );
          },
        );
      },
    );
  }
}

extension ExtensionCollectionViewType on CollectionViewType {
  Widget _buildSelectorItem(final String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Text(text),
    );
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
