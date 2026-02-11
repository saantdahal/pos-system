part of 'mode_bloc.dart';

abstract class ModeEvent extends Equatable {
  const ModeEvent();

  @override
  List<Object> get props => [];
}

class ModeChanged extends ModeEvent {
  const ModeChanged(this.mode);

  final AppMode mode;

  @override
  List<Object> get props => [mode];
}
