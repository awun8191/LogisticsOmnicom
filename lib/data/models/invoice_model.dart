import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  final String? id;
  final String address;
  final String poNumber;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final int totalQuantity;
  final List<InvoiceItem> items;

  InvoiceModel({
    this.id,
    required this.address,
    required this.poNumber,
    required this.orderDate,
    required this.deliveryDate,
    required this.totalQuantity,
    required this.items,
  });

  factory InvoiceModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return InvoiceModel(
      id: snapshot.id,
      address: data['address'],
      poNumber: data['poNumber'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      totalQuantity: data['totalQuantity'],
      items: (data['items'] as List<dynamic>)
          .map((item) => InvoiceItem.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'poNumber': poNumber,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'totalQuantity': totalQuantity,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class InvoiceItem {
  final String sn;
  final String name;
  final int quantity;

  InvoiceItem({
    required this.sn,
    required this.name,
    required this.quantity,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      sn: map['sn'],
      name: map['name'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sn': sn,
      'name': name,
      'quantity': quantity,
    };
  }
}
