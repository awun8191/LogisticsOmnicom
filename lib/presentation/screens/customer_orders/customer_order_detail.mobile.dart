import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/presentation/bloc/customer_order_bloc/customer_order_bloc.dart';

class MobileCustomerOrderDetailPage extends StatelessWidget {
  final CustomerOrderModel order;

  const MobileCustomerOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CustomerOrderBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order ${order.poNumber}'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'update_status') {
                  _showUpdateStatusDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'update_status',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Update Status'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              const SizedBox(height: 24),
              _buildCustomerInfo(),
              const SizedBox(height: 24),
              _buildOrderItems(),
              const SizedBox(height: 24),
              _buildOrderSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('PO Number', order.poNumber),
            const SizedBox(height: 8),
            _buildInfoRow('Order Date', _formatDate(order.orderDate)),
            const SizedBox(height: 8),
            _buildInfoRow('Delivery Date', _formatDate(order.deliveryDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', order.customerName),
            const SizedBox(height: 8),
            _buildInfoRow('Address', order.customerAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildItemCard(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(CustomerOrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildItemInfo('Requested', '${item.requestedQuantity}')),
              Expanded(child: _buildItemInfo('Fulfilled', '${item.fulfilledQuantity}')),
            ],
          ),
          const SizedBox(height: 8),
          _buildItemInfo('Inventory PO', item.inventoryPoNumber),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildItemInfo('Unit Price', '\$${item.unitPrice.toStringAsFixed(2)}'),
              ),
              Expanded(child: _buildItemInfo('Total', '\$${item.totalPrice.toStringAsFixed(2)}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items:', style: TextStyle(fontSize: 15)),
                Text(
                  '${order.items.length}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Quantity:', style: TextStyle(fontSize: 15)),
                Text(
                  '${order.items.fold(0, (sum, item) => sum + item.requestedQuantity)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text('$label:', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'fulfilled':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    final statusOptions = ['pending', 'fulfilled', 'cancelled'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions.map((status) {
              return ListTile(
                title: Text(status[0].toUpperCase() + status.substring(1)),
                leading: Radio<String>(
                  value: status,
                  groupValue: order.status,
                  onChanged: (value) {
                    if (value != null && value != order.status) {
                      context.read<CustomerOrderBloc>().add(UpdateOrderStatus(order.id!, value));
                      Navigator.pop(dialogContext);
                      Navigator.pop(context); // Go back to list
                    }
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
