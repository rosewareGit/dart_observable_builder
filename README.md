# About

Provides the Flutter components to listen to observables and update the UI.

[![Video Title](https://img.youtube.com/vi/y1-IQmouq4M/0.jpg)](https://youtu.be/y1-IQmouq4M)

### ObservableBuilder

- Listens to an observable and rebuilds the widget when the observable changes.
- ```
    final Rx<int> rxInt = Rx<int>(0);
    ObservableBuilder<int>(
      rxInt,
      builder: (BuildContext context, int value) {
        return Text(value.toString());
      },
    );
    ```
- You can use the extension method on Observable to build the widget.
- ```
    final Rx<int> rxInt = Rx<int>(0);
    rxInt.build(
      builder: (BuildContext context, int value) {
        return Text(value.toString());
      },
    );
    ```
- If you want to listen on multiple observables, you can use the other Builder components, like:
- ```
    final Rx<int> rxInt = Rx<int>(0);
    final RxString rxString = RxString('');
    ObservableBuilder2<int, String>(
      rxInt,
      rxString,
      builder: (BuildContext context, int number, String text) {
        return Text('$number: $text');
      },
    );
    ```

### Listeners

- You can create a listener Widget to listen to an observable.
- ```
  ObserverListener<int>(
    observable: _controller.rxCounter,
    onChanged: (final BuildContext context, final int counter) {
      if (counter % 5 == 0) {
        context.snackbar('Counter: $counter');
      }
    },
    child: child,
  ),
    ```

### Logger
- If you enabled the global logger, you can visualize the changes on the observables.
  - To enable the logger, use `ObservableGlobalLogger.enableGlobalLogger()`.
- Wrap your content with `WidgetObservableLogger`.

[![Video Title](https://img.youtube.com/vi/zymOay8EM2E/0.jpg)](https://youtu.be/zymOay8EM2E)

