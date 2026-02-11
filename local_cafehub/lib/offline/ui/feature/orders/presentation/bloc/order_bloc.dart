import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/models/order_item.dart';
import 'order_event.dart';
import 'order_state.dart';
import 'order_filter.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_bloc.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;
  StreamSubscription? _orderSubscription;
  StreamSubscription? _serverNotificationSubscription;

  OrderBloc({required OrderRepository orderRepository, ServerBloc? serverBloc})
    : _orderRepository = orderRepository,
      super(const OrderState()) {
    on<LoadOrders>(_onLoadOrders);
    on<AddOrder>(_onAddOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<NegotiateOrder>(_onNegotiateOrder);
    on<LoadMoreOrders>(_onLoadMoreOrders);

    on<UpdateFilter>(_onUpdateFilter);

    // Clear old seed orders once when bloc is created
    _clearOldSeedOrders();

    // Listen to order repository stream for real-time updates
    _orderSubscription = _orderRepository.onOrderAdded.listen((order) {
      add(LoadOrders());
    });

    // Listen to ServerBloc's order notification stream
    if (serverBloc != null) {
      _serverNotificationSubscription = serverBloc.onOrderNotification.listen((
        event,
      ) {
  

        add(LoadOrders());
      });
    } else {
      debugPrint(
        '[OrderBloc] WARNING: ServerBloc is null, notifications will not trigger reloads',
      );
    }
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    _serverNotificationSubscription?.cancel();
    return super.close();
  }

  // One-time cleanup of old seed orders
  Future<void> _clearOldSeedOrders() async {
    try {
      // Check if we've already cleared seed orders
      final box = await Hive.openBox('app_settings');
      final hasCleared = box.get('seed_orders_cleared', defaultValue: false);

      if (!hasCleared) {
        // Clear all orders to remove seed data (one-time only)
        await _orderRepository.clearAllOrders();
        // Mark as cleared so this doesn't run again
        await box.put('seed_orders_cleared', true);
      }

      await box.close();
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    debugPrint('[OrderBloc] _onLoadOrders called');
    // Only show loading indicator if we don't have any orders yet
    // This prevents UI flickering during auto-refresh
    if (state.orders.isEmpty) {
      emit(state.copyWith(status: OrderStatus.loading));
    }

    try {
      final orders = await _orderRepository.getOrders();
      if (orders.isNotEmpty) {
      }
      final allFilteredOrders = _applyFilter(orders, state.filter);

      final filteredOrders = allFilteredOrders.take(state.pageLimit).toList();

      emit(
        state.copyWith(
          status: OrderStatus.loaded,
          orders: orders,
          allFilteredOrders: allFilteredOrders,
          filteredOrders: filteredOrders,
        ),
      );
    } catch (e) {
      debugPrint('[OrderBloc] Error loading orders: $e');
      // Only emit error state if we have no data to show.
      // If we have data, just log the error and keep showing old data.
      if (state.orders.isEmpty) {
        emit(
          state.copyWith(status: OrderStatus.error, errorMessage: e.toString()),
        );
      }
    }
  }

  Future<void> _onAddOrder(AddOrder event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.addOrder(event.order);
      add(LoadOrders());
    } catch (e) {
      emit(
        state.copyWith(status: OrderStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await _orderRepository.updateOrderStatus(event.orderId, event.status);
      add(LoadOrders());
    } catch (e) {
      emit(
        state.copyWith(status: OrderStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateFilter(
    UpdateFilter event,
    Emitter<OrderState> emit,
  ) async {
    final allFilteredOrders = _applyFilter(state.orders, event.filter);
    const newLimit = 5;
    final filteredOrders = allFilteredOrders.take(newLimit).toList();

    emit(
      state.copyWith(
        filter: event.filter,
        allFilteredOrders: allFilteredOrders,
        filteredOrders: filteredOrders,
        pageLimit: newLimit,
      ),
    );
  }

  Future<void> _onLoadMoreOrders(
    LoadMoreOrders event,
    Emitter<OrderState> emit,
  ) async {
    final newLimit = state.pageLimit + 5;
    final filteredOrders = state.allFilteredOrders.take(newLimit).toList();
    emit(state.copyWith(pageLimit: newLimit, filteredOrders: filteredOrders));
  }

  List<Order> _applyFilter(List<Order> orders, OrderFilter filter) {
    var result = List<Order>.from(orders);

    // Filter by status
    if (filter.status.isNotEmpty) {
      result = result
          .where((order) => filter.status.contains(order.status))
          .toList();
    }

    // Filter by table number
    if (filter.tableNumber != null) {
      result = result
          .where((order) => order.tableNumber == filter.tableNumber)
          .toList();
    }

    // Sort
    result.sort((a, b) {
      switch (filter.sortOrder) {
        case SortOrder.newest:
          return b.createdAt.compareTo(a.createdAt);
        case SortOrder.oldest:
          return a.createdAt.compareTo(b.createdAt);
      }
    });

    return result;
  }

  Future<void> _onNegotiateOrder(
    NegotiateOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      // Since we don't have direct access to the server URL here easily without injecting it,
      // and we are running on the same device, we can try localhost.
      // Ideally, we should get the IP from ServerBloc or a config.
      // For now, using localhost:8080 as a fallback.

      // Note: In a real production app, use a proper API client with base URL configuration.

      // We need http package. If not imported, we need to add import 'package:http/http.dart' as http;
      // But OrderBloc doesn't have http import yet.
      // Alternatively, we can add a method to OrderRepository to handle this.
      // Adding it to OrderRepository is cleaner.

      await _orderRepository.negotiateOrder(event.orderId, event.items);

      // Reload orders to reflect changes (although server notification should also trigger it)
      add(LoadOrders());
    } catch (e) {
      emit(
        state.copyWith(status: OrderStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
