import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/core/di/injection_container.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_event.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_state.dart';
import 'package:logistics/presentation/bloc/customer_order_bloc/customer_order_bloc.dart';

class DesktopCreateInvoicePage extends StatefulWidget {
  final CustomerOrderModel? customerOrder;

  const DesktopCreateInvoicePage({super.key, this.customerOrder});

  @override
  State<DesktopCreateInvoicePage> createState() => _DesktopCreateInvoicePageState();
}

class _DesktopCreateInvoicePageState extends State<DesktopCreateInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  double _taxRate = 0.0;

  List<InvoiceItem> _items = [];
  CustomerOrderModel? _selectedOrder;
  bool _isFromOrder = false;

  @override
  void initState() {
    super.initState();
    if (widget.customerOrder != null) {
      _selectedOrder = widget.customerOrder;
      _isFromOrder = true;
      _populateFromOrder();
    }
    _generateInvoiceNumber();
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    _invoiceNumberController.text =
        'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  void _populateFromOrder() {
    if (_selectedOrder != null) {
      _customerNameController.text = _selectedOrder!.customerName;
      _customerAddressController.text = _selectedOrder!.customerAddress;

      _items = _selectedOrder!.items
          .map(
            (item) => InvoiceItem(
              itemName: item.itemName,
              description: item.itemName,
              quantity: item.fulfilledQuantity > 0
                  ? item.fulfilledQuantity
                  : item.requestedQuantity,
              unitPrice: item.unitPrice,
              totalPrice: item.totalPrice,
              inventoryPoNumber: item.inventoryPoNumber,
            ),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<InvoiceBloc>()),
        BlocProvider(create: (context) => sl<CustomerOrderBloc>()..add(const LoadCustomerOrders())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Invoice'),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: _saveInvoice, child: const Text('Save Invoice')),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocListener<InvoiceBloc, InvoiceState>(
          listener: (context, state) {
            if (state is InvoiceCreated) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Invoice created successfully')));
              Navigator.pop(context);
            } else if (state is InvoiceError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          child: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main form
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInvoiceTypeSelector(),
                        const SizedBox(height: 24),
                        if (_isFromOrder) _buildOrderSelector(),
                        if (_isFromOrder) const SizedBox(height: 24),
                        _buildInvoiceDetails(),
                        const SizedBox(height: 24),
                        _buildCustomerInfo(),
                        const SizedBox(height: 24),
                        _buildItemsSection(),
                        const SizedBox(height: 24),
                        _buildNotesSection(),
                      ],
                    ),
                  ),
                ),
                // Sidebar
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(left: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDatesSection(),
                        const SizedBox(height: 24),
                        _buildTaxSection(),
                        const SizedBox(height: 24),
                        _buildTotalsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invoice Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('From Customer Order'),
                    subtitle: const Text('Create invoice from existing order'),
                    value: true,
                    groupValue: _isFromOrder,
                    onChanged: (value) {
                      setState(() {
                        _isFromOrder = value!;
                        if (_isFromOrder && _selectedOrder != null) {
                          _populateFromOrder();
                        } else {
                          _clearForm();
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Manual Invoice'),
                    subtitle: const Text('Create invoice manually'),
                    value: false,
                    groupValue: _isFromOrder,
                    onChanged: (value) {
                      setState(() {
                        _isFromOrder = value!;
                        if (!_isFromOrder) {
                          _clearForm();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Customer Order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
              builder: (context, state) {
                if (state is CustomerOrderLoaded) {
                  final availableOrders = state.orders
                      .where((order) => order.status == 'fulfilled' || order.status == 'pending')
                      .toList();

                  return DropdownButtonFormField<CustomerOrderModel>(
                    value: _selectedOrder,
                    decoration: const InputDecoration(
                      labelText: 'Customer Order',
                      border: OutlineInputBorder(),
                    ),
                    items: availableOrders.map((order) {
                      return DropdownMenuItem(
                        value: order,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'PO: ${order.poNumber} - \$${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (order) {
                      setState(() {
                        _selectedOrder = order;
                        if (order != null) {
                          _populateFromOrder();
                        }
                      });
                    },
                    validator: (value) {
                      if (_isFromOrder && value == null) {
                        return 'Please select a customer order';
                      }
                      return null;
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter invoice number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isFromOrder,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter customer name';
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
                border: OutlineInputBorder(),
              ),
              enabled: !_isFromOrder,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter customer address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (!_isFromOrder)
                  ElevatedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('No items added yet')),
              )
            else
              _buildItemsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(0.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            _buildTableHeader('Description'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Unit Price'),
            _buildTableHeader('Total'),
            _buildTableHeader(''),
          ],
        ),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildItemTableRow(item, index);
        }),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  TableRow _buildItemTableRow(InvoiceItem item, int index) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (item.description.isNotEmpty && item.description != item.itemName)
                Text(item.description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              if (item.inventoryPoNumber?.isNotEmpty == true)
                Text(
                  'PO: ${item.inventoryPoNumber}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Text(item.quantity.toString())),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(item.unitPrice != null ? '\$${item.unitPrice!.toStringAsFixed(2)}' : '-'),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            item.totalPrice != null ? '\$${item.totalPrice!.toStringAsFixed(2)}' : '-',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: !_isFromOrder
              ? IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Invoice Date'),
              subtitle: Text(_formatDate(_invoiceDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            const Divider(),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(_formatDate(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tax', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: (_taxRate * 100).toString(),
              decoration: const InputDecoration(
                labelText: 'Tax Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _taxRate = (double.tryParse(value) ?? 0) / 100;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
    final taxAmount = subtotal * _taxRate;
    final total = subtotal + taxAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Totals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTotalRow('Subtotal', subtotal),
            if (taxAmount > 0) _buildTotalRow('Tax', taxAmount),
            const Divider(),
            _buildTotalRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onItemAdded: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _clearForm() {
    _customerNameController.clear();
    _customerAddressController.clear();
    _notesController.clear();
    _items.clear();
    _selectedOrder = null;
  }

  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate ? _invoiceDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = date;
        } else {
          _dueDate = date;
        }
      });
    }
  }

  void _saveInvoice() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    if (_isFromOrder && _selectedOrder != null) {
      // Create invoice from order
      context.read<InvoiceBloc>().add(
        CreateInvoiceFromOrder(
          customerOrderId: _selectedOrder!.id!,
          invoiceNumber: _invoiceNumberController.text,
          dueDate: _dueDate,
          taxRate: _taxRate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        ),
      );
    } else {
      // Create manual invoice
      final subtotal = _items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
      final taxAmount = subtotal * _taxRate;
      final totalAmount = subtotal + taxAmount;
      final now = DateTime.now();

      final invoice = InvoiceModel(
        invoiceNumber: _invoiceNumberController.text,
        customerName: _customerNameController.text,
        customerAddress: _customerAddressController.text,
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        items: _items,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        status: 'draft',
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: now,
        updatedAt: now,
      );

      context.read<InvoiceBloc>().add(CreateInvoice(invoice));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(InvoiceItem) onItemAdded;

  const _AddItemDialog({required this.onItemAdded});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Unit Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final quantity = int.parse(_quantityController.text);
              final unitPrice = double.parse(_unitPriceController.text);
              final item = InvoiceItem(
                itemName: _nameController.text,
                description: _descriptionController.text.isEmpty
                    ? _nameController.text
                    : _descriptionController.text,
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: quantity * unitPrice,
              );
              widget.onItemAdded(item);
              Navigator.pop(context);
            }
          },
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }
}
