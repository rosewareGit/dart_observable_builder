import 'package:dart_observable_builder/dart_observable_builder.dart';
import 'package:flutter/material.dart';

import '../components/item_list.dart';
import '../components/type_selector.dart';
import 'floating_bottom_controller.dart';
import 'style.dart';

class WidgetFloatingBottomLogger extends StatefulWidget {
  const WidgetFloatingBottomLogger({
    required this.child,
    this.buttonStyle,
    super.key,
  });

  final Widget? child;
  final ButtonStyle? buttonStyle;

  @override
  State<WidgetFloatingBottomLogger> createState() => _WidgetFloatingBottomLoggerState();
}

class _WidgetFloatingBottomLoggerState extends State<WidgetFloatingBottomLogger> {
  final FloatingBottomLoggerController _controller = FloatingBottomLoggerController();

  @override
  Widget build(final BuildContext context) {
    final Widget? child = widget.child;
    if (child == null) {
      return _buildOpened(context);
    }

    return LayoutBuilder(
      builder: (
        final BuildContext context,
        final BoxConstraints constraints,
      ) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: child),
            _buildOpenedControls(maxHeight: constraints.maxHeight),
          ],
        );
      },
    );
  }

  Widget _buildOpened(final BuildContext context) {
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
            );
          },
        );
      },
    );
  }

  Widget _buildOpenedButtons({
    required final double maxHeight,
  }) {
    final double upperBound;
    if (maxHeight == double.infinity) {
      upperBound = MediaQuery.of(context).size.height;
    } else {
      upperBound = maxHeight;
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Spacer(),
          Draggable<Object>(
            onDragUpdate: (final DragUpdateDetails details) {
              _controller.updateDragPosition(dy: details.delta.dy, upperBound: upperBound);
            },
            feedback: const SizedBox.shrink(),
            child: IconButton(
              style: widget.buttonStyle ?? buttonStyle,
              onPressed: () {
                if (_controller.rxDragPosition.value == 0) {
                  _controller.expand(upperBound: upperBound);
                } else {
                  _controller.collapse();
                }
              },
              icon: const Icon(
                Icons.drag_handle,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildOptions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenedControls({
    required final double maxHeight,
  }) {
    return ObservableBuilder2<double, bool>(
      _controller.rxDragPosition,
      _controller.rxAnimate,
      builder: (final BuildContext context, final double diff, final bool animate) {
        final double floatingDragPosition = FloatingBottomLoggerController.floatingControlHeight + diff;

        return AnimatedPositioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: floatingDragPosition,
          duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
          child: Column(
            children: <Widget>[
              _buildOpenedButtons(maxHeight: maxHeight),
              Expanded(child: _buildOpened(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptions() {
    return _controller.rxDragPosition.build(
      builder: (final BuildContext context, final double dragPosition) {
        return AnimatedOpacity(
          opacity: dragPosition == 0 ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: PopupMenuButton<String>(
            style: widget.buttonStyle ?? buttonStyle,
            enabled: dragPosition > 0,
            onSelected: (final String action) {
              switch (action) {
                case 'clear':
                  _controller.clear();
                  break;
                case 'select':
                  LoggerTypeSelector(
                    rxSelectedTypes: _controller.rxSelectedTypes,
                    onSelectedTypesChanged: (final WidgetObservableLoggerType type) {
                      _controller.toggleLoggerType(type);
                    },
                  ).show(context);
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
              ];
            },
          ),
        );
      },
    );
  }
}
