import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';

part 'localization_event.dart';
part 'localization_state.dart';

class LocalizationBloc
    extends HydratedBloc<LocalizationEvent, LocalizationState> {
  final PreferencesService _preferencesService;

  LocalizationBloc(this._preferencesService)
    : super(LocalizationState(Locale(_preferencesService.languageCode))) {
    on<ChangeLanguage>(_onChangeLanguage);
  }

  void _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LocalizationState> emit,
  ) {
    _preferencesService.setLanguageCode(event.locale.languageCode);
    emit(LocalizationState(event.locale));
  }

  @override
  LocalizationState? fromJson(Map<String, dynamic> json) {
    return LocalizationState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(LocalizationState state) {
    return state.toMap();
  }
}
