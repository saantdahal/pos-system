import 'package:bloc/bloc.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/order_details_model.dart';

part 'order_details_event.dart';
part 'order_details_state.dart';

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  // Mock data - replace with actual API calls
  OrderDetailsBloc() : super(const OrderDetailsInitial()) {
    on<LoadOrderDetailsEvent>(_onLoadOrderDetails);
    on<MarkItemServedEvent>(_onMarkItemServed);
    on<PickupAllEvent>(_onPickupAll);
    on<MarkAllServedEvent>(_onMarkAllServed);
    on<AddNoteEvent>(_onAddNote);
    on<CallKitchenEvent>(_onCallKitchen);
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetailsEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    emit(const OrderDetailsLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final mockOrder = OrderDetailsModel(
        id: event.orderId,
        tableNumber: 5,
        tableName: '#123 Table 5',
        status: 'serving',
        items: [
          OrderItemModel(
            id: 1,
            name: 'Momo(2)',
            quantity: 2,
            status: 'served',
          ),
          OrderItemModel(
            id: 2,
            name: 'Thukpa(1)',
            quantity: 1,
            status: 'ready_for_pickup',
          ),
          OrderItemModel(
            id: 3,
            name: 'Chow Mein(1)',
            quantity: 1,
            status: 'preparing',
          ),
        ],
        totalItems: 3,
        servedItems: 1,
        kitchenNotes:
            'Extra spicy. No cilantro on the Momo garnish please.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      emit(OrderDetailsLoaded(mockOrder));
    } catch (e) {
      emit(OrderDetailsError('Failed to load order details: $e'));
    }
  }

  Future<void> _onMarkItemServed(
    MarkItemServedEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;
      emit(OrderDetailsUpdating(currentState.order));

      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 600));

        final updatedItems = currentState.order.items.map((item) {
          if (item.id == event.itemId) {
            return item.copyWith(status: 'served');
          }
          return item;
        }).toList();

        final servedCount = updatedItems
            .where((item) => item.status == 'served')
            .length;

        final updatedOrder = currentState.order.copyWith(
          items: updatedItems,
          servedItems: servedCount,
        );

        emit(OrderDetailsUpdated(updatedOrder, 'Item marked as served'));
        emit(OrderDetailsLoaded(updatedOrder));
      } catch (e) {
        emit(OrderDetailsError('Failed to mark item as served: $e'));
      }
    }
  }

  Future<void> _onPickupAll(
    PickupAllEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;
      emit(OrderDetailsUpdating(currentState.order));

      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 600));

        emit(OrderDetailsUpdated(currentState.order, 'All items marked for pickup'));
        // Could navigate back or refresh
      } catch (e) {
        emit(OrderDetailsError('Failed to pickup items: $e'));
      }
    }
  }

  Future<void> _onMarkAllServed(
    MarkAllServedEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;
      emit(OrderDetailsUpdating(currentState.order));

      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 600));

        final updatedItems = currentState.order.items
            .map((item) => item.copyWith(status: 'served'))
            .toList();

        final updatedOrder = currentState.order.copyWith(
          items: updatedItems,
          servedItems: updatedItems.length,
        );

        emit(OrderDetailsUpdated(updatedOrder, 'All items marked as served'));
        emit(OrderDetailsLoaded(updatedOrder));
      } catch (e) {
        emit(OrderDetailsError('Failed to mark all items as served: $e'));
      }
    }
  }

  Future<void> _onAddNote(
    AddNoteEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;
      emit(OrderDetailsUpdating(currentState.order));

      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 600));

        final updatedOrder = currentState.order.copyWith(
          kitchenNotes: event.note,
        );

        emit(OrderDetailsUpdated(updatedOrder, 'Note added successfully'));
        emit(OrderDetailsLoaded(updatedOrder));
      } catch (e) {
        emit(OrderDetailsError('Failed to add note: $e'));
      }
    }
  }

  Future<void> _onCallKitchen(
    CallKitchenEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 400));

        emit(OrderDetailsUpdated(currentState.order, 'Kitchen called'));
      } catch (e) {
        emit(OrderDetailsError('Failed to call kitchen: $e'));
      }
    }
  }
}
