import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InventoryBloc>()..add(LoadInventory()),
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
              _buildSearchBar(),
              const SizedBox(height: 24),
              Expanded(child: _buildInventoryTable()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Inventory Management', style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[800],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey[200]),
      ),
      actions: [
        BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            return IconButton(
              onPressed: state is InventoryLoading
                  ? null
                  : () => context.read<InventoryBloc>().add(LoadInventory()),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh inventory',
            );
          },
        ),
        const SizedBox(width: 8),
        Builder(
          builder: (context) {
            return ElevatedButton.icon(
              onPressed: () => _showAddInventoryDialog(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Item'),
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
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        int totalItems = 0;
        int totalQuantity = 0;

        if (state is InventoryLoaded) {
          totalItems = state.inventory.length;
          totalQuantity = state.inventory.fold(0, (sum, item) => sum + item.quantity);
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventory Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your inventory items and track quantities',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _buildStatCard('Total Items', totalItems.toString(), Icons.inventory_2_outlined),
            const SizedBox(width: 16),
            _buildStatCard('Total Quantity', totalQuantity.toString(), Icons.numbers_outlined),
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
                hintText: 'Search by PO number, item name...',
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

  Widget _buildInventoryTable() {
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
      child: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator()),
            );
          }

          if (state is InventoryLoaded) {
            final filteredInventory = _filterInventory(state.inventory);

            if (state.inventory.isEmpty) {
              return _buildEmptyState();
            }

            if (filteredInventory.isEmpty && _searchQuery.isNotEmpty) {
              return _buildNoSearchResults();
            }

            return _buildDataTable(filteredInventory);
          }

          if (state is InventoryError) {
            return _buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<InventoryModel> _filterInventory(List<InventoryModel> inventory) {
    if (_searchQuery.isEmpty) return inventory;

    return inventory.where((item) {
      return item.poNumber.toLowerCase().contains(_searchQuery) ||
          item.itemName.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No inventory items yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Get started by adding your first inventory item',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddInventoryDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Item'),
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
              onPressed: () => context.read<InventoryBloc>().add(LoadInventory()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<InventoryModel> inventory) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowHeight: 56,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        columnSpacing: 24,
        headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
        columns: const [
          DataColumn(label: Text('PO Number'), tooltip: 'Purchase Order Number'),
          DataColumn(label: Text('Item Name'), tooltip: 'Product or item name'),
          DataColumn(label: Text('Quantity'), numeric: true, tooltip: 'Available quantity'),
          DataColumn(label: Text('Created'), tooltip: 'Date added to inventory'),
          DataColumn(label: Text('Actions')),
        ],
        rows: inventory.map((item) {
          return DataRow(
            cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.poNumber,
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue[700]),
                  ),
                ),
              ),
              DataCell(Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.quantity > 10
                        ? Colors.green[50]
                        : item.quantity > 0
                        ? Colors.orange[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.quantity.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: item.quantity > 10
                          ? Colors.green[700]
                          : item.quantity > 0
                          ? Colors.orange[700]
                          : Colors.red[700],
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(_formatDate(item.createdAt), style: TextStyle(color: Colors.grey[600])),
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
                            builder: (context) => InventoryDetailDesktopPage(inventoryItem: item),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      tooltip: 'View details',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      onPressed: () => _showEditInventoryDialog(context, item),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit item',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddInventoryDialog(BuildContext context) {
    _showInventoryDialog(context, null);
  }

  void _showEditInventoryDialog(BuildContext context, InventoryModel item) {
    _showInventoryDialog(context, item);
  }

  void _showInventoryDialog(BuildContext context, InventoryModel? item) {
    final isEditing = item != null;
    final poNumberController = TextEditingController(text: item?.poNumber ?? '');
    final itemNameController = TextEditingController(text: item?.itemName ?? '');
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Inventory Item' : 'Add New Inventory Item'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: poNumberController,
                    decoration: const InputDecoration(
                      labelText: 'PO Number',
                      hintText: 'Enter purchase order number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'PO Number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'Enter item name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Item name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantity is required';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity < 0) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final inventory = InventoryModel(
                    poNumber: poNumberController.text.trim(),
                    itemName: itemNameController.text.trim(),
                    quantity: int.parse(quantityController.text),
                    createdAt: item?.createdAt ?? DateTime.now(),
                  );

                  if (isEditing) {
                    // context.read<InventoryBloc>().add(UpdateInventory(inventory));
                  } else {
                    context.read<InventoryBloc>().add(AddInventory(inventory));
                  }

                  Navigator.pop(dialogContext);
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    ).then((_) {
      poNumberController.dispose();
      itemNameController.dispose();
      quantityController.dispose();
    });
  }
}
