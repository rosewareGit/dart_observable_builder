import 'package:dart_observable/dart_observable.dart';

class PageSimpleController {
  late final RxInt _rxCounter = RxInt(0);
  late final Observable<int> rxCounter = _rxCounter;
  late final Observable<String> rxCounterMapped = _rxCounter.map(
    (final Observable<int> source) => 'Mapped: ${source.value}',
  );
  late final Observable<int?> rxOdd = _rxCounter.filter(
    (final Observable<int> source) => source.value % 2 == 1,
  );
  late final Observable<String?> rxMappedFiltered = rxCounterMapped.filter(
    (final Observable<String> source) =>
        source.value.contains('3') || source.value.contains('7'),
  );

  late final Observable<int> rxFlatMap = _rxCounter.flatMap(
    (final Observable<int> source) {
      final int value = source.value;

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
