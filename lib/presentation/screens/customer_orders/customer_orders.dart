import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'customer_orders_list.mobile.dart';
import 'customer_orders_list.desktop.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux
        ? const DesktopCustomerOrdersListPage()
        : const MobileCustomerOrdersListPage();
  }
}
