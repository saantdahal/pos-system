import 'package:equatable/equatable.dart';

enum ServerStatus { initial, starting, running, stopping, stopped, error }

class ServerState extends Equatable {
  final ServerStatus status;
  final String? ip;
  final int? port;
  final String? errorMessage;

  const ServerState({
    this.status = ServerStatus.initial,
    this.ip,
    this.port,
    this.errorMessage,
  });

  ServerState copyWith({
    ServerStatus? status,
    String? ip,
    int? port,
    String? errorMessage,
  }) {
    return ServerState(
      status: status ?? this.status,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ip, port, errorMessage];
}
