import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryModel {
  final String? id;
  final String inventoryId;
  final int quantity;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String address;

  DeliveryModel({
    this.id,
    required this.inventoryId,
    required this.quantity,
    required this.orderDate,
    required this.deliveryDate,
    required this.address,
  });

  factory DeliveryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DeliveryModel(
      id: doc.id,
      inventoryId: data['inventoryId'],
      quantity: data['quantity'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      address: data['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'inventoryId': inventoryId,
      'quantity': quantity,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'address': address,
    };
  }
}
