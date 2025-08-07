part of 'customer_order_bloc.dart';

abstract class CustomerOrderState extends Equatable {
  const CustomerOrderState();

  @override
  List<Object> get props => [];
}

class CustomerOrderInitial extends CustomerOrderState {}

class CustomerOrderLoading extends CustomerOrderState {}

class CustomerOrderLoaded extends CustomerOrderState {
  final List<CustomerOrderModel> orders;

  const CustomerOrderLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class CustomerOrderCreated extends CustomerOrderState {}

class CustomerOrderError extends CustomerOrderState {
  final String message;

  const CustomerOrderError(this.message);

  @override
  List<Object> get props => [message];
}
