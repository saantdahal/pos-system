part of 'localization_bloc.dart';

class LocalizationState extends Equatable {
  final Locale locale;

  const LocalizationState(this.locale);

  Map<String, dynamic> toMap() {
    return {'languageCode': locale.languageCode};
  }

  factory LocalizationState.fromMap(Map<String, dynamic> map) {
    return LocalizationState(Locale(map['languageCode'] as String));
  }

  @override
  List<Object> get props => [locale];
}
