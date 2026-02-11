import 'package:flutter/material.dart';

class KitchenOrdersPage extends StatelessWidget {
  const KitchenOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Text(
          'Orders Page',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
