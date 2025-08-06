part of 'inventory_bloc.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddInventory extends InventoryEvent {
  final InventoryModel inventory;

  const AddInventory(this.inventory);

  @override
  List<Object> get props => [inventory];
}

class CreateDelivery extends InventoryEvent {
  final DeliveryModel delivery;

  const CreateDelivery(this.delivery);

  @override
  List<Object> get props => [delivery];
}

class LoadDeliveries extends InventoryEvent {
  final String inventoryId;

  const LoadDeliveries(this.inventoryId);

  @override
  List<Object> get props => [inventoryId];
}
