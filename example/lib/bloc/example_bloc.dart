import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'example_event.dart';
part 'example_state.dart';

class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  ExampleBloc() : super(const ExampleInitial()) {
    on<GetExampleData>((event, emit) {
      emit(const ExampleLoading());
      emit(const ExampleUpdated('mock data'));
    });
  }
}
