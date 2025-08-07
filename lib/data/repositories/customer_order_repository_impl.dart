import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/core/services/firestore_service.dart';
import 'package:logistics/data/models/customer_order_model.dart';
// import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/domain/repositories/customer_order_repository.dart';

class CustomerOrderRepositoryImpl implements CustomerOrderRepository {
  final FirebaseFirestore _firestore;

  CustomerOrderRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirestoreService firestoreService,
  }) : _firestore = firestore;

  @override
  Future<void> createCustomerOrder(CustomerOrderModel order) async {
    await _firestore.runTransaction((transaction) async {
      // Check inventory availability for each item
      for (final item in order.items) {
        final inventorySnapshot = await _firestore
            .collection('inventory')
            .where('itemName', isEqualTo: item.itemName)
            .where('poNumber', isEqualTo: item.inventoryPoNumber)
            .get();

        if (inventorySnapshot.docs.isEmpty) {
          throw Exception('Inventory item not found: ${item.itemName}');
        }

        final inventoryDoc = inventorySnapshot.docs.first;
        final inventoryData = inventoryDoc.data();
        final currentBalance = inventoryData['balance'] as int;

        if (currentBalance < item.requestedQuantity) {
          throw Exception(
            'Not enough stock for ${item.itemName}. Available: $currentBalance, Required: ${item.requestedQuantity}',
          );
        }
      }

      // Create the customer order
      final orderRef = _firestore.collection('customer_orders').doc();
      transaction.set(orderRef, order.toFirestore());

      // Update inventory balances
      for (final item in order.items) {
        final inventorySnapshot = await _firestore
            .collection('inventory')
            .where('itemName', isEqualTo: item.itemName)
            .where('poNumber', isEqualTo: item.inventoryPoNumber)
            .get();

        final inventoryDoc = inventorySnapshot.docs.first;
        final inventoryData = inventoryDoc.data();
        final currentBalance = inventoryData['balance'] as int;
        final newBalance = currentBalance - item.requestedQuantity;

        transaction.update(inventoryDoc.reference, {'balance': newBalance});

        // Record allocation transaction
        final txRef = _firestore.collection('inventory_transactions').doc();
        transaction.set(txRef, {
          'type': 'allocate',
          'inventoryId': inventoryDoc.id,
          'itemName': item.itemName,
          'poNumber': item.inventoryPoNumber,
          'quantityDelta': -item.requestedQuantity,
          'balanceAfter': newBalance,
          'sourceRefId': orderRef.id,
          'destinationName': order.customerName,
          'destinationAddress': order.customerAddress,
          'createdAt': DateTime.now(),
        });
      }
    });
  }

  @override
  Stream<List<CustomerOrderModel>> getCustomerOrders() {
    return _firestore
        .collection('customer_orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => CustomerOrderModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Stream<List<CustomerOrderModel>> getCustomerOrdersByStatus(String status) {
    return _firestore
        .collection('customer_orders')
        .where('status', isEqualTo: status)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => CustomerOrderModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('customer_orders').doc(orderId).update({'status': status});
  }

  @override
  Future<CustomerOrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('customer_orders').doc(orderId).get();
    if (doc.exists) {
      return CustomerOrderModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<List<CustomerOrderModel>> getAllCustomerOrders() async {
    final snapshot = await _firestore
        .collection('customer_orders')
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => CustomerOrderModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> updateCustomerOrder(CustomerOrderModel order) async {
    await _firestore.collection('customer_orders').doc(order.id).update(order.toFirestore());
  }

  // Additional method to get inventory usage history
  Stream<List<CustomerOrderModel>> getOrdersByInventoryItem(String itemName, String poNumber) {
    return _firestore
        .collection('customer_orders')
        .where('items', arrayContains: {'itemName': itemName, 'inventoryPoNumber': poNumber})
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => CustomerOrderModel.fromFirestore(doc)).toList(),
        );
  }
}
