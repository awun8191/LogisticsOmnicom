import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logistics/core/services/firestore_service.dart';
import 'package:logistics/data/models/delivery_model.dart';
import 'package:logistics/data/models/inventory_model.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _inventorySubscription;
  StreamSubscription? _deliveriesSubscription;

  InventoryBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddInventory>(_onAddInventory);
    on<CreateDelivery>(_onCreateDelivery);
    on<LoadDeliveries>(_onLoadDeliveries);
    on<UpdateInventory>(_onUpdateInventory);
    on<UpdateDeliveries>(_onUpdateDeliveries);
  }

  void _onLoadInventory(LoadInventory event, Emitter<InventoryState> emit) {
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = _firestoreService.getInventory().listen((inventory) {
      add(UpdateInventory(inventory));
    });
  }

  void _onAddInventory(AddInventory event, Emitter<InventoryState> emit) async {
    try {
      await _firestoreService.addInventory(event.inventory);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  void _onCreateDelivery(CreateDelivery event, Emitter<InventoryState> emit) async {
    try {
      await _firestoreService.createDelivery(event.delivery);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  void _onLoadDeliveries(LoadDeliveries event, Emitter<InventoryState> emit) {
    emit(InventoryLoading());
    _deliveriesSubscription?.cancel();
    _deliveriesSubscription =
        _firestoreService.getDeliveries(event.inventoryId).listen((deliveries) {
      add(UpdateDeliveries(deliveries));
    });
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    _deliveriesSubscription?.cancel();
    return super.close();
  }
}

class UpdateDeliveries extends InventoryEvent {
  final List<DeliveryModel> deliveries;

  const UpdateDeliveries(this.deliveries);

  @override
  List<Object> get props => [deliveries];
}

class UpdateInventory extends InventoryEvent {
  final List<InventoryModel> inventory;

  const UpdateInventory(this.inventory);

  @override
  List<Object> get props => [inventory];
}

void _onUpdateInventory(UpdateInventory event, Emitter<InventoryState> emit) {
  emit(InventoryLoaded(event.inventory));
}

void _onUpdateDeliveries(UpdateDeliveries event, Emitter<InventoryState> emit) {
  emit(DeliveriesLoaded(event.deliveries));
}
