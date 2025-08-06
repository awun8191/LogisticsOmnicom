import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';

class MobileInvoicePage extends StatefulWidget {
  const MobileInvoicePage({super.key});

  @override
  _MobileInvoicePageState createState() => _MobileInvoicePageState();
}

class _MobileInvoicePageState extends State<MobileInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController();

  final List<InvoiceItem> _items = [];

  void _addItem() {
    if (_itemNameController.text.isNotEmpty && _itemQuantityController.text.isNotEmpty) {
      setState(() {
        _items.add(InvoiceItem(
          sn: (_items.length + 1).toString(),
          name: _itemNameController.text,
          quantity: int.parse(_itemQuantityController.text),
        ));
        _itemNameController.clear();
        _itemQuantityController.clear();
      });
    }
  }

  void _createInvoice() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final invoice = InvoiceModel(
        address: _addressController.text,
        poNumber: _poNumberController.text,
        orderDate: DateTime.now(),
        deliveryDate: DateTime.now(), // Or use a date picker
        totalQuantity: _items.fold(0, (sum, item) => sum + item.quantity),
        items: _items,
      );
      context.read<InvoiceBloc>().add(CreateInvoiceEvent(invoice));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
      ),
      body: BlocListener<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invoice created successfully')),
            );
            _formKey.currentState!.reset();
            setState(() {
              _items.clear();
            });
          } else if (state is InvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
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
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Shipping Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the shipping address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _poNumberController,
                    decoration: const InputDecoration(labelText: 'PO Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the PO number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Invoice Items'),
                  TextFormField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  TextFormField(
                    controller: _itemQuantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: _addItem,
                    child: const Text('Add Item'),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('SN')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Quantity')),
                      ],
                      rows: _items
                          .map((item) => DataRow(cells: [
                                DataCell(Text(item.sn)),
                                DataCell(Text(item.name)),
                                DataCell(Text(item.quantity.toString())),
                              ]))
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
