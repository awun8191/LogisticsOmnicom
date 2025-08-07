import 'package:logistics/data/models/invoice_model.dart';

abstract class InvoiceRepository {
  Future<void> createInvoice(InvoiceModel invoice);
  Future<List<InvoiceModel>> getAllInvoices();
  Future<InvoiceModel?> getInvoiceById(String id);
  Future<List<InvoiceModel>> getInvoicesByStatus(String status);
  Future<List<InvoiceModel>> getInvoicesByCustomer(String customerName);
  Future<List<InvoiceModel>> searchInvoices(String query);
  Future<void> updateInvoice(InvoiceModel invoice);
  Future<void> updateInvoiceStatus(String id, String status);
  Future<void> deleteInvoice(String id);
  Stream<List<InvoiceModel>> watchInvoices();
  Stream<List<InvoiceModel>> watchInvoicesByStatus(String status);
}
