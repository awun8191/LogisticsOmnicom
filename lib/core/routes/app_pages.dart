import 'package:get/get.dart';
import 'package:logistics/presentation/screens/splash_screen/splash_screen.dart';
import '../../presentation/screens/auth/signin_page.dart';
import '../../presentation/screens/dashboard/dashboard.dart';
import 'app_routes.dart';
import 'package:flutter/material.dart';

class AppRouter {
  // Use GetX's navigation key instead of our own to avoid conflicts
  static final GlobalKey<NavigatorState> navKey = Get.key;

  /// Centralized list of application routes for GetX navigation
  static final List<GetPage<dynamic>> routes = [
    // Auth Routes
    GetPage(name: AppRoutes.initial, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.signin, page: () => const SigninPage()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardPage()),
  ];

  // Use GetX for navigation to avoid conflicts
  static void navigateTo(String name, [Object? arguments]) {
    Get.toNamed(name, arguments: arguments);
  }

  static void pop() {
    Get.back();
  }
}
