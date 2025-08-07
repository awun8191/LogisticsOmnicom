import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_event.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_state.dart';

class MobileInvoicePage extends StatefulWidget {
  const MobileInvoicePage({super.key});

  @override
  _MobileInvoicePageState createState() => _MobileInvoicePageState();
}

class _MobileInvoicePageState extends State<MobileInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemPoController = TextEditingController();

  DateTime? _dueDate;

  final List<InvoiceItem> _items = [];

  void _addItem() {
    if (_itemNameController.text.isNotEmpty &&
        _itemQuantityController.text.isNotEmpty &&
        _itemPoController.text.isNotEmpty) {
      final int quantity = int.tryParse(_itemQuantityController.text) ?? 0;
      const double unitPrice = 0.0;
      const double totalPrice = 0.0;
      setState(() {
        _items.add(
          InvoiceItem(
            itemName: _itemNameController.text,
            description: _itemDescriptionController.text.isEmpty
                ? _itemNameController.text
                : _itemDescriptionController.text,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
            inventoryPoNumber: _itemPoController.text,
          ),
        );
        _itemNameController.clear();
        _itemDescriptionController.clear();
        _itemQuantityController.clear();
        _itemPoController.clear();
      });
    }
  }

  void _createInvoice() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final now = DateTime.now();
      const double subtotal = 0.0;
      const double taxAmount = 0.0;
      const double totalAmount = 0.0;

      final invoice = InvoiceModel(
        invoiceNumber: _invoiceNumberController.text,
        customerName: _customerNameController.text,
        customerAddress: _customerAddressController.text,
        customerOrderId: null,
        invoiceDate: now,
        dueDate: _dueDate ?? now.add(const Duration(days: 30)),
        items: _items,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        status: 'draft',
        notes: null,
        createdAt: now,
        updatedAt: now,
      );
      context.read<InvoiceBloc>().add(CreateInvoice(invoice));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: BlocListener<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceCreated) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Invoice created successfully')));
            _formKey.currentState!.reset();
            setState(() {
              _items.clear();
            });
          } else if (state is InvoiceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(labelText: 'Customer Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the customer name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customerAddressController,
                    decoration: const InputDecoration(labelText: 'Customer Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the customer address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _invoiceNumberController,
                    decoration: const InputDecoration(labelText: 'Invoice Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the invoice number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  InputDatePickerFormField(
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    fieldLabelText: 'Due Date',
                    onDateSubmitted: (date) => _dueDate = date,
                    onDateSaved: (date) => _dueDate = date,
                  ),
                  const SizedBox(height: 20),
                  const Text('Invoice Items'),
                  TextFormField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _itemDescriptionController,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                  ),
                  TextFormField(
                    controller: _itemQuantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _itemPoController,
                    decoration: const InputDecoration(labelText: 'PO Number (lot)'),
                  ),
                  ElevatedButton(onPressed: _addItem, child: const Text('Add Item')),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Item')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('PO Number')),
                      ],
                      rows: _items
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item.itemName)),
                                DataCell(Text(item.description)),
                                DataCell(Text(item.quantity.toString())),
                                DataCell(Text(item.inventoryPoNumber ?? '-')),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<InvoiceBloc, InvoiceState>(
                    builder: (context, state) {
                      if (state is InvoiceLoading) {
                        return const CircularProgressIndicator();
                      }
                      return ElevatedButton(
                        onPressed: _createInvoice,
                        child: const Text('Create Invoice'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
