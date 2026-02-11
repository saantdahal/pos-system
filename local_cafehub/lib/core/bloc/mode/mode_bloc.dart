import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'mode_event.dart';
part 'mode_state.dart';

class ModeBloc extends HydratedBloc<ModeEvent, ModeState> {
  ModeBloc() : super(const ModeState()) {
    on<ModeChanged>(_onModeChanged);
  }

  void _onModeChanged(ModeChanged event, Emitter<ModeState> emit) {
    emit(state.copyWith(mode: event.mode));
  }

  @override
  ModeState? fromJson(Map<String, dynamic> json) {
    return ModeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ModeState state) {
    return state.toJson();
  }
}
