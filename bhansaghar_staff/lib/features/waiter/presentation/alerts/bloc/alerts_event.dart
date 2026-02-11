part of 'alerts_bloc.dart';

abstract class WaiterAlertsEvent {
  const WaiterAlertsEvent();
}

class LoadAlertsEvent extends WaiterAlertsEvent {
  final String tab; // 'all', 'orders', 'tables'

  const LoadAlertsEvent({this.tab = 'all'});
}

class ChangeTabEvent extends WaiterAlertsEvent {
  final String tab;

  const ChangeTabEvent(this.tab);
}

class MarkAlertAsReadEvent extends WaiterAlertsEvent {
  final int alertId;

  const MarkAlertAsReadEvent(this.alertId);
}

class MarkAllAlertsAsReadEvent extends WaiterAlertsEvent {
  const MarkAllAlertsAsReadEvent();
}
