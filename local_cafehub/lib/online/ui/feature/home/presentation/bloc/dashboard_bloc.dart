import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardInitialized>(_onDashboardInitialized);
    on<DashboardRefreshed>(_onDashboardRefreshed);
    on<DashboardTabChanged>(_onDashboardTabChanged);
  }

  Future<void> _onDashboardInitialized(
    DashboardInitialized event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - in real app, fetch from API
      final data = DashboardData(
        ordersToday: 127,
        ordersTodayGrowth: 12.0,
        revenue: 52400.0,
        peakHourTime: '12 - 2 PM',
        peakHourService: 'Lunch Service',
        lowStockItems: 3,
        liveOrders: [
          const LiveOrder(
            orderNumber: '204',
            status: 'Completed',
            timestamp: '2 mins ago',
            tableNumber: '3',
            amount: 1250,
          ),
          const LiveOrder(
            orderNumber: '203',
            status: 'Preparing',
            timestamp: '5 mins ago',
            tableNumber: '5',
            amount: 890,
          ),
          const LiveOrder(
            orderNumber: '202',
            status: 'Pending',
            timestamp: '8 mins ago',
            tableNumber: '1',
            amount: 1450,
          ),
        ],
      );

      emit(DashboardLoaded(data: data));
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      emit(DashboardError('Failed to load dashboard: $e'));
    }
  }

  Future<void> _onDashboardRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      emit(const DashboardLoading());
      try {
        await Future.delayed(const Duration(seconds: 1));

        final data = DashboardData(
          ordersToday: 127,
          ordersTodayGrowth: 12.0,
          revenue: 52400.0,
          peakHourTime: '12 - 2 PM',
          peakHourService: 'Lunch Service',
          lowStockItems: 3,
          liveOrders: [
            const LiveOrder(
              orderNumber: '204',
              status: 'Completed',
              timestamp: '2 mins ago',
              tableNumber: '3',
              amount: 1250,
            ),
          ],
        );

        emit(DashboardLoaded(data: data));
      } catch (e) {
        debugPrint('Error refreshing dashboard: $e');
        emit(DashboardError('Failed to refresh dashboard'));
      }
    }
  }

  Future<void> _onDashboardTabChanged(
    DashboardTabChanged event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(currentTabIndex: event.tabIndex));
    }
  }
}
