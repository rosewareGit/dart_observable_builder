import 'package:fl_observable/fl_observable.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../styles/theme.dart';

class WidgetListItem extends StatefulWidget {
  const WidgetListItem({
    required this.title,
    required this.item,
    required this.controller,
    this.onDeletePressed,
    super.key,
  });

  final String title;
  final String item;
  final VoidCallback? onDeletePressed;
  final PageCollectionsController controller;

  @override
  State<WidgetListItem> createState() => _WidgetListItemState();
}

class _WidgetListItemState extends State<WidgetListItem> {
  late final TextEditingController _editController = TextEditingController(text: widget.item);

  late final FocusNode _focusNode = FocusNode();

  String get item => widget.item;

  String get title => widget.title;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16),
      horizontalTitleGap: 0,
      minVerticalPadding: 0,
      minTileHeight: 32,
      title: widget.controller.rxEditingItems.build(
        builder: (final BuildContext context, final Set<String> items, _) {
          final bool isEditing = items.contains(item);
          if (isEditing) {
            return TextField(
              controller: _editController,
              focusNode: _focusNode,
              onSubmitted: (final String value) {
                widget.controller.updateItem(original: item, updated: value);
              },
            );
          }
          return Text(title, style: context.textStyles.listItem);
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.controller.rxEditingItems.build(
            builder: (final BuildContext context, final Set<String> editingItems, _) {
              final bool isEditing = editingItems.contains(item);
              final Widget icon = isEditing
                  ? const Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.edit,
                      color: AppTheme.iconColor,
                    );
              return IconButton(
                iconSize: 20,
                onPressed: () {
                  if (isEditing) {
                    _focusNode.unfocus();
                    widget.controller.updateItem(original: item, updated: _editController.text);
                  } else {
                    _focusNode.requestFocus();
                  }
                  widget.controller.toggleEditingItem(item);
                },
                icon: icon,
              );
            },
          ),
          if (widget.onDeletePressed != null)
            IconButton(
              iconSize: 20,
              icon: const Icon(Icons.delete, color: AppTheme.iconColor),
              onPressed: widget.onDeletePressed,
            ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant final WidgetListItem oldWidget) {
    if (oldWidget.item != widget.item) {
      _editController.text = widget.item;
    }
    super.didUpdateWidget(oldWidget);
  }
}
