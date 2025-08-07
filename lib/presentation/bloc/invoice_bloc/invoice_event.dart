import 'package:equatable/equatable.dart';
import 'package:logistics/data/models/invoice_model.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoices extends InvoiceEvent {
  const LoadInvoices();
}

class LoadInvoicesByStatus extends InvoiceEvent {
  final String status;

  const LoadInvoicesByStatus(this.status);

  @override
  List<Object> get props => [status];
}

class LoadInvoiceById extends InvoiceEvent {
  final String id;

  const LoadInvoiceById(this.id);

  @override
  List<Object> get props => [id];
}

class SearchInvoices extends InvoiceEvent {
  final String query;

  const SearchInvoices(this.query);

  @override
  List<Object> get props => [query];
}

class CreateInvoice extends InvoiceEvent {
  final InvoiceModel invoice;

  const CreateInvoice(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class CreateInvoiceFromOrder extends InvoiceEvent {
  final String customerOrderId;
  final String invoiceNumber;
  final DateTime dueDate;
  final double taxRate;
  final String? notes;

  const CreateInvoiceFromOrder({
    required this.customerOrderId,
    required this.invoiceNumber,
    required this.dueDate,
    this.taxRate = 0.0,
    this.notes,
  });

  @override
  List<Object?> get props => [customerOrderId, invoiceNumber, dueDate, taxRate, notes];
}

class UpdateInvoice extends InvoiceEvent {
  final InvoiceModel invoice;

  const UpdateInvoice(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class UpdateInvoiceStatus extends InvoiceEvent {
  final String id;
  final String status;

  const UpdateInvoiceStatus(this.id, this.status);

  @override
  List<Object> get props => [id, status];
}

class DeleteInvoice extends InvoiceEvent {
  final String id;

  const DeleteInvoice(this.id);

  @override
  List<Object> get props => [id];
}

class WatchInvoices extends InvoiceEvent {
  const WatchInvoices();
}

class WatchInvoicesByStatus extends InvoiceEvent {
  final String status;

  const WatchInvoicesByStatus(this.status);

  @override
  List<Object> get props => [status];
}
