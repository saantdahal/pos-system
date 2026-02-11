import 'package:equatable/equatable.dart';

enum QrStatus { initial, loading, generated, error }

enum QrType { wifi, menu }

class QrState extends Equatable {
  final QrStatus status;
  final String? qrData;
  final QrType? qrType;
  final String? errorMessage;

  const QrState({
    this.status = QrStatus.initial,
    this.qrData,
    this.qrType,
    this.errorMessage,
  });

  QrState copyWith({
    QrStatus? status,
    String? qrData,
    QrType? qrType,
    String? errorMessage,
  }) {
    return QrState(
      status: status ?? this.status,
      qrData: qrData ?? this.qrData,
      qrType: qrType ?? this.qrType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, qrData, qrType, errorMessage];
}
