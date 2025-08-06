import 'package:flutter/material.dart';
import 'package:logistics/data/models/delivery_model.dart';

class OrderDetailDesktopPage extends StatelessWidget {
  final DeliveryModel delivery;

  const OrderDetailDesktopPage({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery to: ${delivery.address}'),
            Text('Order Date: ${delivery.orderDate}'),
            Text('Delivery Date: ${delivery.deliveryDate}'),
            Text('Quantity: ${delivery.quantity}'),
          ],
        ),
      ),
    );
  }
}
