import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/domain/repositories/invoice_repository.dart';
import 'package:logistics/domain/repositories/customer_order_repository.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository _invoiceRepository;
  final CustomerOrderRepository _customerOrderRepository;
  StreamSubscription<List<InvoiceModel>>? _invoicesSubscription;

  InvoiceBloc({
    required InvoiceRepository invoiceRepository,
    required CustomerOrderRepository customerOrderRepository,
  }) : _invoiceRepository = invoiceRepository,
       _customerOrderRepository = customerOrderRepository,
       super(const InvoiceInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<LoadInvoicesByStatus>(_onLoadInvoicesByStatus);
    on<LoadInvoiceById>(_onLoadInvoiceById);
    on<SearchInvoices>(_onSearchInvoices);
    on<CreateInvoice>(_onCreateInvoice);
    on<CreateInvoiceFromOrder>(_onCreateInvoiceFromOrder);
    on<UpdateInvoice>(_onUpdateInvoice);
    on<UpdateInvoiceStatus>(_onUpdateInvoiceStatus);
    on<DeleteInvoice>(_onDeleteInvoice);
    on<WatchInvoices>(_onWatchInvoices);
    on<WatchInvoicesByStatus>(_onWatchInvoicesByStatus);
  }

  Future<void> _onLoadInvoices(LoadInvoices event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      final invoices = await _invoiceRepository.getAllInvoices();
      emit(InvoiceLoaded(invoices));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onLoadInvoicesByStatus(
    LoadInvoicesByStatus event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());
    try {
      final invoices = await _invoiceRepository.getInvoicesByStatus(event.status);
      emit(InvoiceLoaded(invoices));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceById(LoadInvoiceById event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      final invoice = await _invoiceRepository.getInvoiceById(event.id);
      if (invoice != null) {
        emit(InvoiceDetailLoaded(invoice));
      } else {
        emit(const InvoiceError('Invoice not found'));
      }
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onSearchInvoices(SearchInvoices event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      final invoices = await _invoiceRepository.searchInvoices(event.query);
      emit(InvoiceSearchResults(invoices, event.query));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onCreateInvoice(CreateInvoice event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      await _invoiceRepository.createInvoice(event.invoice);
      emit(InvoiceCreated(event.invoice));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onCreateInvoiceFromOrder(
    CreateInvoiceFromOrder event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());
    try {
      // Get the customer order
      final orders = await _customerOrderRepository.getAllCustomerOrders();
      final order = orders.firstWhere((o) => o.id == event.customerOrderId);

      // Calculate totals
      final subtotal = order.totalAmount;
      final taxAmount = subtotal * event.taxRate;
      final totalAmount = subtotal + taxAmount;

      // Convert order items to invoice items
      final invoiceItems = order.items
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

      final now = DateTime.now();
      final invoice = InvoiceModel(
        invoiceNumber: event.invoiceNumber,
        customerName: order.customerName,
        customerAddress: order.customerAddress,
        customerOrderId: order.id,
        invoiceDate: now,
        dueDate: event.dueDate,
        items: invoiceItems,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        status: 'draft',
        notes: event.notes,
        createdAt: now,
        updatedAt: now,
      );

      await _invoiceRepository.createInvoice(invoice);

      // Update customer order status to invoiced
      final updatedOrder = order.copyWith(status: 'invoiced');
      await _customerOrderRepository.updateCustomerOrder(updatedOrder);

      emit(InvoiceCreated(invoice));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onUpdateInvoice(UpdateInvoice event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      final updatedInvoice = event.invoice.copyWith(updatedAt: DateTime.now());
      await _invoiceRepository.updateInvoice(updatedInvoice);
      emit(InvoiceUpdated(updatedInvoice));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onUpdateInvoiceStatus(UpdateInvoiceStatus event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      await _invoiceRepository.updateInvoiceStatus(event.id, event.status);
      emit(InvoiceOperationSuccess('Invoice status updated successfully'));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onDeleteInvoice(DeleteInvoice event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      await _invoiceRepository.deleteInvoice(event.id);
      emit(InvoiceDeleted(event.id));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> _onWatchInvoices(WatchInvoices event, Emitter<InvoiceState> emit) async {
    await _invoicesSubscription?.cancel();
    _invoicesSubscription = _invoiceRepository.watchInvoices().listen(
      (invoices) => emit(InvoiceLoaded(invoices)),
      onError: (error) => emit(InvoiceError(error.toString())),
    );
  }

  Future<void> _onWatchInvoicesByStatus(
    WatchInvoicesByStatus event,
    Emitter<InvoiceState> emit,
  ) async {
    await _invoicesSubscription?.cancel();
    _invoicesSubscription = _invoiceRepository
        .watchInvoicesByStatus(event.status)
        .listen(
          (invoices) => emit(InvoiceLoaded(invoices)),
          onError: (error) => emit(InvoiceError(error.toString())),
        );
  }

  @override
  Future<void> close() {
    _invoicesSubscription?.cancel();
    return super.close();
  }
}
