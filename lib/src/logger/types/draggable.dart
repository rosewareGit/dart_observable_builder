import 'package:fl_observable/fl_observable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/item_list.dart';
import '../components/type_selector.dart';
import 'draggable_controller.dart';
import 'style.dart';

class WidgetDraggableLogger extends StatefulWidget {
  const WidgetDraggableLogger({
    required this.child,
    this.buttonStyle,
    super.key,
  });

  final Widget? child;
  final ButtonStyle? buttonStyle;

  @override
  State<WidgetDraggableLogger> createState() => _WidgetDraggableLoggerState();
}

class _WidgetDraggableLoggerState extends State<WidgetDraggableLogger> {
  final DraggableLoggerController _controller = DraggableLoggerController();

  @override
  Widget build(final BuildContext context) {
    final Widget? child = widget.child;
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        _controller.maxHeight = constraints.maxHeight;
        _controller.maxWidth = constraints.maxWidth;
        return Stack(
          children: <Widget>[
            _buildOpened(showBelowContent: true),
            if (child != null) Positioned.fill(child: child),
            _buildControls(),
            _buildOpened(showBelowContent: false),
            _buildBottomRightHandle(),
          ],
        );
      },
    );
  }

  Widget _buildBottomRightHandle() {
    return _controller.rxOpened.build(
      builder: (final BuildContext context, final bool opened) {
        if (opened == false) {
          return const Positioned(
            width: 0,
            height: 0,
            child: SizedBox.shrink(),
          );
        }

        return _controller.rxBottomRightOffset.build(
          builder: (final BuildContext context, final Offset offset) {
            return Positioned(
              right: offset.dx,
              bottom: offset.dy,
              height: DraggableLoggerController.bottomHeight,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  child: Draggable<Object>(
                    hitTestBehavior: HitTestBehavior.translucent,
                    onDragUpdate: (final DragUpdateDetails details) {
                      _controller.updateBottomRightDragOffsetBy(details.delta);
                    },
                    feedback: const SizedBox.shrink(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        CupertinoIcons.arrow_up_left_arrow_down_right,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClosedButton() {
    return LongPressDraggable<Object>(
      delay: const Duration(milliseconds: 300),
      onDragUpdate: (final DragUpdateDetails details) {
        _controller.updateTopLeftDragOffsetBy(details.delta);
      },
      feedback: const SizedBox.shrink(),
      child: IconButton(
        onPressed: _controller.open,
        style: widget.buttonStyle ?? buttonStyle,
        icon: const Icon(Icons.bar_chart, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(final BuildContext context) {
    return Builder(
      builder: (final BuildContext context) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        final double screenHeight = mediaQuery.size.height;
        final double topPadding = mediaQuery.padding.top;
        final double maxHeight = screenHeight - topPadding;

        return _controller.rxDarkMode.build(
          builder: (final BuildContext context, final bool showDarkMode) {
            return LoggerItemList(
              rxItems: _controller.rxItems,
              showDarkMode: showDarkMode,
              maxHeight: maxHeight,
              bottomPadding: 50,
              scrollController: _controller.scrollController,
            );
          },
        );
      },
    );
  }

  Widget _buildControls() {
    return ObservableBuilder3<Offset, Offset, bool>(
      _controller.rxTopLeftOffset,
      _controller.rxBottomRightOffset,
      _controller.rxOpened,
      builder: (
        final BuildContext context,
        final Offset topLeft,
        final Offset bottomRight,
        final bool opened,
      ) {
        return Positioned(
          top: topLeft.dy,
          left: topLeft.dx,
          right: opened ? bottomRight.dx : null,
          height: DraggableLoggerController.headerHeight,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Builder(
              builder: (final BuildContext context) {
                if (opened) {
                  return _buildOpenedButtons();
                }

                return _buildClosedButton();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Draggable<Object>(
        onDragUpdate: (final DragUpdateDetails details) {
          _controller.updateDrag(details.delta);
        },
        feedback: const SizedBox.shrink(),
        child: const Icon(
          Icons.drag_handle,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildOpened({
    required final bool showBelowContent,
  }) {
    return _controller.rxOpened.build(
      builder: (final BuildContext context, final bool opened) {
        if (opened == false) {
          return const Positioned(
            width: 0,
            height: 0,
            child: SizedBox.shrink(),
          );
        }

        return ObservableBuilder2<Offset, Offset>(
          _controller.rxTopLeftOffset,
          _controller.rxBottomRightOffset,
          builder: (
            final BuildContext context,
            final Offset topLeft,
            final Offset bottomRight,
          ) {
            return Positioned(
              top: topLeft.dy + DraggableLoggerController.headerHeight,
              left: topLeft.dx,
              right: bottomRight.dx,
              bottom: bottomRight.dy,
              child: _controller.rxShowBelowContent.build(
                builder: (final BuildContext context, final bool rxBelowContent) {
                  if (showBelowContent != rxBelowContent) {
                    return const SizedBox.shrink();
                  }

                  return _buildContent(context);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOpenedButtons() {
    return Row(
      children: <Widget>[
        const SizedBox(width: 8),
        MouseRegion(
          cursor: SystemMouseCursors.resizeUpLeftDownRight,
          child: Draggable<Object>(
            onDragUpdate: (final DragUpdateDetails details) {
              _controller.updateTopLeftDragOffsetBy(details.delta);
            },
            feedback: const SizedBox.shrink(),
            child: const Icon(
              CupertinoIcons.arrow_up_left_arrow_down_right,
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        _buildDragHandle(),
        _buildOptions(),
        IconButton(
          style: widget.buttonStyle ?? buttonStyle,
          onPressed: () {
            _controller.close();
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return PopupMenuButton<String>(
      style: widget.buttonStyle ?? buttonStyle,
      onSelected: (final String action) {
        switch (action) {
          case 'clear':
            _controller.clear();
            break;
          case 'select':
            _showSelectTypeDialog(context);
            break;
          case 'position':
            _controller.toggleZPosition();
            break;
          case 'reset':
            _controller.resetPosition();
            break;
          case 'color':
            _controller.toggleColorMode();
            break;
        }
      },
      itemBuilder: (final BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'clear',
            child: Text('Clear'),
          ),
          const PopupMenuItem<String>(
            value: 'select',
            child: Text('Select types'),
          ),
          const PopupMenuItem<String>(
            value: 'color',
            child: Text('Change color'),
          ),
          PopupMenuItem<String>(
            value: 'position',
            child: _controller.rxShowBelowContent.build(
              builder: (final BuildContext context, final bool showBelowContent) {
                if (showBelowContent) {
                  return const Text('Bring to front');
                }

                return const Text('Move to back');
              },
            ),
          ),
          const PopupMenuItem<String>(
            value: 'reset',
            child: Text('Reset position'),
          ),
        ];
      },
    );
  }

  void _showSelectTypeDialog(final BuildContext context) {
    LoggerTypeSelector(
      rxSelectedTypes: _controller.rxSelectedTypes,
      onSelectedTypesChanged: (final WidgetObservableLoggerType type) {
        _controller.toggleLoggerType(type);
      },
    ).show(context);
  }
}
