import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logistics/presentation/screens/inventory/inventory.dart';

class DashboardController extends GetxController {
  final selectedIndex = 0.obs;

  final List<NavigationRailDestination> destinations = [
    NavigationRailDestination(icon: Icon(Icons.inventory), label: Text("Inventory")),
  ];

  final List<Widget> pages = [InventoryPage()];

  void chenageSelectedIndex(int index) {
    selectedIndex.value = index;
  }
}
