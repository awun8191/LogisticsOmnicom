import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_event.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_state.dart';
import 'package:logistics/presentation/screens/invoice/invoice_detail.desktop.dart';
import 'package:logistics/presentation/screens/invoice/create_invoice.desktop.dart';

class DesktopInvoiceListPage extends StatefulWidget {
  const DesktopInvoiceListPage({super.key});

  @override
  State<DesktopInvoiceListPage> createState() => _DesktopInvoiceListPageState();
}

class _DesktopInvoiceListPageState extends State<DesktopInvoiceListPage> {
  String _selectedStatus = 'all';
  final List<String> _statusOptions = ['all', 'draft', 'sent', 'paid', 'overdue', 'cancelled'];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InvoiceBloc>()..add(const LoadInvoices()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invoices'),
          actions: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search invoices...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            if (_selectedStatus == 'all') {
                              context.read<InvoiceBloc>().add(const LoadInvoices());
                            } else {
                              context.read<InvoiceBloc>().add(
                                LoadInvoicesByStatus(_selectedStatus),
                              );
                            }
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    context.read<InvoiceBloc>().add(SearchInvoices(query));
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (status) {
                setState(() {
                  _selectedStatus = status!;
                });
                if (status == 'all') {
                  context.read<InvoiceBloc>().add(const LoadInvoices());
                } else {
                  context.read<InvoiceBloc>().add(LoadInvoicesByStatus(status!));
                }
              },
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(_formatStatusText(status)),
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DesktopCreateInvoicePage()),
                ).then((_) {
                  // Refresh invoices after creating new invoice
                  if (_selectedStatus == 'all') {
                    context.read<InvoiceBloc>().add(const LoadInvoices());
                  } else {
                    context.read<InvoiceBloc>().add(LoadInvoicesByStatus(_selectedStatus));
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Invoice'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, state) {
            if (state is InvoiceLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is InvoiceLoaded || state is InvoiceSearchResults) {
              final invoices = state is InvoiceLoaded
                  ? state.invoices
                  : (state as InvoiceSearchResults).invoices;

              if (invoices.isEmpty) {
                return _buildEmptyState();
              }
              return _buildInvoiceTable(invoices);
            }
            if (state is InvoiceError) {
              return _buildErrorState(state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInvoiceTable(List<InvoiceModel> invoices) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${invoices.length} invoice${invoices.length != 1 ? 's' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_selectedStatus == 'all') {
                        context.read<InvoiceBloc>().add(const LoadInvoices());
                      } else {
                        context.read<InvoiceBloc>().add(LoadInvoicesByStatus(_selectedStatus));
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Invoice #')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Invoice Date')),
                    DataColumn(label: Text('Due Date')),
                    DataColumn(label: Text('Items')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: invoices.map((invoice) => _buildDataRow(invoice)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(InvoiceModel invoice) {
    return DataRow(
      cells: [
        DataCell(Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(invoice.customerName)),
        DataCell(
          Text(
            '\$${(invoice.totalAmount ?? 0.0).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(_buildStatusChip(invoice.displayStatus)),
        DataCell(Text(_formatDate(invoice.invoiceDate))),
        DataCell(
          Text(
            _formatDate(invoice.dueDate),
            style: TextStyle(
              color: invoice.isOverdue ? Colors.red[600] : null,
              fontWeight: invoice.isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        DataCell(Text('${invoice.items.length} item${invoice.items.length != 1 ? 's' : ''}')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DesktopInvoiceDetailPage(invoice: invoice),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                tooltip: 'View Details',
              ),
              PopupMenuButton<String>(
                onSelected: (action) => _handleAction(context, action, invoice),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')],
                    ),
                  ),
                  if (invoice.status != 'paid')
                    const PopupMenuItem(
                      value: 'mark_paid',
                      child: Row(
                        children: [
                          Icon(Icons.payment, size: 16),
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
                          Icon(Icons.send, size: 16),
                          SizedBox(width: 8),
                          Text('Send Invoice'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 8),
                        Text('Export PDF'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        _formatStatusText(status),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No invoices yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first invoice to get started',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DesktopCreateInvoicePage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Invoice'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedStatus == 'all') {
                  context.read<InvoiceBloc>().add(const LoadInvoices());
                } else {
                  context.read<InvoiceBloc>().add(LoadInvoicesByStatus(_selectedStatus));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  void _handleAction(BuildContext context, String action, InvoiceModel invoice) {
    switch (action) {
      case 'edit':
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
