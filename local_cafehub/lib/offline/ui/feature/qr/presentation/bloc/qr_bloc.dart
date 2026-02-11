import 'package:flutter_bloc/flutter_bloc.dart';
import 'qr_event.dart';
import 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  QrBloc() : super(const QrState()) {
    on<GenerateWifiQr>(_onGenerateWifiQr);
    on<GenerateMenuQr>(_onGenerateMenuQr);
    on<ResetQr>(_onResetQr);
  }

  Future<void> _onGenerateWifiQr(
    GenerateWifiQr event,
    Emitter<QrState> emit,
  ) async {
    emit(state.copyWith(status: QrStatus.loading));
    try {
      // WiFi QR code format: WIFI:T:WPA;S:SSID;P:password;;
      final qrData =
          'WIFI:T:${event.encryption};S:${event.ssid};P:${event.password};;';
      emit(
        state.copyWith(
          status: QrStatus.generated,
          qrData: qrData,
          qrType: QrType.wifi,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: QrStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGenerateMenuQr(
    GenerateMenuQr event,
    Emitter<QrState> emit,
  ) async {
    emit(state.copyWith(status: QrStatus.loading));
    try {
      emit(
        state.copyWith(
          status: QrStatus.generated,
          qrData: event.url,
          qrType: QrType.menu,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: QrStatus.error, errorMessage: e.toString()));
    }
  }

  void _onResetQr(ResetQr event, Emitter<QrState> emit) {
    emit(const QrState());
  }
}
