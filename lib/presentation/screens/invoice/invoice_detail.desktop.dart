import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_event.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_state.dart';

class DesktopInvoiceDetailPage extends StatelessWidget {
  final InvoiceModel invoice;

  const DesktopInvoiceDetailPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InvoiceBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Invoice #${invoice.invoiceNumber}'),
          actions: [
            if (invoice.status == 'draft')
              ElevatedButton.icon(
                onPressed: () => _handleAction(context, 'send'),
                icon: const Icon(Icons.send),
                label: const Text('Send Invoice'),
              ),
            const SizedBox(width: 8),
            if (invoice.status != 'paid')
              ElevatedButton.icon(
                onPressed: () => _handleAction(context, 'mark_paid'),
                icon: const Icon(Icons.payment),
                label: const Text('Mark as Paid'),
              ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _handleAction(context, 'export'),
              icon: const Icon(Icons.download),
              label: const Text('Export PDF'),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (action) => _handleAction(context, action),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [Icon(Icons.copy, size: 20), SizedBox(width: 8), Text('Duplicate')],
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
            const SizedBox(width: 16),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInvoiceHeader(),
                      const SizedBox(height: 32),
                      _buildCustomerInfo(),
                      const SizedBox(height: 32),
                      _buildItemsTable(),
                      const SizedBox(height: 32),
                      _buildTotals(),
                      if (invoice.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: 32),
                        _buildNotes(),
                      ],
                    ],
                  ),
                ),
              ),
              // Sidebar
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(left: BorderSide(color: Colors.grey[300]!)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 24),
                      _buildInvoiceDetails(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INVOICE',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            Text(
              '#${invoice.invoiceNumber}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (invoice.isOverdue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Text(
              'OVERDUE',
              style: TextStyle(color: Colors.red[800], fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill To',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              invoice.customerName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(invoice.customerAddress, style: const TextStyle(fontSize: 16)),
            if (invoice.customerOrderId != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Related Order: ${invoice.customerOrderId}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    _buildTableHeader('Description'),
                    _buildTableHeader('Qty'),
                    _buildTableHeader('Unit Price'),
                    _buildTableHeader('Total'),
                  ],
                ),
                ...invoice.items.map((item) => _buildItemRow(item)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  TableRow _buildItemRow(InvoiceItem item) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (item.description.isNotEmpty && item.description != item.itemName)
                Text(item.description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              if (item.inventoryPoNumber?.isNotEmpty == true)
                Text(
                  'PO: ${item.inventoryPoNumber}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Text(item.quantity.toString())),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(item.unitPrice != null ? '\$${item.unitPrice!.toStringAsFixed(2)}' : '-'),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            item.totalPrice != null ? '\$${item.totalPrice!.toStringAsFixed(2)}' : '-',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTotals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 300,
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
              ],
            ),
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
        padding: const EdgeInsets.all(24),
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

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildStatusChip(invoice.displayStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Invoice Date', _formatDate(invoice.invoiceDate)),
            _buildDetailRow('Due Date', _formatDate(invoice.dueDate)),
            _buildDetailRow('Created', _formatDate(invoice.createdAt)),
            _buildDetailRow('Items', '${invoice.items.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleAction(null, 'edit'),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Invoice'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleAction(null, 'duplicate'),
                icon: const Icon(Icons.copy),
                label: const Text('Duplicate'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleAction(null, 'export'),
                icon: const Icon(Icons.download),
                label: const Text('Export PDF'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
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

  void _handleAction(BuildContext? context, String action) {
    final ctx = context ?? this.context;
    if (ctx == null) return;

    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text('Edit functionality coming soon')));
        break;
      case 'mark_paid':
        _showConfirmDialog(
          ctx,
          'Mark as Paid',
          'Are you sure you want to mark this invoice as paid?',
          () => ctx.read<InvoiceBloc>().add(UpdateInvoiceStatus(invoice.id!, 'paid')),
        );
        break;
      case 'send':
        _showConfirmDialog(
          ctx,
          'Send Invoice',
          'Are you sure you want to send this invoice?',
          () => ctx.read<InvoiceBloc>().add(UpdateInvoiceStatus(invoice.id!, 'sent')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text('Export functionality coming soon')));
        break;
      case 'duplicate':
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text('Duplicate functionality coming soon')));
        break;
      case 'delete':
        _showConfirmDialog(
          ctx,
          'Delete Invoice',
          'Are you sure you want to delete this invoice? This action cannot be undone.',
          () => ctx.read<InvoiceBloc>().add(DeleteInvoice(invoice.id!)),
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

  BuildContext? get context {
    // This is a workaround to get context in static methods
    // In a real app, you'd pass context properly
    return null;
  }
}
