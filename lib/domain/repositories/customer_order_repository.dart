import 'package:logistics/data/models/customer_order_model.dart';

abstract class CustomerOrderRepository {
  Future<void> createCustomerOrder(CustomerOrderModel order);
  Stream<List<CustomerOrderModel>> getCustomerOrders();
  Stream<List<CustomerOrderModel>> getCustomerOrdersByStatus(String status);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<CustomerOrderModel?> getOrderById(String orderId);
  Future<List<CustomerOrderModel>> getAllCustomerOrders();
  Future<void> updateCustomerOrder(CustomerOrderModel order);
}
