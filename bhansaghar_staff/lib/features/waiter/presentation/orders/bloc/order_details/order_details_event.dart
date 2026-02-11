part of 'order_details_bloc.dart';

abstract class OrderDetailsEvent {
  const OrderDetailsEvent();
}

class LoadOrderDetailsEvent extends OrderDetailsEvent {
  final int orderId;

  const LoadOrderDetailsEvent(this.orderId);
}

class MarkItemServedEvent extends OrderDetailsEvent {
  final int itemId;

  const MarkItemServedEvent(this.itemId);
}

class PickupAllEvent extends OrderDetailsEvent {
  const PickupAllEvent();
}

class MarkAllServedEvent extends OrderDetailsEvent {
  const MarkAllServedEvent();
}

class AddNoteEvent extends OrderDetailsEvent {
  final String note;

  const AddNoteEvent(this.note);
}

class CallKitchenEvent extends OrderDetailsEvent {
  const CallKitchenEvent();
}
