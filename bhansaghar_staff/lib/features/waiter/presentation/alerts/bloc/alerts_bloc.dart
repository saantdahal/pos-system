import 'package:bloc/bloc.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/alert_model.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

class WaiterAlertsBloc extends Bloc<WaiterAlertsEvent, WaiterAlertsState> {
  // Mock data - replace with actual API calls
  static final List<AlertModel> _mockAlerts = [
    AlertModel(
      id: 1,
      title: 'Table 5 ready #123',
      description: 'Main course is plated and ready for...',
      type: AlertType.table,
      createdAt: DateTime.now(),
      isRead: false,
    ),
    AlertModel(
      id: 2,
      title: 'New table occupied',
      description: 'Table 12 has 4 guests. Water needed.',
      type: AlertType.table,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
    AlertModel(
      id: 3,
      title: 'Kitchen delay resolved',
      description: 'Station 2 back to normal operational...',
      type: AlertType.kitchen,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: true,
    ),
    AlertModel(
      id: 4,
      title: 'Order #119 Modification',
      description: 'Customer added Extra Cheese to...',
      type: AlertType.order,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: true,
    ),
  ];

  WaiterAlertsBloc() : super(const WaiterAlertsInitial()) {
    on<LoadAlertsEvent>(_onLoadAlerts);
    on<ChangeTabEvent>(_onChangeTab);
    on<MarkAlertAsReadEvent>(_onMarkAlertAsRead);
    on<MarkAllAlertsAsReadEvent>(_onMarkAllAlertsAsRead);
  }

  Future<void> _onLoadAlerts(
    LoadAlertsEvent event,
    Emitter<WaiterAlertsState> emit,
  ) async {
    emit(const WaiterAlertsLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final filteredAlerts = _filterAlertsByTab(event.tab);
      final recentAlerts = filteredAlerts
          .where(
            (alert) => alert.createdAt.isAfter(
              DateTime.now().subtract(const Duration(minutes: 30)),
            ),
          )
          .toList();
      final earlierAlerts = filteredAlerts
          .where(
            (alert) => alert.createdAt.isBefore(
              DateTime.now().subtract(const Duration(minutes: 30)),
            ),
          )
          .toList();

      final unreadCount = filteredAlerts.where((alert) => !alert.isRead).length;

      emit(
        WaiterAlertsLoaded(
          recentAlerts: recentAlerts,
          earlierAlerts: earlierAlerts,
          currentTab: event.tab,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(WaiterAlertsError('Failed to load alerts: $e'));
    }
  }

  Future<void> _onChangeTab(
    ChangeTabEvent event,
    Emitter<WaiterAlertsState> emit,
  ) async {
    final filteredAlerts = _filterAlertsByTab(event.tab);
    final recentAlerts = filteredAlerts
        .where(
          (alert) => alert.createdAt.isAfter(
            DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        )
        .toList();
    final earlierAlerts = filteredAlerts
        .where(
          (alert) => alert.createdAt.isBefore(
            DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        )
        .toList();
    final unreadCount = filteredAlerts.where((alert) => !alert.isRead).length;

    if (state is WaiterAlertsLoaded) {
      emit(
        (state as WaiterAlertsLoaded).copyWith(
          recentAlerts: recentAlerts,
          earlierAlerts: earlierAlerts,
          currentTab: event.tab,
          unreadCount: unreadCount,
        ),
      );
    }
  }

  Future<void> _onMarkAlertAsRead(
    MarkAlertAsReadEvent event,
    Emitter<WaiterAlertsState> emit,
  ) async {
    if (state is WaiterAlertsLoaded) {
      final currentState = state as WaiterAlertsLoaded;
      final updatedAlerts = _markAlertAsRead(event.alertId);

      final recentAlerts = updatedAlerts
          .where(
            (alert) => alert.createdAt.isAfter(
              DateTime.now().subtract(const Duration(minutes: 30)),
            ),
          )
          .toList();
      final earlierAlerts = updatedAlerts
          .where(
            (alert) => alert.createdAt.isBefore(
              DateTime.now().subtract(const Duration(minutes: 30)),
            ),
          )
          .toList();
      final unreadCount = updatedAlerts.where((alert) => !alert.isRead).length;

      emit(
        currentState.copyWith(
          recentAlerts: recentAlerts,
          earlierAlerts: earlierAlerts,
          unreadCount: unreadCount,
        ),
      );
    }
  }

  Future<void> _onMarkAllAlertsAsRead(
    MarkAllAlertsAsReadEvent event,
    Emitter<WaiterAlertsState> emit,
  ) async {
    if (state is WaiterAlertsLoaded) {
      final currentState = state as WaiterAlertsLoaded;

      for (int i = 0; i < _mockAlerts.length; i++) {
        if (!_mockAlerts[i].isRead) {
          _mockAlerts[i] = _mockAlerts[i].copyWith(isRead: true);
        }
      }

      final recentAlerts = currentState.recentAlerts
          .map((alert) => alert.copyWith(isRead: true))
          .toList();
      final earlierAlerts = currentState.earlierAlerts
          .map((alert) => alert.copyWith(isRead: true))
          .toList();

      emit(
        currentState.copyWith(
          recentAlerts: recentAlerts,
          earlierAlerts: earlierAlerts,
          unreadCount: 0,
        ),
      );
    }
  }

  List<AlertModel> _filterAlertsByTab(String tab) {
    if (tab == 'orders') {
      return _mockAlerts
          .where((alert) => alert.type == AlertType.order)
          .toList();
    } else if (tab == 'tables') {
      return _mockAlerts
          .where((alert) => alert.type == AlertType.table)
          .toList();
    }
    return _mockAlerts;
  }

  List<AlertModel> _markAlertAsRead(int alertId) {
    final index = _mockAlerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1 && !_mockAlerts[index].isRead) {
      _mockAlerts[index] = _mockAlerts[index].copyWith(isRead: true);
    }
    return _mockAlerts;
  }
}
