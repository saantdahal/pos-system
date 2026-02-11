part of 'order_details_bloc.dart';


abstract class OrderDetailsState {
  const OrderDetailsState();
}

class OrderDetailsInitial extends OrderDetailsState {
  const OrderDetailsInitial();
}

class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

class OrderDetailsLoaded extends OrderDetailsState {
  final OrderDetailsModel order;

  const OrderDetailsLoaded(this.order);

  OrderDetailsLoaded copyWith({
    OrderDetailsModel? order,
  }) {
    return OrderDetailsLoaded(
      order ?? this.order,
    );
  }
}

class OrderDetailsUpdating extends OrderDetailsState {
  final OrderDetailsModel order;

  const OrderDetailsUpdating(this.order);
}

class OrderDetailsUpdated extends OrderDetailsState {
  final OrderDetailsModel order;
  final String message;

  const OrderDetailsUpdated(this.order, this.message);
}

class OrderDetailsError extends OrderDetailsState {
  final String message;

  const OrderDetailsError(this.message);
}
