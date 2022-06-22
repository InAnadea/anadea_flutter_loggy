part of 'example_bloc.dart';

@immutable
abstract class ExampleState {
  const ExampleState();
}

class ExampleInitial extends ExampleState {
  const ExampleInitial();
}

class ExampleLoading extends ExampleState {
  const ExampleLoading();
}

class ExampleUpdated extends ExampleState {
  const ExampleUpdated([this.data = '']);

  final String data;
}
