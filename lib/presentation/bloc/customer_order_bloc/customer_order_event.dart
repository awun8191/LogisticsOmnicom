part of 'customer_order_bloc.dart';

abstract class CustomerOrderEvent extends Equatable {
  const CustomerOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomerOrders extends CustomerOrderEvent {
  const LoadCustomerOrders();
}

class CreateCustomerOrder extends CustomerOrderEvent {
  final CustomerOrderModel order;

  const CreateCustomerOrder(this.order);

  @override
  List<Object> get props => [order];
}

class UpdateOrderStatus extends CustomerOrderEvent {
  final String orderId;
  final String status;

  const UpdateOrderStatus(this.orderId, this.status);

  @override
  List<Object> get props => [orderId, status];
}

class LoadOrdersByStatus extends CustomerOrderEvent {
  final String status;

  const LoadOrdersByStatus(this.status);

  @override
  List<Object> get props => [status];
}
