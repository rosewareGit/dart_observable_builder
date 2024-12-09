import 'package:fl_observable/fl_observable.dart';
import 'package:fl_observable_example/styles/theme.dart';
import 'package:flutter/material.dart';

class WidgetNumberWithControls extends StatelessWidget {
  const WidgetNumberWithControls({
    required this.rxNumber,
    required this.title,
    required this.onIncrement,
    required this.onReduce,
    this.titleWidth = 100,
    super.key,
  });

  final Observable<int> rxNumber;
  final String title;
  final VoidCallback onIncrement;
  final VoidCallback onReduce;
  final double titleWidth;

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: onReduce,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: titleWidth,
          child: Center(
            child: rxNumber.build(
              builder: (final BuildContext context, final int number, final _) {
                return RichText(
                  text: TextSpan(
                    text: '$title: ',
                    style: context.textStyles.info,
                    children: <TextSpan>[
                      TextSpan(
                        text: number.toString(),
                        style: context.textStyles.infoHighlighted,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}
