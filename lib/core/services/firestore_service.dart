import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/data/models/delivery_model.dart';
import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/data/models/invoice_model.dart';
// import 'package:logistics/data/models/order_model.dart';
import 'package:logistics/data/models/customer_order_model.dart';

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

      if (inventory.balance < delivery.quantity) {
        throw Exception('Not enough inventory');
      }
      final newBalance = inventory.balance - delivery.quantity;
      transaction.update(inventoryRef, {'balance': newBalance});
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

  Future<QuerySnapshot> getInventoryByItemName(String itemName) async {
    try {
      return await _firestore.collection('inventory').where('itemName', isEqualTo: itemName).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot> getInventoryByItemAndPo(String itemName, String poNumber) async {
    try {
      return await _firestore
          .collection('inventory')
          .where('itemName', isEqualTo: itemName)
          .where('poNumber', isEqualTo: poNumber)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInventoryBalance(String docId, int newBalance) async {
    try {
      await _firestore.collection('inventory').doc(docId).update({'balance': newBalance});
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

  // Invoice management methods
  Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => InvoiceModel.fromSnapshot(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<InvoiceModel?> getInvoiceById(String id) async {
    try {
      final doc = await _firestore.collection('invoices').doc(id).get();
      if (doc.exists) {
        return InvoiceModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InvoiceModel>> getInvoicesByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => InvoiceModel.fromSnapshot(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InvoiceModel>> getInvoicesByCustomer(String customerName) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('customerName', isEqualTo: customerName)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => InvoiceModel.fromSnapshot(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InvoiceModel>> searchInvoices(String query) async {
    try {
      // Search by invoice number or customer name
      final invoiceNumberSnapshot = await _firestore
          .collection('invoices')
          .where('invoiceNumber', isGreaterThanOrEqualTo: query)
          .where('invoiceNumber', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final customerNameSnapshot = await _firestore
          .collection('invoices')
          .where('customerName', isGreaterThanOrEqualTo: query)
          .where('customerName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final Set<String> seenIds = {};
      final List<InvoiceModel> results = [];

      for (final doc in invoiceNumberSnapshot.docs) {
        if (!seenIds.contains(doc.id)) {
          results.add(InvoiceModel.fromSnapshot(doc));
          seenIds.add(doc.id);
        }
      }

      for (final doc in customerNameSnapshot.docs) {
        if (!seenIds.contains(doc.id)) {
          results.add(InvoiceModel.fromSnapshot(doc));
          seenIds.add(doc.id);
        }
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    try {
      await _firestore.collection('invoices').doc(invoice.id).update(invoice.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInvoiceStatus(String id, String status) async {
    try {
      await _firestore.collection('invoices').doc(id).update({
        'status': status,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _firestore.collection('invoices').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<InvoiceModel>> watchInvoices() {
    return _firestore.collection('invoices').orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) => InvoiceModel.fromSnapshot(doc)).toList();
      },
    );
  }

  Stream<List<InvoiceModel>> watchInvoicesByStatus(String status) {
    return _firestore
        .collection('invoices')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => InvoiceModel.fromSnapshot(doc)).toList();
        });
  }

  // Customer order methods
  Stream<List<CustomerOrderModel>> getCustomerOrders() {
    return _firestore.collection('customer_orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CustomerOrderModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<CustomerOrderModel>> getCustomerOrdersByStatus(String status) {
    return _firestore
        .collection('customer_orders')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => CustomerOrderModel.fromFirestore(doc)).toList();
        });
  }

  Future<void> createCustomerOrder(CustomerOrderModel order) async {
    await _firestore.collection('customer_orders').add(order.toFirestore());
  }

  Future<void> updateCustomerOrder(CustomerOrderModel order) async {
    await _firestore.collection('customer_orders').doc(order.id).update(order.toFirestore());
  }

  Future<void> deleteCustomerOrder(String id) async {
    await _firestore.collection('customer_orders').doc(id).delete();
  }

  // Transactions ledger
  Future<void> recordInventoryTransaction({
    required String type,
    required String inventoryId,
    required String itemName,
    required String poNumber,
    required int quantityDelta,
    required int balanceAfter,
    String? sourceRefId,
    String? destinationName,
    String? destinationAddress,
  }) async {
    await _firestore.collection('inventory_transactions').add({
      'type': type,
      'inventoryId': inventoryId,
      'itemName': itemName,
      'poNumber': poNumber,
      'quantityDelta': quantityDelta,
      'balanceAfter': balanceAfter,
      'sourceRefId': sourceRefId,
      'destinationName': destinationName,
      'destinationAddress': destinationAddress,
      'createdAt': DateTime.now(),
    });
  }

  // Create invoice and adjust inventory when not created from an order
  Future<void> createInvoiceAndAdjustInventory(InvoiceModel invoice) async {
    await _firestore.runTransaction((transaction) async {
      // Create invoice first to obtain id for transaction logs
      final invoiceRef = _firestore.collection('invoices').doc();
      transaction.set(invoiceRef, invoice.toMap());

      // For each item, deduct using a specific lot if inventoryId provided; otherwise by item+PO across lots (FIFO)
      for (final item in invoice.items) {
        if (item.inventoryId != null && item.inventoryId!.isNotEmpty) {
          final ref = _firestore.collection('inventory').doc(item.inventoryId);
          final snap = await transaction.get(ref);
          if (!snap.exists) {
            throw Exception('Inventory lot not found');
          }
          final inv = InventoryModel.fromFirestore(snap);
          if (inv.balance < item.quantity) {
            throw Exception(
              'Not enough stock for ${item.itemName}. Available: ${inv.balance}, Required: ${item.quantity}',
            );
          }
          final newBalance = inv.balance - item.quantity;
          transaction.update(ref, {'balance': newBalance});
          final txRef = _firestore.collection('inventory_transactions').doc();
          transaction.set(txRef, {
            'type': 'invoice',
            'inventoryId': ref.id,
            'itemName': inv.itemName,
            'poNumber': inv.poNumber,
            'quantityDelta': -item.quantity,
            'balanceAfter': newBalance,
            'sourceRefId': invoiceRef.id,
            'destinationName': invoice.customerName,
            'destinationAddress': invoice.customerAddress,
            'createdAt': DateTime.now(),
          });
          continue;
        }

        final query = await _firestore
            .collection('inventory')
            .where('itemName', isEqualTo: item.itemName)
            .where('poNumber', isEqualTo: item.inventoryPoNumber ?? '')
            .get();

        if (query.docs.isEmpty) {
          throw Exception(
            'Inventory not found for ${item.itemName} with PO ${item.inventoryPoNumber ?? '(none)'}',
          );
        }

        // Load and sort lots by createdAt ascending (FIFO)
        final lots = await Future.wait(
          query.docs.map((d) async {
            final snap = await transaction.get(d.reference);
            return {'ref': d.reference, 'inv': InventoryModel.fromFirestore(snap)};
          }),
        );

        lots.sort(
          (a, b) => (a['inv'] as InventoryModel).createdAt.compareTo(
            (b['inv'] as InventoryModel).createdAt,
          ),
        );

        int remaining = item.quantity;
        int totalAvailable = lots.fold(0, (sum, e) => sum + (e['inv'] as InventoryModel).balance);
        if (totalAvailable < remaining) {
          throw Exception(
            'Not enough stock for ${item.itemName}. Available: $totalAvailable, Required: $remaining',
          );
        }

        for (final lot in lots) {
          if (remaining == 0) break;
          final ref = lot['ref'] as DocumentReference;
          final inv = lot['inv'] as InventoryModel;
          final take = remaining > inv.balance ? inv.balance : remaining;
          final newBalance = inv.balance - take;
          transaction.update(ref, {'balance': newBalance});

          // Record ledger entry
          final txRef = _firestore.collection('inventory_transactions').doc();
          transaction.set(txRef, {
            'type': 'invoice',
            'inventoryId': ref.id,
            'itemName': inv.itemName,
            'poNumber': inv.poNumber,
            'quantityDelta': -take,
            'balanceAfter': newBalance,
            'sourceRefId': invoiceRef.id,
            'destinationName': invoice.customerName,
            'destinationAddress': invoice.customerAddress,
            'createdAt': DateTime.now(),
          });

          remaining -= take;
        }
      }
    });
  }
}

// Removed unused helper class
