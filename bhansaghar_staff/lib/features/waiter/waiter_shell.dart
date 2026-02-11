import 'package:bhansaghar_staff/features/waiter/presentation/alerts/bloc/alerts_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/alerts/pages/alerts_page.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/pages/orders_page.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/profile/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/pages/dashboard.dart';

class WaiterShell extends StatefulWidget {
  const WaiterShell({super.key});

  @override
  State<WaiterShell> createState() => _WaiterShellState();
}

class _WaiterShellState extends State<WaiterShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    WaiterDashboard(),
    OrdersPage(),
    WaiterAlertScreen(),
    WaiterProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WaiterAlertsBloc(),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.black87,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.table_chart),
              label: 'TABLES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'ORDERS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'ALERTS',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}
