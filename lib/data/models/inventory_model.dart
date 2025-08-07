import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryModel {
  final String? id;
  final String poNumber;
  final String itemName;
  final int originalQuantity;
  final int balance;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final DateTime createdAt;

  InventoryModel({
    this.id,
    required this.poNumber,
    required this.itemName,
    required this.originalQuantity,
    required this.balance,
    required this.orderDate,
    required this.deliveryDate,
    required this.createdAt,
  });

  factory InventoryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InventoryModel(
      id: doc.id,
      poNumber: data['poNumber'],
      itemName: data['itemName'],
      originalQuantity: data['originalQuantity'] ?? 0,
      balance: data['balance'] ?? 0,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'poNumber': poNumber,
      'itemName': itemName,
      'originalQuantity': originalQuantity,
      'balance': balance,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'createdAt': createdAt,
    };
  }

  InventoryModel copyWith({
    String? id,
    String? poNumber,
    String? itemName,
    int? originalQuantity,
    int? balance,
    DateTime? orderDate,
    DateTime? deliveryDate,
    DateTime? createdAt,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      itemName: itemName ?? this.itemName,
      originalQuantity: originalQuantity ?? this.originalQuantity,
      balance: balance ?? this.balance,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
