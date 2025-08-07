import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOrderModel {
  final String? id;
  final String customerName;
  final String customerAddress;
  final String poNumber;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final List<CustomerOrderItem> items;
  final double totalAmount;
  final String status;

  CustomerOrderModel({
    this.id,
    required this.customerName,
    required this.customerAddress,
    required this.poNumber,
    required this.orderDate,
    required this.deliveryDate,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
  });

  factory CustomerOrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CustomerOrderModel(
      id: doc.id,
      customerName: data['customerName'],
      customerAddress: data['customerAddress'],
      poNumber: data['poNumber'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      items: (data['items'] as List<dynamic>)
          .map((item) => CustomerOrderItem.fromMap(item))
          .toList(),
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerName': customerName,
      'customerAddress': customerAddress,
      'poNumber': poNumber,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
    };
  }

  CustomerOrderModel copyWith({
    String? id,
    String? customerName,
    String? customerAddress,
    String? poNumber,
    DateTime? orderDate,
    DateTime? deliveryDate,
    List<CustomerOrderItem>? items,
    double? totalAmount,
    String? status,
  }) {
    return CustomerOrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      poNumber: poNumber ?? this.poNumber,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
    );
  }
}

class CustomerOrderItem {
  final String itemName;
  final int requestedQuantity;
  final int fulfilledQuantity;
  final String inventoryPoNumber;
  final double unitPrice;
  final double totalPrice;

  CustomerOrderItem({
    required this.itemName,
    required this.requestedQuantity,
    required this.fulfilledQuantity,
    required this.inventoryPoNumber,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory CustomerOrderItem.fromMap(Map<String, dynamic> map) {
    return CustomerOrderItem(
      itemName: map['itemName'],
      requestedQuantity: map['requestedQuantity'],
      fulfilledQuantity: map['fulfilledQuantity'],
      inventoryPoNumber: map['inventoryPoNumber'],
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'requestedQuantity': requestedQuantity,
      'fulfilledQuantity': fulfilledQuantity,
      'inventoryPoNumber': inventoryPoNumber,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}
