part of 'alerts_bloc.dart';


abstract class WaiterAlertsState {
  const WaiterAlertsState();
}

class WaiterAlertsInitial extends WaiterAlertsState {
  const WaiterAlertsInitial();
}

class WaiterAlertsLoading extends WaiterAlertsState {
  const WaiterAlertsLoading();
}

class WaiterAlertsLoaded extends WaiterAlertsState {
  final List<AlertModel> recentAlerts;
  final List<AlertModel> earlierAlerts;
  final String currentTab; // 'all', 'orders', 'tables'
  final int unreadCount;

  const WaiterAlertsLoaded({
    required this.recentAlerts,
    required this.earlierAlerts,
    required this.currentTab,
    required this.unreadCount,
  });

  WaiterAlertsLoaded copyWith({
    List<AlertModel>? recentAlerts,
    List<AlertModel>? earlierAlerts,
    String? currentTab,
    int? unreadCount,
  }) {
    return WaiterAlertsLoaded(
      recentAlerts: recentAlerts ?? this.recentAlerts,
      earlierAlerts: earlierAlerts ?? this.earlierAlerts,
      currentTab: currentTab ?? this.currentTab,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class WaiterAlertsError extends WaiterAlertsState {
  final String message;

  const WaiterAlertsError(this.message);
}


