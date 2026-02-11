import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(isDarkMode: true)) {
    on<ToggleThemeEvent>((event, emit) {
      emit(ThemeState(isDarkMode: !state.isDarkMode));
    });
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    return ThemeState(isDarkMode: json['isDarkMode'] as bool);
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {'isDarkMode': state.isDarkMode};
  }
}
