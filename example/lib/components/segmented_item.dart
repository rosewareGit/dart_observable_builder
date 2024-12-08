import 'package:flutter/material.dart';

class WidgetSegmentedItem extends StatelessWidget {
  const WidgetSegmentedItem({
    required this.text,
    this.width = 80,
    super.key,
  });

  final String text;
  final double width;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Center(child: Text(text)),
        ),
      ),
    );
  }
}
