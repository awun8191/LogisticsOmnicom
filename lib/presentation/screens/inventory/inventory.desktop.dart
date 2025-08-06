import 'package:flutter/material.dart';

class DesktopInventoryPage extends StatefulWidget {
  const DesktopInventoryPage({super.key});

  @override
  State<DesktopInventoryPage> createState() => _DesktopInventoryPagStatee();
}

class _DesktopInventoryPagStatee extends State<DesktopInventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1),
              ),
              child: Text("Orders", style: Theme.of(context).textTheme.displayLarge),
            ),
          ),
        ],
      ),
    );
  }
}
