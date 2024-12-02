import 'package:dart_observable_builder/dart_observable_builder.dart';
import 'package:dart_observable_builder_example/snackbars.dart';
import 'package:flutter/material.dart';

import 'simple_controller.dart';

class PageSimple extends StatefulWidget {
  const PageSimple({super.key});

  @override
  State<PageSimple> createState() => _PageSimpleState();
}

class _PageSimpleState extends State<PageSimple> {
  late final PageSimpleController _controller = PageSimpleController();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Simple'),
      ),
      body: SafeArea(
        child: WidgetObservableMetrics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              ObserverListener<int>(
                observable: _controller.rxCounter,
                onChanged: (final BuildContext context, final int counter) {
                  if (counter % 5 == 0) {
                    context.snackbar('Counter: $counter');
                  }
                },
              ),
              const Divider(),
              _buildCounter(),
              const Divider(),
              _buildMappedValue(),
              const Divider(),
              _buildOddValue(),
              const Divider(),
              _buildMappedFilteredValue(),
              const SizedBox(height: 40),
              const Center(child: Text('SwitchMap')),
              const SizedBox(height: 10),
              _buildSwitchMapValue(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Row(
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            _controller.onCounterReducePressed();
          },
          child: const Icon(Icons.remove),
        ),
        Expanded(
          child: _controller.rxCounter.build(
            builder: (final BuildContext context, final int value) {
              return Text('Counter: $value', textAlign: TextAlign.center);
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _controller.onCounterIncreasePressed();
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildMappedValue() {
    return _controller.rxCounterMapped.build(
      builder: (final BuildContext context, final String value) {
        return Text(value, textAlign: TextAlign.start);
      },
    );
  }

  Widget _buildOddValue() {
    return Row(
      children: <Widget>[
        const Text('Odd: '),
        _controller.rxOdd.build(
          builder: (final BuildContext context, final int? value) {
            return Text(value?.toString() ?? 'N/A', textAlign: TextAlign.start);
          },
        ),
      ],
    );
  }

  Widget _buildMappedFilteredValue() {
    return _controller.rxMappedFiltered.build(
      builder: (final BuildContext context, final String? value) {
        return Text(value ?? 'N/A', textAlign: TextAlign.start);
      },
    );
  }

  Widget _buildSwitchMapValue() {
    return _controller.rxFlatMap.build(
      builder: (final BuildContext context, final int value) {
        return Text(value.toString(), textAlign: TextAlign.start);
      },
    );
  }
}
