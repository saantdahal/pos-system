import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final int ordersToday;
  final double ordersTodayGrowth;
  final double revenue;
  final String peakHourTime;
  final String peakHourService;
  final int lowStockItems;
  final List<LiveOrder> liveOrders;

  const DashboardData({
    required this.ordersToday,
    required this.ordersTodayGrowth,
    required this.revenue,
    required this.peakHourTime,
    required this.peakHourService,
    required this.lowStockItems,
    required this.liveOrders,
  });

  @override
  List<Object?> get props => [
    ordersToday,
    ordersTodayGrowth,
    revenue,
    peakHourTime,
    peakHourService,
    lowStockItems,
    liveOrders,
  ];
}

class LiveOrder extends Equatable {
  final String orderNumber;
  final String status;
  final String timestamp;
  final String tableNumber;
  final double amount;

  const LiveOrder({
    required this.orderNumber,
    required this.status,
    required this.timestamp,
    required this.tableNumber,
    required this.amount,
  });

  @override
  List<Object?> get props => [
    orderNumber,
    status,
    timestamp,
    tableNumber,
    amount,
  ];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final int currentTabIndex;

  const DashboardLoaded({required this.data, this.currentTabIndex = 0});

  DashboardLoaded copyWith({DashboardData? data, int? currentTabIndex}) {
    return DashboardLoaded(
      data: data ?? this.data,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [data, currentTabIndex];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
