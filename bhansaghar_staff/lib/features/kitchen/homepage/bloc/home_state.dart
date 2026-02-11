part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int pendingCount;
  final int prepCount;
  final int readyCount;
  final List<KitchenOrder> activeOrders;
  final String restaurantName;
  final String chefName;
  final bool isOnline;
  final int kitchenCapacity;

  const HomeLoaded({
    required this.pendingCount,
    required this.prepCount,
    required this.readyCount,
    required this.activeOrders,
    required this.restaurantName,
    required this.chefName,
    this.isOnline = true,
    this.kitchenCapacity = 0,
  });

  @override
  List<Object> get props => [
    pendingCount,
    prepCount,
    readyCount,
    activeOrders,
    restaurantName,
    chefName,
    isOnline,
    kitchenCapacity,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
