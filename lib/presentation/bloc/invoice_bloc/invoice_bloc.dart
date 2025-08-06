import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/domain/repositories/invoice_repository.dart';

// Events
abstract class InvoiceEvent {}

class CreateInvoiceEvent extends InvoiceEvent {
  final InvoiceModel invoice;

  CreateInvoiceEvent(this.invoice);
}

// States
abstract class InvoiceState {}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceSuccess extends InvoiceState {}

class InvoiceError extends InvoiceState {
  final String message;

  InvoiceError(this.message);
}

// BLoC
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository _invoiceRepository;

  InvoiceBloc({required InvoiceRepository invoiceRepository})
      : _invoiceRepository = invoiceRepository,
        super(InvoiceInitial()) {
    on<CreateInvoiceEvent>((event, emit) async {
      emit(InvoiceLoading());
      try {
        await _invoiceRepository.createInvoice(event.invoice);
        emit(InvoiceSuccess());
      } catch (e) {
        emit(InvoiceError(e.toString()));
      }
    });
  }
}
