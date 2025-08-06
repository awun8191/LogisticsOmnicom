import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/presentation/bloc/inventory_bloc/inventory_bloc.dart';
import 'package:logistics/presentation/screens/inventory/order_detail.desktop.dart';

class InventoryDetailDesktopPage extends StatelessWidget {
  final InventoryModel inventoryItem;

  const InventoryDetailDesktopPage({super.key, required this.inventoryItem});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InventoryBloc>()..add(LoadDeliveries(inventoryItem.id!)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(inventoryItem.itemName),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PO Number: ${inventoryItem.poNumber}'),
              Text('Initial Quantity: ${inventoryItem.quantity}'),
              const SizedBox(height: 16),
              const Text(
                'Deliveries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is DeliveriesLoaded) {
                      if (state.deliveries.isEmpty) {
                        return const Center(
                          child: Text('No deliveries found for this item.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: state.deliveries.length,
                        itemBuilder: (context, index) {
                          final delivery = state.deliveries[index];
                          return ListTile(
                            title: Text('Delivery to: ${delivery.address}'),
                            subtitle: Text('Date: ${delivery.deliveryDate}'),
                            trailing: Text('Qty: ${delivery.quantity}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailDesktopPage(delivery: delivery),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    if (state is InventoryError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
