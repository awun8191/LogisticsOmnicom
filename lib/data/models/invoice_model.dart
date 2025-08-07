import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  final String? id;
  final String invoiceNumber;
  final String customerName;
  final String customerAddress;
  final String? customerOrderId;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double? subtotal;
  final double? taxAmount;
  final double? totalAmount;
  final String status; // draft, sent, paid, overdue, cancelled
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceModel({
    this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerAddress,
    this.customerOrderId,
    required this.invoiceDate,
    required this.dueDate,
    required this.items,
    this.subtotal,
    this.taxAmount,
    this.totalAmount,
    this.status = 'draft',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return InvoiceModel(
      id: snapshot.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      customerName: data['customerName'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      customerOrderId: data['customerOrderId'],
      invoiceDate: (data['invoiceDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      items: (data['items'] as List<dynamic>).map((item) => InvoiceItem.fromMap(item)).toList(),
      subtotal: data['subtotal'] != null ? (data['subtotal'] as num).toDouble() : null,
      taxAmount: data['taxAmount'] != null ? (data['taxAmount'] as num).toDouble() : null,
      totalAmount: data['totalAmount'] != null ? (data['totalAmount'] as num).toDouble() : null,
      status: data['status'] ?? 'draft',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerOrderId': customerOrderId,
      'invoiceDate': invoiceDate,
      'dueDate': dueDate,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? customerName,
    String? customerAddress,
    String? customerOrderId,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerOrderId: customerOrderId ?? this.customerOrderId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    return status != 'paid' && status != 'cancelled' && DateTime.now().isAfter(dueDate);
  }

  String get displayStatus {
    if (isOverdue && status != 'paid' && status != 'cancelled') {
      return 'overdue';
    }
    return status;
  }
}

class InvoiceItem {
  final String itemName;
  final String description;
  final int quantity;
  final double? unitPrice;
  final double? totalPrice;
  final String? inventoryPoNumber;
  final String? inventoryId;

  InvoiceItem({
    required this.itemName,
    required this.description,
    required this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.inventoryPoNumber,
    this.inventoryId,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      itemName: map['itemName'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: map['unitPrice'] != null ? (map['unitPrice'] as num).toDouble() : null,
      totalPrice: map['totalPrice'] != null ? (map['totalPrice'] as num).toDouble() : null,
      inventoryPoNumber: map['inventoryPoNumber'],
      inventoryId: map['inventoryId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'inventoryPoNumber': inventoryPoNumber,
      'inventoryId': inventoryId,
    };
  }

  InvoiceItem copyWith({
    String? itemName,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? inventoryPoNumber,
    String? inventoryId,
  }) {
    return InvoiceItem(
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      inventoryPoNumber: inventoryPoNumber ?? this.inventoryPoNumber,
      inventoryId: inventoryId ?? this.inventoryId,
    );
  }
}
