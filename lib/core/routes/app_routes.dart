class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String signin = '/signin';
  static const String dashboard = '/dashboard';
  static const String customerOrders = '/customer-orders';
  static const String customerOrderDetail = '/customer-order-detail';
  static const String createCustomerOrder = '/create-customer-order';
  static const String invoices = '/invoices';
  static const String invoiceDetail = '/invoice-detail';
  static const String createInvoice = '/create-invoice';

  static final List<String> protectedRoutes = [
    dashboard,
    customerOrders,
    customerOrderDetail,
    createCustomerOrder,
    invoices,
    invoiceDetail,
    createInvoice,
  ];
}
