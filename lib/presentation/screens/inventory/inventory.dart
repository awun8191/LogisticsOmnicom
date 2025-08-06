import 'package:flutter/material.dart';
import 'package:logistics/presentation/screens/inventory/inventory.desktop.dart';
import 'package:logistics/presentation/screens/inventory/inventory.mobile.dart';
import 'package:logistics/presentation/widgets/app_layout.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(desktop: DesktopInventoryPage(), mobile: MobileInventoryPage());
  }
}
