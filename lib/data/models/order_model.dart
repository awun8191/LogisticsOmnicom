class OrderModel {
  final String id;
  final String carrier;
  final String po_number;
  final DateTime createdAt;
  final int received_qty;
  final int balance;
  final int amount_shipped;

  OrderModel({
    required this.id,
    required this.carrier,
    required this.po_number,
    required this.createdAt,
    required this.received_qty,
    required this.balance,
    required this.amount_shipped,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      carrier: json['carrier'] as String,
      po_number: json['po_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      received_qty: json['received_qty'] as int,
      balance: json['balance'] as int,
      amount_shipped: json['amount_shipped'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carrier': carrier,
      'po_number': po_number,
      'created_at': createdAt.toIso8601String(),
      'received_qty': received_qty,
      'balance': balance,
      'amount_shipped': amount_shipped,
    };
  }

  OrderModel copyWith({
    String? id,
    String? carrier,
    String? po_number,
    DateTime? createdAt,
    int? received_qty,
    int? balance,
    int? amount_shipped,
  }) {
    return OrderModel(
      id: id ?? this.id,
      carrier: carrier ?? this.carrier,
      po_number: po_number ?? this.po_number,
      createdAt: createdAt ?? this.createdAt,
      received_qty: received_qty ?? this.received_qty,
      balance: balance ?? this.balance,
      amount_shipped: amount_shipped ?? this.amount_shipped,
    );
  }
}
