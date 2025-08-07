import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics/presentation/controller/dashboard_controller/dashboard_controller.dart';

class DesktopDashboardPage extends StatefulWidget {
  const DesktopDashboardPage({super.key});

  @override
  State<DesktopDashboardPage> createState() => _DesktopDashboardStatePage();
}

class _DesktopDashboardStatePage extends State<DesktopDashboardPage> {
  final _dashController = Get.find<DashboardController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Row(
          children: [
            NavigationRail(
              leading: const Icon(Icons.abc),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              groupAlignment: 0.00,
              onDestinationSelected: _dashController.chenageSelectedIndex,
              destinations: _dashController.destinations,
              selectedIndex: _dashController.selectedIndex.value,
            ),
            Expanded(child: _dashController.pages[_dashController.selectedIndex.value]),
          ],
        ),
      ),
    );
  }
}
