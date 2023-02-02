import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable_builder/dart_observable_builder.dart';
import 'package:dart_observable_builder_example/snackbars.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Rx<int> _rxCounter1 = Rx<int>(0);
  final Rx<int> _rxCounter2 = Rx<int>(0);
  final Rx<int> _rxCounter3 = Rx<int>(0);

  Observable<int> get rxCounter1 => _rxCounter1;

  Observable<int> get rxCounter2 => _rxCounter2;

  Observable<int> get rxCounter3 => _rxCounter3;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MultiObserverListener(
              handlers: <ObserverListenerHandler<dynamic>>[
                ObserverListenerHandler<int>(
                  observable: rxCounter1,
                  onChanged: (final BuildContext context) {
                    final int counter1 = rxCounter1.value;
                    if (counter1 % 2 == 1) {
                      context.snackbar('Counter1: $counter1');
                    }
                  },
                ),
              ],
              child: Builder(
                builder: (final BuildContext context) {
                  return Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _onCounter1Pressed,
                        child: const Text('Counter1'),
                      ),
                      ElevatedButton(
                        onPressed: _onCounter2Pressed,
                        child: const Text('Counter2'),
                      ),
                      ElevatedButton(
                        onPressed: _onCounter3Pressed,
                        child: const Text('Counter3'),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Spacer(),
            ObservableBuilder<int>(
              rxCounter1,
              builder: (final BuildContext context, final int val) {
                return Text('Counter1: $val');
              },
            ),
            const SizedBox(height: 10),
            rxCounter2.build((final BuildContext context, final int value) {
              return Text('Counter2: $value');
            }),
            const SizedBox(height: 10),
            rxCounter3.build((final BuildContext context, final int value) {
              return Text('Counter3: $value');
            }),
            const SizedBox(height: 10),
            ObservableBuilder2<int, int>(
              rxCounter1,
              rxCounter2,
              builder: (final BuildContext context, final int val1, final int val2) {
                return Text('counter1+counter2:${val1 + val2}');
              },
            ),
            const SizedBox(height: 10),
            ObservableBuilder3<int, int, int>(
              rxCounter1,
              rxCounter2,
              rxCounter3,
              builder: (
                final BuildContext context,
                final int counter1,
                final int counter2,
                final int counter3,
              ) {
                if (counter3 % 9 == 0) {
                  return Text('Counter3 only: $counter3');
                }
                return Text('counter1+counter2:${counter1 + counter2}');
              },
            ),
            const SizedBox(height: 10),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _onCounter1Pressed() {
    _rxCounter1.value = rxCounter1.value + 1;
  }

  void _onCounter2Pressed() {
    _rxCounter2.value = _rxCounter2.value + 2;
  }

  void _onCounter3Pressed() {
    _rxCounter3.value = _rxCounter3.value - 3;
  }
}
