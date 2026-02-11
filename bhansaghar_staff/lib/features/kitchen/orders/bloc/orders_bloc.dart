import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bhansaghar_staff/core/services/websocket_service.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/repositories/kitchen_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class KitchenOrdersBloc extends Bloc<KitchenOrdersEvent, KitchenOrdersState> {
  final KitchenRepository _repository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;

  KitchenOrdersBloc({
    required KitchenRepository repository,
    required WebSocketService webSocketService,
  }) : _repository = repository,
       _webSocketService = webSocketService,
       super(const KitchenOrdersState()) {
    on<LoadKitchenOrders>(_onLoadOrders);
    on<ConnectWebSocket>(_onConnectWebSocket);
    on<WebSocketMessageReceived>(_onWebSocketMessage);
    on<StartPrep>(_onStartPrep);
    on<MarkReady>(_onMarkReady);
    on<CreateBargain>(_onCreateBargain);
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _webSocketService.dispose();
    return super.close();
  }

  Future<void> _onLoadOrders(
    LoadKitchenOrders event,
    Emitter<KitchenOrdersState> emit,
  ) async {
    emit(state.copyWith(status: KitchenStatus.loading));
    try {
      final orders = await _repository.getLiveOrders();
      emit(state.copyWith(status: KitchenStatus.success, orders: orders));
    } catch (e) {
      emit(
        state.copyWith(
          status: KitchenStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onConnectWebSocket(
    ConnectWebSocket event,
    Emitter<KitchenOrdersState> emit,
  ) {
    final baseUrl = dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000/ws';
    final url = '$baseUrl/kitchen/${event.restaurantId}/';

    _webSocketService.connect(url);

    _wsSubscription?.cancel();
    _wsSubscription = _webSocketService.events.listen((message) {
      add(WebSocketMessageReceived(message));
    });
  }

  void _onWebSocketMessage(
    WebSocketMessageReceived event,
    Emitter<KitchenOrdersState> emit,
  ) {
    if (event.message['type'] == 'new_order') {
      add(
        LoadKitchenOrders(),
      ); // Simple reload for now, could optimize to append
    } else if (event.message['type'] == 'order_update' ||
        event.message['type'] == 'bargain_response' ||
        event.message['type'] == 'bargain_resolution') {
      add(LoadKitchenOrders());
    }
  }

  Future<void> _onStartPrep(
    StartPrep event,
    Emitter<KitchenOrdersState> emit,
  ) async {
    try {
      await _repository.startPrep(event.orderId);
      // Optimistic update
      state.orders.map((o) {
        if (o.id == event.orderId) {
          // Ideally create a copy with new status, but for now relying on reload/WS
          // or we can implement copyWith on model
        }
        return o;
      }).toList();
      // For now just wait for WS update or reload
      add(LoadKitchenOrders());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onMarkReady(
    MarkReady event,
    Emitter<KitchenOrdersState> emit,
  ) async {
    try {
      await _repository.markReady(event.orderId);
      add(LoadKitchenOrders());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onCreateBargain(
    CreateBargain event,
    Emitter<KitchenOrdersState> emit,
  ) async {
    try {
      await _repository.createBargain(
        event.orderId,
        event.itemId,
        event.originalQty,
        event.availableQty,
        event.message,
      );
      add(LoadKitchenOrders());
    } catch (e) {
      // Handle error
    }
  }
}
