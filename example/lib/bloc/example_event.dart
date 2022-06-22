part of 'example_bloc.dart';

@immutable
abstract class ExampleEvent {
  const ExampleEvent();
}

class GetExampleData extends ExampleEvent {
  const GetExampleData();
}
