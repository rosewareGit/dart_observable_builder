import 'package:dart_observable_builder_example/styles/theme.dart';
import 'package:flutter/material.dart';

class WidgetInfoRow extends StatelessWidget {
  const WidgetInfoRow({
    required this.title,
    required this.info,
    this.value,
    super.key,
  });

  final String info;
  final String title;
  final String? value;

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(title, style: context.textStyles.subtitle),
            ),
            Text(value ?? '', style: context.textStyles.infoHighlighted),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          info,
          style: context.textStyles.hint,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
