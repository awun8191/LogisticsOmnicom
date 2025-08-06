import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/data/models/invoice_model.dart';
import 'package:logistics/data/models/order_model.dart';

class FirestoreService {
  final _instance = FirebaseFirestore.instance;

  Future<DocumentReference> createInvoice(InvoiceModel invoice) async {
    try {
      final docRef = await _instance.collection('invoices').add(invoice.toMap());
      return docRef;
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot> getInventoryByName(String name) async {
    try {
      return await _instance.collection('inventory').where('name', isEqualTo: name).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInventoryQuantity(String docId, int newQuantity) async {
    try {
      await _instance.collection('inventory').doc(docId).update({'quantity': newQuantity});
    } catch (e) {
      rethrow;
    }
  }
}
