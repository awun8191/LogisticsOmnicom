import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logistics/presentation/screens/inventory/inventory.dart';
import 'package:logistics/presentation/screens/invoice/invoice.dart';

class DashboardController extends GetxController {
  final selectedIndex = 0.obs;

  final List<NavigationRailDestination> destinations = [
    const NavigationRailDestination(icon: Icon(Icons.inventory), label: Text("Inventory")),
    const NavigationRailDestination(icon: Icon(Icons.receipt), label: Text("Invoices")),
  ];

  final List<Widget> pages = [const InventoryPage(), const InvoicePage()];

  void chenageSelectedIndex(int index) {
    selectedIndex.value = index;
    update();
  }
}
