import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/data/models/order_model.dart';

class FirestoreService {
  final _instance = FirebaseFirestore.instance;

  // Future<OrderModel> getOrders() async {
  //   try{
  //     _instance.collection("orders").get();
  //   }
  // }
}
