import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/presentation/bloc/customer_order_bloc/customer_order_bloc.dart';
import 'package:logistics/presentation/screens/customer_orders/customer_order_detail.desktop.dart';
import 'package:logistics/presentation/screens/customer_orders/create_customer_order.desktop.dart';

class DesktopCustomerOrdersListPage extends StatefulWidget {
  const DesktopCustomerOrdersListPage({super.key});

  @override
  State<DesktopCustomerOrdersListPage> createState() => _DesktopCustomerOrdersListPageState();
}

class _DesktopCustomerOrdersListPageState extends State<DesktopCustomerOrdersListPage> {
  String _searchQuery = '';
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusOptions = ['all', 'pending', 'fulfilled', 'cancelled'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CustomerOrderBloc>()..add(const LoadCustomerOrders()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildFiltersRow(),
              const SizedBox(height: 24),
              Expanded(child: _buildOrdersTable()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Customer Orders', style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[800],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey[200]),
      ),
      actions: [
        BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
          builder: (context, state) {
            return IconButton(
              onPressed: state is CustomerOrderLoading ? null : () => _refreshOrders(),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh orders',
            );
          },
        ),
        const SizedBox(width: 8),
        Builder(
          builder: (context) {
            return ElevatedButton.icon(
              onPressed: () => _showCreateOrderDialog(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
      builder: (context, state) {
        int totalOrders = 0;
        double totalValue = 0.0;
        int pendingOrders = 0;

        if (state is CustomerOrderLoaded) {
          totalOrders = state.orders.length;
          totalValue = state.orders.fold(0.0, (sum, order) => sum + order.totalAmount);
          pendingOrders = state.orders.where((order) => order.status == 'pending').length;
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Orders Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage customer orders and track fulfillment status',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _buildStatCard('Total Orders', totalOrders.toString(), Icons.shopping_cart_outlined),
            const SizedBox(width: 16),
            _buildStatCard('Pending', pendingOrders.toString(), Icons.pending_outlined),
            const SizedBox(width: 16),
            _buildStatCard(
              'Total Value',
              '\$${totalValue.toStringAsFixed(0)}',
              Icons.attach_money_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(child: _buildSearchBar()),
        const SizedBox(width: 16),
        _buildStatusFilter(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by customer name, PO number...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: Icon(Icons.clear_rounded, color: Colors.grey[400], size: 20),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          hint: const Text('Filter by status'),
          items: _statusOptions.map((status) {
            return DropdownMenuItem<String>(value: status, child: Text(_formatStatusText(status)));
          }).toList(),
          onChanged: (status) {
            if (status != null) {
              setState(() {
                _selectedStatus = status;
              });
              if (status == 'all') {
                context.read<CustomerOrderBloc>().add(const LoadCustomerOrders());
              } else {
                context.read<CustomerOrderBloc>().add(LoadOrdersByStatus(status));
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildOrdersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
        builder: (context, state) {
          if (state is CustomerOrderLoading) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator()),
            );
          }

          if (state is CustomerOrderLoaded) {
            final filteredOrders = _filterOrders(state.orders);

            if (state.orders.isEmpty) {
              return _buildEmptyState();
            }

            if (filteredOrders.isEmpty && _searchQuery.isNotEmpty) {
              return _buildNoSearchResults();
            }

            return _buildDataTable(filteredOrders);
          }

          if (state is CustomerOrderError) {
            return _buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<CustomerOrderModel> _filterOrders(List<CustomerOrderModel> orders) {
    if (_searchQuery.isEmpty) return orders;

    return orders.where((order) {
      return order.customerName.toLowerCase().contains(_searchQuery) ||
          order.poNumber.toLowerCase().contains(_searchQuery) ||
          order.customerAddress.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No customer orders yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first customer order to get started',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateOrderDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create First Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text('Try adjusting your search terms', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
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
              onPressed: () => _refreshOrders(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<CustomerOrderModel> orders) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowHeight: 56,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        columnSpacing: 24,
        headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
        columns: const [
          DataColumn(label: Text('Customer'), tooltip: 'Customer name'),
          DataColumn(label: Text('PO Number'), tooltip: 'Purchase order number'),
          DataColumn(label: Text('Status'), tooltip: 'Order status'),
          DataColumn(label: Text('Items'), numeric: true, tooltip: 'Number of items'),
          DataColumn(label: Text('Total Amount'), numeric: true, tooltip: 'Total order value'),
          DataColumn(label: Text('Order Date'), tooltip: 'Date order was placed'),
          DataColumn(label: Text('Actions')),
        ],
        rows: orders.map((order) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      order.customerAddress,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.poNumber,
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue[700]),
                  ),
                ),
              ),
              DataCell(_buildStatusChip(order.status)),
              DataCell(Text(order.items.length.toString())),
              DataCell(
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                Text(_formatDate(order.orderDate), style: TextStyle(color: Colors.grey[600])),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DesktopCustomerOrderDetailPage(order: order),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      tooltip: 'View details',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      onPressed: () => _showUpdateStatusDialog(context, order),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Update status',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        _formatStatusText(status),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showCreateOrderDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DesktopCreateCustomerOrderPage()),
    ).then((_) {
      _refreshOrders();
    });
  }

  void _showUpdateStatusDialog(BuildContext context, CustomerOrderModel order) {
    final statusOptions = ['pending', 'fulfilled', 'cancelled'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Update Order Status - ${order.poNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions.map((status) {
              return ListTile(
                title: Text(_formatStatusText(status)),
                leading: Radio<String>(
                  value: status,
                  groupValue: order.status,
                  onChanged: (value) {
                    if (value != null && value != order.status) {
                      context.read<CustomerOrderBloc>().add(UpdateOrderStatus(order.id!, value));
                      Navigator.pop(dialogContext);
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

  void _refreshOrders() {
    if (_selectedStatus == 'all') {
      context.read<CustomerOrderBloc>().add(const LoadCustomerOrders());
    } else {
      context.read<CustomerOrderBloc>().add(LoadOrdersByStatus(_selectedStatus));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }
}
