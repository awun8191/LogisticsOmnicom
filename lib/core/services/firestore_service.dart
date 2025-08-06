import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/data/models/delivery_model.dart';
import 'package:logistics/data/models/inventory_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> addInventory(InventoryModel inventory) async {
    await _firestore.collection('inventory').add(inventory.toFirestore());
  }

  Future<void> createDelivery(DeliveryModel delivery) async {
    await _firestore.runTransaction((transaction) async {
      final inventoryRef = _firestore.collection('inventory').doc(delivery.inventoryId);
      final inventorySnapshot = await transaction.get(inventoryRef);
      final inventory = InventoryModel.fromFirestore(inventorySnapshot);

      if (inventory.quantity < delivery.quantity) {
        throw Exception('Not enough inventory');
      }

      final newQuantity = inventory.quantity - delivery.quantity;
      transaction.update(inventoryRef, {'quantity': newQuantity});
      transaction.set(_firestore.collection('deliveries').doc(), delivery.toFirestore());
    });
  }

  Stream<List<InventoryModel>> getInventory() {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => InventoryModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<DeliveryModel>> getDeliveries(String inventoryId) {
    return _firestore
        .collection('deliveries')
        .where('inventoryId', isEqualTo: inventoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => DeliveryModel.fromFirestore(doc)).toList();
    });
  }
}
