import 'package:dart_observable/dart_observable.dart';
import 'package:flutter/material.dart';

abstract class ObservableBuilderBase extends StatelessWidget {
  const ObservableBuilderBase({super.key});

  List<Observable<dynamic>> get observables;
}
