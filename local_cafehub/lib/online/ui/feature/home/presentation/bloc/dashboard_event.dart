import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardInitialized extends DashboardEvent {
  const DashboardInitialized();
}

class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
}

class DashboardTabChanged extends DashboardEvent {
  final int tabIndex;
  const DashboardTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
