import 'package:equatable/equatable.dart';
import 'package:logistics/data/models/invoice_model.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {
  const InvoiceInitial();
}

class InvoiceLoading extends InvoiceState {
  const InvoiceLoading();
}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceModel> invoices;

  const InvoiceLoaded(this.invoices);

  @override
  List<Object> get props => [invoices];
}

class InvoiceDetailLoaded extends InvoiceState {
  final InvoiceModel invoice;

  const InvoiceDetailLoaded(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceSearchResults extends InvoiceState {
  final List<InvoiceModel> invoices;
  final String query;

  const InvoiceSearchResults(this.invoices, this.query);

  @override
  List<Object> get props => [invoices, query];
}

class InvoiceCreated extends InvoiceState {
  final InvoiceModel invoice;

  const InvoiceCreated(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceUpdated extends InvoiceState {
  final InvoiceModel invoice;

  const InvoiceUpdated(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceDeleted extends InvoiceState {
  final String invoiceId;

  const InvoiceDeleted(this.invoiceId);

  @override
  List<Object> get props => [invoiceId];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}

class InvoiceOperationSuccess extends InvoiceState {
  final String message;

  const InvoiceOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
