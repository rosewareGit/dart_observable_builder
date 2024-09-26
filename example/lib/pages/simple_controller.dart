import 'package:dart_observable/dart_observable.dart';

class PageSimpleController {
  late final RxInt _rxCounter = RxInt(0);
  late final Observable<int> rxCounter = _rxCounter;
  late final Observable<String> rxCounterMapped = _rxCounter.map(
    (final int value) => 'Mapped: $value',
  );
  late final Observable<int?> rxOdd = _rxCounter.filter(
    (final int value) => value % 2 == 1,
  );
  late final Observable<String?> rxMappedFiltered = rxCounterMapped.filter(
    (final String value) => value.contains('3') || value.contains('7'),
  );

  late final Observable<int> rxFlatMap = _rxCounter.switchMap(
    (final int value) {
      if (value % 2 == 0) {
        return Observable<int>.fromStream(
          stream: Stream<int>.periodic(
            const Duration(milliseconds: 300),
            (final int count) => value * 100 + count,
          ),
          initial: value * 100,
        );
      } else {
        return Observable<int>.fromStream(
          initial: -value * 100,
          stream: Stream<int>.periodic(
            const Duration(milliseconds: 300),
            (final int count) => -value * 100 - count,
          ),
        );
      }
    },
  );

  void onCounterIncreasePressed() {
    _rxCounter.value++;
  }

  void onCounterReducePressed() {
    _rxCounter.value--;
  }
}
