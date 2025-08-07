import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryTransactionModel {
  final String? id;
  final String type; // receive, allocate, invoice, return, adjust, delivery
  final String inventoryId;
  final String itemName;
  final String poNumber;
  final int quantityDelta; // negative for out, positive for in
  final int balanceAfter;
  final String? sourceRefId; // e.g., orderId or invoiceId
  final String? destinationName; // e.g., customer name
  final String? destinationAddress; // e.g., customer address/location
  final DateTime createdAt;

  InventoryTransactionModel({
    this.id,
    required this.type,
    required this.inventoryId,
    required this.itemName,
    required this.poNumber,
    required this.quantityDelta,
    required this.balanceAfter,
    this.sourceRefId,
    this.destinationName,
    this.destinationAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'inventoryId': inventoryId,
      'itemName': itemName,
      'poNumber': poNumber,
      'quantityDelta': quantityDelta,
      'balanceAfter': balanceAfter,
      'sourceRefId': sourceRefId,
      'destinationName': destinationName,
      'destinationAddress': destinationAddress,
      'createdAt': createdAt,
    };
  }

  factory InventoryTransactionModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return InventoryTransactionModel(
      id: snapshot.id,
      type: data['type'] ?? '',
      inventoryId: data['inventoryId'] ?? '',
      itemName: data['itemName'] ?? '',
      poNumber: data['poNumber'] ?? '',
      quantityDelta: data['quantityDelta'] ?? 0,
      balanceAfter: data['balanceAfter'] ?? 0,
      sourceRefId: data['sourceRefId'],
      destinationName: data['destinationName'],
      destinationAddress: data['destinationAddress'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
