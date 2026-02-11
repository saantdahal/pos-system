part of 'mode_bloc.dart';

enum AppMode { offline, online }

class ModeState extends Equatable {
  const ModeState({this.mode = AppMode.online});

  final AppMode mode;

  ModeState copyWith({AppMode? mode}) {
    return ModeState(mode: mode ?? this.mode);
  }

  @override
  List<Object> get props => [mode];

  Map<String, dynamic> toJson() {
    return {'mode': mode.name};
  }

  factory ModeState.fromJson(Map<String, dynamic> json) {
    return ModeState(
      mode: AppMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => AppMode.online,
      ),
    );
  }
}
