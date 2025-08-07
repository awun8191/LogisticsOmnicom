import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/presentation/bloc/customer_order_bloc/customer_order_bloc.dart';
import 'package:logistics/presentation/bloc/inventory_bloc/inventory_bloc.dart';

class DesktopCreateCustomerOrderPage extends StatefulWidget {
  const DesktopCreateCustomerOrderPage({super.key});

  @override
  State<DesktopCreateCustomerOrderPage> createState() => _DesktopCreateCustomerOrderPageState();
}

class _DesktopCreateCustomerOrderPageState extends State<DesktopCreateCustomerOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _poNumberController = TextEditingController();

  DateTime _orderDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));

  final List<CustomerOrderItem> _orderItems = [];
  List<InventoryModel> _availableInventory = [];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _poNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<CustomerOrderBloc>()),
        BlocProvider(create: (context) => sl<InventoryBloc>()..add(LoadInventory())),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        body: BlocListener<CustomerOrderBloc, CustomerOrderState>(
          listener: (context, state) {
            if (state is CustomerOrderCreated) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Order created successfully!')));
              Navigator.pop(context);
            } else if (state is CustomerOrderError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            }
          },
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, inventoryState) {
              if (inventoryState is InventoryLoaded) {
                _availableInventory = inventoryState.inventory
                    .where((item) => item.balance > 0)
                    .toList();
              }

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildCustomerInfoSection(),
                            const SizedBox(height: 24),
                            _buildOrderInfoSection(),
                            const SizedBox(height: 24),
                            _buildOrderItemsSection(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildOrderSummary(),
                          const SizedBox(height: 24),
                          _buildActionButtons(context),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Create Customer Order', style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[800],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey[200]),
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      hintText: 'Enter customer name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Customer name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerAddressController,
              decoration: const InputDecoration(
                labelText: 'Customer Address',
                hintText: 'Enter customer address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Customer address is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _poNumberController,
                    decoration: const InputDecoration(
                      labelText: 'PO Number',
                      hintText: 'Enter purchase order number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'PO number is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Order Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(_formatDate(_orderDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Delivery Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                      ),
                      child: Text(_formatDate(_deliveryDate)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _availableInventory.isNotEmpty ? _showAddItemDialog : null,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_orderItems.isEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No items added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click "Add Item" to start building your order',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildItemsDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 56,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        columnSpacing: 24,
        headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
        columns: const [
          DataColumn(label: Text('Item Name')),
          DataColumn(label: Text('Inventory PO')),
          DataColumn(label: Text('Quantity'), numeric: true),
          DataColumn(label: Text('Unit Price'), numeric: true),
          DataColumn(label: Text('Total Price'), numeric: true),
          DataColumn(label: Text('Actions')),
        ],
        rows: _orderItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return DataRow(
            cells: [
              DataCell(Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.inventoryPoNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(Text(item.requestedQuantity.toString())),
              DataCell(Text('\$${item.unitPrice.toStringAsFixed(2)}')),
              DataCell(
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                IconButton(
                  onPressed: () {
                    setState(() {
                      _orderItems.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove item',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final totalAmount = _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final totalItems = _orderItems.length;
    final totalQuantity = _orderItems.fold(0, (sum, item) => sum + item.requestedQuantity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            _buildSummaryRow('Total Items', totalItems.toString()),
            const SizedBox(height: 12),
            _buildSummaryRow('Total Quantity', totalQuantity.toString()),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _orderItems.isNotEmpty ? _createOrder : null,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Create Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        InventoryModel? selectedInventory;
        int quantity = 1;
        double unitPrice = 0.0;
        final quantityController = TextEditingController(text: '1');
        final priceController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Order Item'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<InventoryModel>(
                        decoration: const InputDecoration(
                          labelText: 'Select Item',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        value: selectedInventory,
                        items: _availableInventory.map((inventory) {
                          return DropdownMenuItem<InventoryModel>(
                            value: inventory,
                            child: Text('${inventory.itemName} (Available: ${inventory.balance})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedInventory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an item';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                hintText: selectedInventory != null
                                    ? 'Max: ${selectedInventory!.balance}'
                                    : 'Enter quantity',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.numbers_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (value) {
                                quantity = int.tryParse(value) ?? 1;
                              },
                              validator: (value) {
                                final qty = int.tryParse(value ?? '');
                                if (qty == null || qty <= 0) {
                                  return 'Please enter a valid quantity';
                                }
                                if (selectedInventory != null && qty > selectedInventory!.balance) {
                                  return 'Quantity exceeds available balance';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: priceController,
                              decoration: const InputDecoration(
                                labelText: 'Unit Price',
                                hintText: 'Enter unit price',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money_outlined),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                unitPrice = double.tryParse(value) ?? 0.0;
                              },
                              validator: (value) {
                                final price = double.tryParse(value ?? '');
                                if (price == null || price <= 0) {
                                  return 'Please enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      if (selectedInventory != null && quantity > 0 && unitPrice > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Price:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '\$${(quantity * unitPrice).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final orderItem = CustomerOrderItem(
                        itemName: selectedInventory!.itemName,
                        requestedQuantity: quantity,
                        fulfilledQuantity: 0,
                        inventoryPoNumber: selectedInventory!.poNumber,
                        unitPrice: unitPrice,
                        totalPrice: quantity * unitPrice,
                      );

                      setState(() {
                        _orderItems.add(orderItem);
                      });

                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isOrderDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isOrderDate ? _orderDate : _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isOrderDate) {
          _orderDate = picked;
          // Ensure delivery date is not before order date
          if (_deliveryDate.isBefore(_orderDate)) {
            _deliveryDate = _orderDate.add(const Duration(days: 1));
          }
        } else {
          _deliveryDate = picked;
        }
      });
    }
  }

  void _createOrder() {
    if (_formKey.currentState!.validate() && _orderItems.isNotEmpty) {
      final totalAmount = _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      final order = CustomerOrderModel(
        customerName: _customerNameController.text.trim(),
        customerAddress: _customerAddressController.text.trim(),
        poNumber: _poNumberController.text.trim(),
        orderDate: _orderDate,
        deliveryDate: _deliveryDate,
        items: _orderItems,
        totalAmount: totalAmount,
        status: 'pending',
      );

      context.read<CustomerOrderBloc>().add(CreateCustomerOrder(order));
    } else if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add at least one item to the order')));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
