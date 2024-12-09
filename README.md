# About

Provides the Flutter components for the [DartObservable](https://pub.dev/packages/dart_observable) package.

### ObservableBuilder

Listens to an observable and rebuilds the widget when the given observable changes.  
The registration is explicit, any other observable used within the builder scope is NOT registered automatically.  
The default builder only accepts one observable, but you can use the other builders to listen to multiple observables.  
You can pass an optional `shouldRebuild` function to avoid unwanted rebuilds.

```
    final Rx<int> rxInt = Rx<int>(0);
    ObservableBuilder<int>(
      rxInt,
      builder: (BuildContext context, int value, Widget? child) {
        return Text(value.toString());
      },
    );
```

You can use the extension method on Observable to build the widget.

```
    final Rx<int> rxInt = Rx<int>(0);
    rxInt.build(
      builder: (BuildContext context, int value, Widget? child) {
        return Text(value.toString());
      },
    );
```

If you want to listen on multiple observables, you can use the other Builder components, like:

```
    final Rx<int> rxInt = Rx<int>(0);
    final RxString rxString = RxString('');
    ObservableBuilder2<int, String>(
      rxInt,
      rxString,
      builder: (BuildContext context, int number, String text, Widget? child) {
        return Text('$number: $text');
      },
    );
```

### Listeners

You can create a listener Widget to listen to an observable.

```
  ObservableListener<int>(
    observable: rxCounter,
    shouldNotify: (final int counter) => counter % 5 == 0,
    onChanged: (final BuildContext context, final int counter) {
        context.snackbar('Counter: $counter');
    },
    child: child,
  ),
```

For multiple listeners you can use `MultiObservableListener`.

 ```
 MultiObservableListener(
   handlers: [
     ObservableListenerHandler<int>(
       observable: myObservable1,
       onChanged: (context, value) {
         print('Observable 1 value changed: $value');
       },
     ),
     ObservableListenerHandler<String>(
       observable: myObservable2,
       onChanged: (context, value) {
         print('Observable 2 value changed: $value');
       },
     ),
   ],
   child: Text('Listening to multiple observables'),
 );
 ```

### Example app

[![Example app](https://img.youtube.com/vi/y1-IQmouq4M/0.jpg)](https://youtu.be/y1-IQmouq4M)

### Logger

If you enabled the global logger, you can visualize the changes on the observables.

- To enable the logger, use `ObservableGlobalLogger.enableGlobalLogger()`.

Wrap your content with `WidgetObservableLogger`.

[![Logger](https://img.youtube.com/vi/zymOay8EM2E/0.jpg)](https://youtu.be/zymOay8EM2E)

