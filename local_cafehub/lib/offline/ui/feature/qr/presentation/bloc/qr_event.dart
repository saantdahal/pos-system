import 'package:equatable/equatable.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class GenerateWifiQr extends QrEvent {
  final String ssid;
  final String password;
  final String encryption;

  const GenerateWifiQr({
    required this.ssid,
    required this.password,
    this.encryption = 'WPA',
  });

  @override
  List<Object?> get props => [ssid, password, encryption];
}

class GenerateMenuQr extends QrEvent {
  final String url;

  const GenerateMenuQr(this.url);

  @override
  List<Object?> get props => [url];
}

class ResetQr extends QrEvent {}
