import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/orders_bloc.dart';
import '../widgets/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WaiterOrdersBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ready for Pickup (3)',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Refresh orders
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Orders List
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: [
                      // Order Card 1
                      OrderCard(
                        image: 'assets/images/momo.jpg',
                        isPrepared: true,
                        preparedTime: '8min ago',
                        status: 'READY',
                        statusColor: const Color(0xFF22C55E),
                        orderId: '#123',
                        tableNumber: 'Table 5',
                        items: 'Momo x2',
                        isUrgent: true,
                      ),
                      SizedBox(height: 16.h),
                      // Order Card 2
                      OrderCard(
                        image: 'assets/images/thukpa.jpg',
                        isPrepared: true,
                        preparedTime: '2min ago',
                        status: 'READY',
                        statusColor: const Color(0xFF22C55E),
                        orderId: '#124',
                        tableNumber: 'Table 3',
                        items: 'Thukpa x1',
                        isUrgent: false,
                      ),
                      SizedBox(height: 16.h),
                      // Order Card 3
                      OrderCard(
                        image: 'assets/images/chicken_curry.jpg',
                        isPrepared: true,
                        preparedTime: '1min ago',
                        status: 'READY',
                        statusColor: const Color(0xFF22C55E),
                        orderId: '#125',
                        tableNumber: 'Table 8',
                        items: 'Chicken Curry x1, Naan x2',
                        isUrgent: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
