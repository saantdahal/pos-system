import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class WaiterOrdersBloc extends Bloc<WaiterOrdersEvent, WaiterOrdersState> {
  WaiterOrdersBloc() : super(WaiterOrdersInitial()) {
    on<WaiterOrdersEvent>((event, emit) {
      // Intentionally empty until events are defined
    });
  }
}
