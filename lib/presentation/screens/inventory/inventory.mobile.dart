import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/delivery_model.dart';
import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/presentation/bloc/inventory_bloc/inventory_bloc.dart';

class MobileInventoryPage extends StatefulWidget {
  const MobileInventoryPage({super.key});

  @override
  State<MobileInventoryPage> createState() => _MobileInventoryPageState();
}

class _MobileInventoryPageState extends State<MobileInventoryPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InventoryBloc>()..add(LoadInventory()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is InventoryLoaded) {
              return ListView.builder(
                itemCount: state.inventory.length,
                itemBuilder: (context, index) {
                  final item = state.inventory[index];
                  return ListTile(
                    title: Text(item.itemName),
                    subtitle: Text('PO: ${item.poNumber}'),
                    trailing: Text('Qty: ${item.quantity}'),
                    onTap: () {
                      _showCreateDeliveryDialog(context, item);
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddInventoryDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        final poNumberController = TextEditingController();
        final itemNameController = TextEditingController();
        final quantityController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Inventory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: poNumberController,
                decoration: const InputDecoration(labelText: 'PO Number'),
              ),
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final inventory = InventoryModel(
                  poNumber: poNumberController.text,
                  itemName: itemNameController.text,
                  quantity: int.parse(quantityController.text),
                  createdAt: DateTime.now(),
                );
                context.read<InventoryBloc>().add(AddInventory(inventory));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDeliveryDialog(BuildContext context, InventoryModel item) {
    showDialog(
      context: context,
      builder: (_) {
        final quantityController = TextEditingController();
        final addressController = TextEditingController();
        return AlertDialog(
          title: const Text('Create Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Item: ${item.itemName}'),
              Text('Available Quantity: ${item.quantity}'),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final deliveryDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (deliveryDate != null) {
                  final delivery = DeliveryModel(
                    inventoryId: item.id!,
                    quantity: int.parse(quantityController.text),
                    orderDate: DateTime.now(),
                    deliveryDate: deliveryDate,
                    address: addressController.text,
                  );
                  context.read<InventoryBloc>().add(CreateDelivery(delivery));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
