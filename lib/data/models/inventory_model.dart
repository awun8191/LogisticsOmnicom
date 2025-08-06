import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryModel {
  final String? id;
  final String poNumber;
  final String itemName;
  final int quantity;
  final DateTime createdAt;

  InventoryModel({
    this.id,
    required this.poNumber,
    required this.itemName,
    required this.quantity,
    required this.createdAt,
  });

  factory InventoryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InventoryModel(
      id: doc.id,
      poNumber: data['poNumber'],
      itemName: data['itemName'],
      quantity: data['quantity'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'poNumber': poNumber,
      'itemName': itemName,
      'quantity': quantity,
      'createdAt': createdAt,
    };
  }
}
