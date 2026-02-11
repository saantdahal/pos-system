import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_state.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:bhansa_ghar/offline/core/services/notification_service.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_event.dart';
import 'package:permission_handler/permission_handler.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  final FlutterBackgroundService _backgroundService =
      FlutterBackgroundService();
  final NotificationService _notificationService = NotificationService();

  // Stream controller to broadcast order notification events
  final _orderNotificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onOrderNotification =>
      _orderNotificationController.stream;

  ServerBloc() : super(const ServerState()) {
    on<StartServer>(_onStartServer);
    on<StopServer>(_onStopServer);
    on<_ServerStartedEvent>(_onServerStarted);

    on<CheckServerStatus>(_onCheckServerStatus);

    // Set up background service event listeners once in constructor
    _backgroundService.on('server_started').listen((event) {
      if (event != null) {
        final host = event['host'] as String? ?? 'Unknown';
        final port = event['port'] as int? ?? 8080;
        add(_ServerStartedEvent(host: host, port: port));
      }
    });

    _backgroundService.on('server_stopped').listen((event) {
      add(StopServer());
    });

    _backgroundService.on('cancel_notification').listen((event) async {
      if (event != null) {
        final id = event['id'] as int? ?? 999;
        await _notificationService.cancelNotification(id);
      }
    });

    // Listen for order notification requests from background service
    _backgroundService.on('order_notification').listen((event) async {
      if (event != null) {
        final id =
            event['id'] as int? ??
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final title = event['title'] as String? ?? 'New Order';
        final body = event['body'] as String? ?? '';
        final orderId = event['orderId'] as String?;

        // Show system notification
        await _notificationService.showNotification(
          id: id,
          title: title,
          body: body,
        );

        // Broadcast the event so other blocs can listen and reload
        _orderNotificationController.add({
          'id': id,
          'title': title,
          'body': body,
          'orderId': orderId,
        });
      }
    });
  }

  @override
  Future<void> close() {
    _orderNotificationController.close();
    return super.close();
  }

  Future<void> _onCheckServerStatus(
    CheckServerStatus event,
    Emitter<ServerState> emit,
  ) async {
    final isRunning = await _backgroundService.isRunning();
    if (isRunning) {
      _backgroundService.invoke('get_server_status');
    } else {
      emit(state.copyWith(status: ServerStatus.stopped));
    }
  }

  Future<void> _onStartServer(
    StartServer event,
    Emitter<ServerState> emit,
  ) async {
    emit(state.copyWith(status: ServerStatus.starting));

    // Request to ignore battery optimizations for robust background execution
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    try {
      var isRunning = await _backgroundService.isRunning();

      if (!isRunning) {

        // Set up a completer to wait for service_ready event
        final readyCompleter = Completer<void>();
        _backgroundService.on('service_ready').listen((event) {
          if (!readyCompleter.isCompleted) {
            readyCompleter.complete();
          }
        });

        await _backgroundService.startService();

        // Wait for service_ready event with timeout
        await readyCompleter.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
          },
        );
      }

      // Now invoke start_server
      _backgroundService.invoke('start_server');

      // Set initial state as starting
      emit(
        state.copyWith(
          status: ServerStatus.starting,
          ip: 'Starting...',
          port: 8080,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ServerStatus.stopped,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStopServer(
    StopServer event,
    Emitter<ServerState> emit,
  ) async {
    try {
      _backgroundService.invoke('stop_server');
      emit(state.copyWith(status: ServerStatus.stopped));
    } catch (e) {
      emit(
        state.copyWith(
          status: ServerStatus.stopped,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Internal event to handle server_started from background service
  void _onServerStarted(_ServerStartedEvent event, Emitter<ServerState> emit) {
    emit(
      state.copyWith(
        status: ServerStatus.running,
        ip: event.host,
        port: event.port,
      ),
    );
  }
}

// Internal event for server started
class _ServerStartedEvent extends ServerEvent {
  final String host;
  final int port;

  const _ServerStartedEvent({required this.host, required this.port});

  @override
  List<Object> get props => [host, port];
}
