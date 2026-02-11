import 'package:equatable/equatable.dart';

abstract class KitchenOrdersEvent extends Equatable {
  const KitchenOrdersEvent();

  @override
  List<Object> get props => [];
}

class LoadKitchenOrders extends KitchenOrdersEvent {}

class ConnectWebSocket extends KitchenOrdersEvent {
  final String restaurantId;
  const ConnectWebSocket(this.restaurantId);

  @override
  List<Object> get props => [restaurantId];
}

class WebSocketMessageReceived extends KitchenOrdersEvent {
  final Map<String, dynamic> message;
  const WebSocketMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class StartPrep extends KitchenOrdersEvent {
  final String orderId;
  const StartPrep(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class MarkReady extends KitchenOrdersEvent {
  final String orderId;
  const MarkReady(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class CreateBargain extends KitchenOrdersEvent {
  final String orderId;
  final int itemId;
  final int originalQty;
  final int availableQty;
  final String message;

  const CreateBargain({
    required this.orderId,
    required this.itemId,
    required this.originalQty,
    required this.availableQty,
    required this.message,
  });

  @override
  List<Object> get props => [
    orderId,
    itemId,
    originalQty,
    availableQty,
    message,
  ];
}
