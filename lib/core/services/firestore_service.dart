import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/data/models/delivery_model.dart';
import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/data/models/order_model.dart';

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

  Future<DocumentReference> createInvoice(InvoiceModel invoice) async {
    try {
      final docRef = await _firestore.collection('invoices').add(invoice.toMap());
      return docRef;
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot> getInventoryByName(String name) async {
    try {
      return await _firestore.collection('inventory').where('name', isEqualTo: name).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInventoryQuantity(String docId, int newQuantity) async {
    try {
      await _firestore.collection('inventory').doc(docId).update({'quantity': newQuantity});
    } catch (e) {
      rethrow;
    }
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
