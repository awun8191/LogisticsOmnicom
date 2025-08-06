import 'package:flutter/material.dart';
import 'package:logistics/presentation/screens/invoice/invoice.desktop.dart';
import 'package:logistics/presentation/screens/invoice/invoice.mobile.dart';
import 'package:logistics/presentation/widgets/app_layout.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLayout(
      desktop: DesktopInvoicePage(),
      mobile: MobileInvoicePage(),
    );
  }
}
