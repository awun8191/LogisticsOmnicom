import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_event.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_state.dart';
import 'package:logistics/presentation/screens/invoice/invoice_detail.mobile.dart';
import 'package:logistics/presentation/screens/invoice/create_invoice.mobile.dart';

class MobileInvoiceListPage extends StatefulWidget {
  const MobileInvoiceListPage({super.key});

  @override
  State<MobileInvoiceListPage> createState() => _MobileInvoiceListPageState();
}

class _MobileInvoiceListPageState extends State<MobileInvoiceListPage> {
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
            PopupMenuButton<String>(
              onSelected: (status) {
                setState(() {
                  _selectedStatus = status;
                });
                if (status == 'all') {
                  context.read<InvoiceBloc>().add(const LoadInvoices());
                } else {
                  context.read<InvoiceBloc>().add(LoadInvoicesByStatus(status));
                }
              },
              itemBuilder: (context) => _statusOptions.map((status) {
                return PopupMenuItem<String>(
                  value: status,
                  child: Row(
                    children: [
                      if (_selectedStatus == status) const Icon(Icons.check, size: 16),
                      if (_selectedStatus == status) const SizedBox(width: 8),
                      Text(_formatStatusText(status)),
                    ],
                  ),
                );
              }).toList(),
              child: const Icon(Icons.filter_list),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
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
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    context.read<InvoiceBloc>().add(SearchInvoices(query));
                  }
                },
              ),
            ),
            // Invoice list
            Expanded(
              child: BlocBuilder<InvoiceBloc, InvoiceState>(
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
                    return RefreshIndicator(
                      onRefresh: () async {
                        if (_selectedStatus == 'all') {
                          context.read<InvoiceBloc>().add(const LoadInvoices());
                        } else {
                          context.read<InvoiceBloc>().add(LoadInvoicesByStatus(_selectedStatus));
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return _buildInvoiceCard(context, invoice);
                        },
                      ),
                    );
                  }
                  if (state is InvoiceError) {
                    return _buildErrorState(state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MobileCreateInvoicePage()),
            ).then((_) {
              // Refresh invoices after creating new invoice
              if (_selectedStatus == 'all') {
                context.read<InvoiceBloc>().add(const LoadInvoices());
              } else {
                context.read<InvoiceBloc>().add(LoadInvoicesByStatus(_selectedStatus));
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, InvoiceModel invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MobileInvoiceDetailPage(invoice: invoice)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Invoice #${invoice.invoiceNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _buildStatusChip(invoice.displayStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                invoice.customerName,
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${(invoice.totalAmount ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Invoice Date: ${_formatDate(invoice.invoiceDate)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Due Date: ${_formatDate(invoice.dueDate)}',
                style: TextStyle(
                  color: invoice.isOverdue ? Colors.red[600] : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: invoice.isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${invoice.items.length} item${invoice.items.length != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
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
                  MaterialPageRoute(builder: (context) => const MobileCreateInvoicePage()),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
