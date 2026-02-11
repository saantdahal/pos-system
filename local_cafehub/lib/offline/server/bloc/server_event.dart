import 'package:equatable/equatable.dart';

abstract class ServerEvent extends Equatable {
  const ServerEvent();

  @override
  List<Object> get props => [];
}

class StartServer extends ServerEvent {}

class StopServer extends ServerEvent {}

class ServerStatusChanged extends ServerEvent {
  final bool isRunning;
  final String? ip;
  final int? port;

  const ServerStatusChanged({required this.isRunning, this.ip, this.port});

  @override
  List<Object> get props => [isRunning, ip ?? '', port ?? 0];
}

class CheckServerStatus extends ServerEvent {}
