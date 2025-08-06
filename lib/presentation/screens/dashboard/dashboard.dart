import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics/presentation/controller/dashboard_controller/dashboard_controller.dart';
import 'package:logistics/presentation/screens/dashboard/dashboard.desktop.dart';
import 'package:logistics/presentation/screens/dashboard/dashboard.mobile.dart';
import 'package:logistics/presentation/widgets/app_layout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());
    return AppLayout(desktop: DesktopDashboardPage(), mobile: MobileDashboardPage());
  }
}
