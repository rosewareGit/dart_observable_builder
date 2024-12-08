import 'package:fl_observable/fl_observable.dart';
import 'package:flutter/material.dart';

import '../components/item_list.dart';
import '../components/type_selector.dart';
import 'pinned_bottom_controller.dart';
import 'style.dart';

class WidgetPinnedBottomLogger extends StatefulWidget {
  const WidgetPinnedBottomLogger({
    required this.child,
    required this.expandedHeight,
    this.buttonStyle,
    super.key,
  });

  final Widget? child;
  final double expandedHeight;
  final ButtonStyle? buttonStyle;

  @override
  State<WidgetPinnedBottomLogger> createState() => _WidgetPinnedBottomLoggerState();
}

class _WidgetPinnedBottomLoggerState extends State<WidgetPinnedBottomLogger> {
  final PinnedBottomLoggerController _controller = PinnedBottomLoggerController();

  @override
  Widget build(final BuildContext context) {
    final Widget? child = widget.child;
    if (child == null) {
      return _buildOpened(context);
    }

    final Widget controls = _controller.rxOpened.build(
      builder: (final BuildContext context, final bool opened) {
        final Widget child;
        if (opened) {
          child = Column(
            children: <Widget>[
              _buildOpenedButtons(),
              Expanded(child: _buildOpened(context)),
            ],
          );
        } else {
          child = _buildClosedButton();
        }

        return AnimatedContainer(
          height: opened ? widget.expandedHeight : 50,
          duration: const Duration(milliseconds: 100),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: child,
        );
      },
    );

    return Column(
      children: <Widget>[
        Expanded(child: child),
        controls,
      ],
    );
  }

  Widget _buildClosedButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        style: widget.buttonStyle ?? buttonStyle,
        onPressed: () {
          _controller.open();
        },
        icon: const Icon(
          Icons.analytics,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildOpened(final BuildContext context) {
    return Builder(
      builder: (final BuildContext context) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        final double screenHeight = mediaQuery.size.height;
        final double topPadding = mediaQuery.padding.top;
        final double maxHeight = screenHeight - topPadding;

        return LoggerItemList(
          rxItems: _controller.rxItems,
          showDarkMode: true,
          maxHeight: maxHeight,
        );
      },
    );
  }

  Widget _buildOpenedButtons() {
    return Row(
      children: <Widget>[
        const Spacer(),
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
            LoggerTypeSelector(
              rxSelectedTypes: _controller.rxSelectedTypes,
              onSelectedTypesChanged: (final WidgetObservableLoggerType type) {
                _controller.toggleLoggerType(type);
              },
            ).show(context);
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
        ];
      },
    );
  }
}
