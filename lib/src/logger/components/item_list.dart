import 'package:fl_observable/fl_observable.dart';
import 'package:flutter/material.dart';

import 'list_item.dart';

class LoggerItemList extends StatelessWidget {
  const LoggerItemList({
    required this.rxItems,
    required this.showDarkMode,
    required this.maxHeight,
    this.bottomPadding = 0,
    this.scrollController,
    super.key,
  });

  final ObservableMap<String, LoggerListItem> rxItems;
  final bool showDarkMode;
  final double maxHeight;
  final double bottomPadding;
  final ScrollController? scrollController;

  @override
  Widget build(final BuildContext context) {
    return Material(
      color: showDarkMode ? Colors.black : Colors.black12,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: rxItems.build(
          builder: (
            final BuildContext context,
            final Map<String, LoggerListItem> state,
          ) {
            final List<LoggerListItem> items = state.values.toList();

            final TextStyle textStyle;
            if (showDarkMode) {
              textStyle = const TextStyle(color: Colors.white);
            } else {
              textStyle = const TextStyle(color: Colors.black);
            }
            return ListView.builder(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: bottomPadding),
              controller: scrollController,
              itemCount: items.length,
              itemBuilder: (
                final BuildContext context,
                final int index,
              ) {
                final LoggerListItem item = items[index];
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
                              style: textStyle,
                            ),
                          ),
                          Text(
                            item.type.toString(),
                            maxLines: 1,
                            textAlign: TextAlign.end,
                            style: textStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.count.toString(),
                      style: textStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
