import 'package:logistics/core/services/firestore_service.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final FirestoreService _firestoreService;

  InvoiceRepositoryImpl(this._firestoreService);

  @override
  Future<void> createInvoice(InvoiceModel invoice) async {
    // If the invoice is created from an order, the order flow already adjusted inventory
    if (invoice.customerOrderId != null) {
      await _firestoreService.createInvoice(invoice);
      return;
    }

    // Standalone invoice: adjust inventory in a transaction and write ledger entries
    await _firestoreService.createInvoiceAndAdjustInventory(invoice);
  }

  @override
  Future<List<InvoiceModel>> getAllInvoices() async {
    return await _firestoreService.getAllInvoices();
  }

  @override
  Future<InvoiceModel?> getInvoiceById(String id) async {
    return await _firestoreService.getInvoiceById(id);
  }

  @override
  Future<List<InvoiceModel>> getInvoicesByStatus(String status) async {
    return await _firestoreService.getInvoicesByStatus(status);
  }

  @override
  Future<List<InvoiceModel>> getInvoicesByCustomer(String customerName) async {
    return await _firestoreService.getInvoicesByCustomer(customerName);
  }

  @override
  Future<List<InvoiceModel>> searchInvoices(String query) async {
    return await _firestoreService.searchInvoices(query);
  }

  @override
  Future<void> updateInvoice(InvoiceModel invoice) async {
    await _firestoreService.updateInvoice(invoice);
  }

  @override
  Future<void> updateInvoiceStatus(String id, String status) async {
    await _firestoreService.updateInvoiceStatus(id, status);
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _firestoreService.deleteInvoice(id);
  }

  @override
  Stream<List<InvoiceModel>> watchInvoices() {
    return _firestoreService.watchInvoices();
  }

  @override
  Stream<List<InvoiceModel>> watchInvoicesByStatus(String status) {
    return _firestoreService.watchInvoicesByStatus(status);
  }
}
