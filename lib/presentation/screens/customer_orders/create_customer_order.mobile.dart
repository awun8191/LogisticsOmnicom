import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/data/models/inventory_model.dart';
import 'package:logistics/presentation/bloc/customer_order_bloc/customer_order_bloc.dart';
import 'package:logistics/presentation/bloc/inventory_bloc/inventory_bloc.dart';

class MobileCreateCustomerOrderPage extends StatefulWidget {
  const MobileCreateCustomerOrderPage({super.key});

  @override
  State<MobileCreateCustomerOrderPage> createState() => _MobileCreateCustomerOrderPageState();
}

class _MobileCreateCustomerOrderPageState extends State<MobileCreateCustomerOrderPage> {
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
        appBar: AppBar(
          title: const Text('Create Customer Order'),
          actions: [
            TextButton(
              onPressed: _orderItems.isNotEmpty ? _createOrder : null,
              child: const Text('Create'),
            ),
          ],
        ),
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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomerInfoSection(),
                      const SizedBox(height: 24),
                      _buildOrderInfoSection(),
                      const SizedBox(height: 24),
                      _buildOrderItemsSection(),
                      const SizedBox(height: 24),
                      _buildOrderSummary(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Customer name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerAddressController,
              decoration: const InputDecoration(
                labelText: 'Customer Address',
                hintText: 'Enter customer address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _poNumberController,
              decoration: const InputDecoration(
                labelText: 'PO Number',
                hintText: 'Enter purchase order number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt_long),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'PO number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Order Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
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
                        prefixIcon: Icon(Icons.local_shipping),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _availableInventory.isNotEmpty ? _showAddItemDialog : null,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_orderItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('No items added yet', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
            else
              ...(_orderItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildOrderItemCard(item, index);
              })),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(CustomerOrderItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _orderItems.removeAt(index);
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quantity: ${item.requestedQuantity}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: Text(
                  'Unit Price: \$${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total: \$${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final totalAmount = _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final totalItems = _orderItems.length;
    final totalQuantity = _orderItems.fold(0, (sum, item) => sum + item.requestedQuantity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Total Items:'), Text('$totalItems')],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Total Quantity:'), Text('$totalQuantity')],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
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

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        InventoryModel? selectedInventory;
        int quantity = 1;
        double unitPrice = 0.0;
        final quantityController = TextEditingController(text: '1');
        final priceController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Order Item'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<InventoryModel>(
                      decoration: const InputDecoration(
                        labelText: 'Select Item',
                        border: OutlineInputBorder(),
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
                    TextFormField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: selectedInventory != null
                            ? 'Max: ${selectedInventory!.balance}'
                            : 'Enter quantity',
                        border: const OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Unit Price',
                        hintText: 'Enter unit price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedInventory != null &&
                        quantity > 0 &&
                        quantity <= selectedInventory!.balance &&
                        unitPrice > 0) {
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
                  child: const Text('Add'),
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
