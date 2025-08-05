import 'package:flutter/material.dart';

class AppLayout extends StatefulWidget {
  final Widget desktop;
  final Widget mobile;
  final Widget? tablet;

  const AppLayout({super.key, required this.desktop, required this.mobile, this.tablet});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return widget.desktop;
        } else if (constraints.maxWidth >= 800) {
          return widget.tablet ?? widget.mobile;
        } else {
          return widget.mobile;
        }
      },
    );
  }
}
