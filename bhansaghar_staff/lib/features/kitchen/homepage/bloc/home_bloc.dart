import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/kitchen_order_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Simulate API call or data fetching
      await Future.delayed(const Duration(seconds: 1));

      final mockOrders = [
        KitchenOrder(
          orderId: '204',
          orderType: OrderType.dineIn,
          status: OrderStatus.prep,
          location: 'Table 08',
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          items: const [
            OrderItem(
              name: 'Chicken MoMo',
              quantity: 2,
              specialInstructions: 'Extra Spicy',
            ),
            OrderItem(
              name: 'Paneer Tikka',
              quantity: 1,
              specialInstructions: 'No onions',
            ),
          ],
          timeElapsedSeconds: 720,
          chefName: 'Chef Rahul',
        ),
        KitchenOrder(
          orderId: '205',
          orderType: OrderType.takeaway,
          status: OrderStatus.pending,
          location: 'Delivery Port',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          items: const [
            OrderItem(name: 'Veg Thali', quantity: 1),
            OrderItem(name: 'Sweet Lassi', quantity: 3),
          ],
          timeElapsedSeconds: 300,
          chefName: 'Chef Rahul',
        ),
      ];

      emit(
        HomeLoaded(
          pendingCount: 3,
          prepCount: 2,
          readyCount: 1,
          activeOrders: mockOrders,
          restaurantName: 'BhansaGhar',
          chefName: 'Chef Rahul',
          isOnline: true,
          kitchenCapacity: 65,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load dashboard data'));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      await _onLoadDashboard(LoadDashboard(), emit);
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      // In a real app, this would call an API
      await Future.delayed(const Duration(milliseconds: 500));
      // Refresh to get updated data
      await _onLoadDashboard(LoadDashboard(), emit);
    }
  }
}
