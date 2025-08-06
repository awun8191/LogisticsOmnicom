import 'package:logistics/data/models/invoice_model.dart';

abstract class InvoiceRepository {
  Future<void> createInvoice(InvoiceModel invoice);
}
