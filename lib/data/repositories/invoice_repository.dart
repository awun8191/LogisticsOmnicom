import 'package:logistics/core/services/firestore_service.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final FirestoreService _firestoreService;

  InvoiceRepositoryImpl(this._firestoreService);

  @override
  Future<void> createInvoice(InvoiceModel invoice) async {
    for (final item in invoice.items) {
      final inventorySnapshot = await _firestoreService.getInventoryByName(item.name);
      if (inventorySnapshot.docs.isEmpty) {
        throw Exception('Inventory item not found: ${item.name}');
      }

      final inventoryDoc = inventorySnapshot.docs.first;
      final inventoryData = inventoryDoc.data() as Map<String, dynamic>;
      final currentQuantity = inventoryData['quantity'] as int;

      if (currentQuantity < item.quantity) {
        throw Exception('Not enough stock for ${item.name}. Available: $currentQuantity, Required: ${item.quantity}');
      }
    }

    // After checking all items, create the invoice and update inventory
    final invoiceRef = await _firestoreService.createInvoice(invoice);

    for (final item in invoice.items) {
      final inventorySnapshot = await _firestoreService.getInventoryByName(item.name);
      final inventoryDoc = inventorySnapshot.docs.first;
      final inventoryData = inventoryDoc.data() as Map<String, dynamic>;
      final currentQuantity = inventoryData['quantity'] as int;
      final newQuantity = currentQuantity - item.quantity;
      await _firestoreService.updateInventoryQuantity(inventoryDoc.id, newQuantity);
    }
  }
}
