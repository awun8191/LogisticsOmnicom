import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/presentation/bloc/customer_order_bloc/customer_order_bloc.dart';
import 'package:logistics/presentation/screens/customer_orders/customer_order_detail.mobile.dart';
import 'package:logistics/presentation/screens/customer_orders/create_customer_order.mobile.dart';

class MobileCustomerOrdersListPage extends StatefulWidget {
  const MobileCustomerOrdersListPage({super.key});

  @override
  State<MobileCustomerOrdersListPage> createState() => _MobileCustomerOrdersListPageState();
}

class _MobileCustomerOrdersListPageState extends State<MobileCustomerOrdersListPage> {
  String _selectedStatus = 'all';
  final List<String> _statusOptions = ['all', 'pending', 'fulfilled', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CustomerOrderBloc>()..add(const LoadCustomerOrders()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Orders'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (status) {
                setState(() {
                  _selectedStatus = status;
                });
                if (status == 'all') {
                  context.read<CustomerOrderBloc>().add(const LoadCustomerOrders());
                } else {
                  context.read<CustomerOrderBloc>().add(LoadOrdersByStatus(status));
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
        body: BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
          builder: (context, state) {
            if (state is CustomerOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CustomerOrderLoaded) {
              if (state.orders.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  if (_selectedStatus == 'all') {
                    context.read<CustomerOrderBloc>().add(const LoadCustomerOrders());
                  } else {
                    context.read<CustomerOrderBloc>().add(LoadOrdersByStatus(_selectedStatus));
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
              );
            }
            if (state is CustomerOrderError) {
              return _buildErrorState(state.message);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MobileCreateCustomerOrderPage()),
            ).then((_) {
              // Refresh orders after creating new order
              if (_selectedStatus == 'all') {
                context.read<CustomerOrderBloc>().add(const LoadCustomerOrders());
              } else {
                context.read<CustomerOrderBloc>().add(LoadOrdersByStatus(_selectedStatus));
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, CustomerOrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MobileCustomerOrderDetailPage(order: order)),
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
                      order.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'PO: ${order.poNumber}',
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Order Date: ${_formatDate(order.orderDate)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Delivery Date: ${_formatDate(order.deliveryDate)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MobileCreateCustomerOrderPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Order'),
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
                  context.read<CustomerOrderBloc>().add(const LoadCustomerOrders());
                } else {
                  context.read<CustomerOrderBloc>().add(LoadOrdersByStatus(_selectedStatus));
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
}
