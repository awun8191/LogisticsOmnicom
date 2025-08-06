import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/presentation/bloc/inventory_bloc/inventory_bloc.dart';
import 'package:logistics/presentation/screens/inventory/inventory_detail.desktop.dart';

class DesktopInventoryPage extends StatefulWidget {
  const DesktopInventoryPage({super.key});

  @override
  State<DesktopInventoryPage> createState() => _DesktopInventoryPageState();
}

class _DesktopInventoryPageState extends State<DesktopInventoryPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InventoryBloc>()..add(LoadInventory()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    _showAddInventoryDialog(context);
                  },
                  icon: const Icon(Icons.add),
                );
              }
            ),
          ],
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is InventoryLoaded) {
              if (state.inventory.isEmpty) {
                return const Center(
                  child: Text('No inventory items found. Add one to get started.'),
                );
              }
              return DataTable(
                columns: const [
                  DataColumn(label: Text('PO Number')),
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Created At')),
                ],
                rows: state.inventory.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.poNumber)),
                      DataCell(Text(item.itemName)),
                      DataCell(Text(item.quantity.toString())),
                      DataCell(Text(item.createdAt.toString())),
                    ],
                    onSelectChanged: (selected) {
                      if (selected != null && selected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryDetailDesktopPage(inventoryItem: item),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              );
            }
            if (state is InventoryError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showAddInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
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
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
