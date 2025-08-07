import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_event.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_state.dart';

class MobileInvoiceDetailPage extends StatelessWidget {
  final InvoiceModel invoice;

  const MobileInvoiceDetailPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InvoiceBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Invoice #${invoice.invoiceNumber}'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (action) => _handleAction(context, action),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')],
                  ),
                ),
                if (invoice.status != 'paid')
                  const PopupMenuItem(
                    value: 'mark_paid',
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 20),
                        SizedBox(width: 8),
                        Text('Mark as Paid'),
                      ],
                    ),
                  ),
                if (invoice.status == 'draft')
                  const PopupMenuItem(
                    value: 'send',
                    child: Row(
                      children: [
                        Icon(Icons.send, size: 20),
                        SizedBox(width: 8),
                        Text('Send Invoice'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 8),
                      Text('Export PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocListener<InvoiceBloc, InvoiceState>(
          listener: (context, state) {
            if (state is InvoiceOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.pop(context);
            } else if (state is InvoiceError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildCustomerInfo(),
                const SizedBox(height: 16),
                _buildInvoiceInfo(),
                const SizedBox(height: 16),
                _buildItemsList(),
                const SizedBox(height: 16),
                _buildTotals(),
                if (invoice.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _buildNotes(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatusChip(invoice.displayStatus),
            const Spacer(),
            if (invoice.isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', invoice.customerName),
            const SizedBox(height: 8),
            _buildInfoRow('Address', invoice.customerAddress),
            if (invoice.customerOrderId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Related Order', invoice.customerOrderId!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Invoice Number', invoice.invoiceNumber),
            const SizedBox(height: 8),
            _buildInfoRow('Invoice Date', _formatDate(invoice.invoiceDate)),
            const SizedBox(height: 8),
            _buildInfoRow('Due Date', _formatDate(invoice.dueDate)),
            const SizedBox(height: 8),
            _buildInfoRow('Created', _formatDate(invoice.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...invoice.items.map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                item.totalPrice != null ? '\$${item.totalPrice!.toStringAsFixed(2)}' : '-',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (item.description.isNotEmpty && item.description != item.itemName)
            Text(item.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: ${item.quantity}${item.unitPrice != null ? ' × \$${item.unitPrice!.toStringAsFixed(2)}' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              if (item.inventoryPoNumber?.isNotEmpty == true)
                Text(
                  'PO: ${item.inventoryPoNumber}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', invoice.subtotal ?? 0.0),
            if ((invoice.taxAmount ?? 0) > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow('Tax', invoice.taxAmount ?? 0.0),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildTotalRow('Total', invoice.totalAmount ?? 0.0, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(invoice.notes!, style: const TextStyle(fontSize: 14)),
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
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'draft':
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        break;
      case 'sent':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'paid':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'overdue':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'cancelled':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        // Navigate to edit screen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Edit functionality coming soon')));
        break;
      case 'mark_paid':
        _showConfirmDialog(
          context,
          'Mark as Paid',
          'Are you sure you want to mark this invoice as paid?',
          () => context.read<InvoiceBloc>().add(UpdateInvoiceStatus(invoice.id!, 'paid')),
        );
        break;
      case 'send':
        _showConfirmDialog(
          context,
          'Send Invoice',
          'Are you sure you want to send this invoice?',
          () => context.read<InvoiceBloc>().add(UpdateInvoiceStatus(invoice.id!, 'sent')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export functionality coming soon')));
        break;
      case 'delete':
        _showConfirmDialog(
          context,
          'Delete Invoice',
          'Are you sure you want to delete this invoice? This action cannot be undone.',
          () => context.read<InvoiceBloc>().add(DeleteInvoice(invoice.id!)),
          isDestructive: true,
        );
        break;
    }
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm, {
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: isDestructive ? TextButton.styleFrom(foregroundColor: Colors.red) : null,
            child: Text(isDestructive ? 'Delete' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}
