part of 'inventory_bloc.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryModel> inventory;

  const InventoryLoaded(this.inventory);

  @override
  List<Object> get props => [inventory];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object> get props => [message];
}

class DeliveriesLoaded extends InventoryState {
  final List<DeliveryModel> deliveries;

  const DeliveriesLoaded(this.deliveries);

  @override
  List<Object> get props => [deliveries];
}
