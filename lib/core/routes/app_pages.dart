import 'package:get/get.dart';
import 'package:logistics/presentation/screens/splash_screen/splash_screen.dart';
import '../../presentation/screens/auth/signin_page.dart';
import '../../presentation/screens/dashboard/dashboard.dart';
import '../../presentation/screens/customer_orders/customer_orders.dart';
import '../../presentation/screens/customer_orders/customer_order_detail.mobile.dart';
import '../../presentation/screens/customer_orders/customer_order_detail.desktop.dart';
import '../../presentation/screens/customer_orders/create_customer_order.mobile.dart';
import '../../presentation/screens/customer_orders/create_customer_order.desktop.dart';
import '../../presentation/screens/invoice/invoice.dart';
import '../../presentation/screens/invoice/invoice_detail.mobile.dart';
import '../../presentation/screens/invoice/invoice_detail.desktop.dart';
import '../../presentation/screens/invoice/create_invoice.mobile.dart';
import '../../presentation/screens/invoice/create_invoice.desktop.dart';
import 'app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppRouter {
  // Use GetX's navigation key instead of our own to avoid conflicts
  static final GlobalKey<NavigatorState> navKey = Get.key;

  /// Centralized list of application routes for GetX navigation
  static final List<GetPage<dynamic>> routes = [
    // Auth Routes
    GetPage(name: AppRoutes.initial, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.signin, page: () => const SigninPage()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardPage()),

    // Customer Order Routes
    GetPage(name: AppRoutes.customerOrders, page: () => const CustomerOrdersPage()),
    GetPage(
      name: AppRoutes.customerOrderDetail,
      page: () {
        final order = Get.arguments;
        return kIsWeb ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux
            ? DesktopCustomerOrderDetailPage(order: order)
            : MobileCustomerOrderDetailPage(order: order);
      },
    ),
    GetPage(
      name: AppRoutes.createCustomerOrder,
      page: () =>
          kIsWeb ||
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.linux
          ? const DesktopCreateCustomerOrderPage()
          : const MobileCreateCustomerOrderPage(),
    ),

    // Invoice Routes
    GetPage(name: AppRoutes.invoices, page: () => const InvoicePage()),
    GetPage(
      name: AppRoutes.invoiceDetail,
      page: () {
        final invoice = Get.arguments;
        return kIsWeb ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux
            ? DesktopInvoiceDetailPage(invoice: invoice)
            : MobileInvoiceDetailPage(invoice: invoice);
      },
    ),
    GetPage(
      name: AppRoutes.createInvoice,
      page: () {
        final customerOrder = Get.arguments;
        return kIsWeb ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux
            ? DesktopCreateInvoicePage(customerOrder: customerOrder)
            : MobileCreateInvoicePage(customerOrder: customerOrder);
      },
    ),
  ];

  // Use GetX for navigation to avoid conflicts
  static void navigateTo(String name, [Object? arguments]) {
    Get.toNamed(name, arguments: arguments);
  }

  static void pop() {
    Get.back();
  }
}
