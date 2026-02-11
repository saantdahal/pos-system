import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/home_bloc.dart';
import '../models/kitchen_order_model.dart';
import '../widgets/kds_header.dart';
import '../widgets/order_card.dart';
import '../widgets/summary_stat_card.dart';

class KitchenHomePage extends StatefulWidget {
  const KitchenHomePage({super.key});

  @override
  State<KitchenHomePage> createState() => _KitchenHomePageState();
}

class _KitchenHomePageState extends State<KitchenHomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadDashboard()),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Dark Background
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            KDSHeader(
                              restaurantName: state.restaurantName,
                              stationName: 'LIVE STATION 01',
                            ),
                            SizedBox(height: 16.h),

                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SummaryStatCard(
                                  title: 'PENDING',
                                  count: state.pendingCount.toString(),
                                  infoColor: Colors.deepOrange,
                                  backgroundColor: const Color(0xFF2A1C15),
                                ),
                                SummaryStatCard(
                                  title: 'PREP',
                                  count: state.prepCount.toString(),
                                  infoColor: Colors.amber,
                                  backgroundColor: const Color(0xFF2A2815),
                                ),
                                SummaryStatCard(
                                  title: 'READY',
                                  count: state.readyCount.toString(),
                                  infoColor: Colors.green,
                                  backgroundColor: const Color(0xFF152A1C),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            // Active Orders Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Active Orders',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Orders List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.activeOrders.length,
                              itemBuilder: (context, index) {
                                final order = state.activeOrders[index];
                                return OrderCard(
                                  order: order,
                                  onPrep: () {
                                    context.read<HomeBloc>().add(
                                      UpdateOrderStatus(
                                        orderId: order.orderId,
                                        newStatus: OrderStatus.prep,
                                      ),
                                    );
                                  },
                                  onReady: () {
                                    context.read<HomeBloc>().add(
                                      UpdateOrderStatus(
                                        orderId: order.orderId,
                                        newStatus: OrderStatus.ready,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is HomeError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
