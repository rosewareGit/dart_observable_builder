import 'package:flutter/material.dart';

import '../../../../fl_observable.dart';

class LoggerTypeSelector extends StatelessWidget {
  const LoggerTypeSelector({
    required this.rxSelectedTypes,
    required this.onSelectedTypesChanged,
    super.key,
  });

  final ObservableSet<WidgetObservableLoggerType> rxSelectedTypes;
  final Function(WidgetObservableLoggerType type) onSelectedTypesChanged;

  @override
  Widget build(final BuildContext context) {
    return rxSelectedTypes.build(
      builder: (
        final BuildContext context,
        final Set<WidgetObservableLoggerType> selectedTypes,
        final Widget? child,
      ) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final WidgetObservableLoggerType type in WidgetObservableLoggerType.values)
              CheckboxListTile(
                value: selectedTypes.contains(type),
                onChanged: (final bool? value) {
                  onSelectedTypesChanged(type);
                },
                title: Text(type.toString()),
              ),
          ],
        );
      },
    );
  }

  void show(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Select types'),
          content: this,
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
