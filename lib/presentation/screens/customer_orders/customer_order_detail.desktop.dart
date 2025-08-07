import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/presentation/bloc/customer_order_bloc/customer_order_bloc.dart';

class DesktopCustomerOrderDetailPage extends StatelessWidget {
  final CustomerOrderModel order;

  const DesktopCustomerOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CustomerOrderBloc>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [_buildOrderHeader(), const SizedBox(height: 24), _buildOrderItems()],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildCustomerInfo(),
                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Order ${order.poNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[800],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey[200]),
      ),
      actions: [_buildStatusChip(order.status), const SizedBox(width: 16)],
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'ID: ${order.id ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard('PO Number', order.poNumber, Icons.receipt_long_outlined),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Order Date',
                    _formatDate(order.orderDate),
                    Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Delivery Date',
                    _formatDate(order.deliveryDate),
                    Icons.local_shipping_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${order.items.length})',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            _buildItemsDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 56,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        columnSpacing: 24,
        headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
        columns: const [
          DataColumn(label: Text('Item Name')),
          DataColumn(label: Text('Inventory PO')),
          DataColumn(label: Text('Requested'), numeric: true),
          DataColumn(label: Text('Fulfilled'), numeric: true),
          DataColumn(label: Text('Unit Price'), numeric: true),
          DataColumn(label: Text('Total Price'), numeric: true),
        ],
        rows: order.items.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.inventoryPoNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(Text(item.requestedQuantity.toString())),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.fulfilledQuantity == item.requestedQuantity
                        ? Colors.green[50]
                        : item.fulfilledQuantity > 0
                        ? Colors.orange[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.fulfilledQuantity.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: item.fulfilledQuantity == item.requestedQuantity
                          ? Colors.green[700]
                          : item.fulfilledQuantity > 0
                          ? Colors.orange[700]
                          : Colors.red[700],
                    ),
                  ),
                ),
              ),
              DataCell(Text('\$${item.unitPrice.toStringAsFixed(2)}')),
              DataCell(
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            _buildCustomerInfoRow(Icons.person_outlined, 'Name', order.customerName),
            const SizedBox(height: 16),
            _buildCustomerInfoRow(Icons.location_on_outlined, 'Address', order.customerAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final totalItems = order.items.length;
    final totalQuantity = order.items.fold(0, (sum, item) => sum + item.requestedQuantity);
    final fulfilledQuantity = order.items.fold(0, (sum, item) => sum + item.fulfilledQuantity);
    final fulfillmentPercentage = totalQuantity > 0
        ? (fulfilledQuantity / totalQuantity * 100)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            _buildSummaryRow('Total Items', totalItems.toString()),
            const SizedBox(height: 12),
            _buildSummaryRow('Total Quantity', totalQuantity.toString()),
            const SizedBox(height: 12),
            _buildSummaryRow('Fulfilled Quantity', fulfilledQuantity.toString()),
            const SizedBox(height: 12),
            _buildSummaryRow('Fulfillment', '${fulfillmentPercentage.toStringAsFixed(1)}%'),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateStatusDialog(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Update Status'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_outlined),
                label: const Text('Back to Orders'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    final statusOptions = ['pending', 'fulfilled', 'cancelled'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Update Order Status - ${order.poNumber}'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current status: ${order.status[0].toUpperCase() + order.status.substring(1)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ...statusOptions.map((status) {
                  return ListTile(
                    title: Text(status[0].toUpperCase() + status.substring(1)),
                    leading: Radio<String>(
                      value: status,
                      groupValue: order.status,
                      onChanged: (value) {
                        if (value != null && value != order.status) {
                          context.read<CustomerOrderBloc>().add(
                            UpdateOrderStatus(order.id!, value),
                          );
                          Navigator.pop(dialogContext);
                          Navigator.pop(context); // Go back to list
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
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
