import 'package:bhansa_ghar/online/ui/feature/menu/presentation/pages/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/ui/feature/home/presentation/bloc/dashboard_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/home/presentation/bloc/dashboard_event.dart';
import 'package:bhansa_ghar/online/ui/feature/home/presentation/bloc/dashboard_state.dart';
import 'package:bhansa_ghar/online/ui/feature/settings/presentation/pages/setting.dart';
import '../widgets/home_navbar.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/live_status_item.dart';

class OnlineHomepage extends StatefulWidget {
  const OnlineHomepage({super.key});

  @override
  State<OnlineHomepage> createState() => _OnlineHomepageState();
}

class _OnlineHomepageState extends State<OnlineHomepage> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardInitialized());
  }

  void _onNavTabChanged(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    context.read<DashboardBloc>().add(DashboardTabChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: _currentNavIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: null,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BhansaGhar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB8A0A0).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: const Color(0xFF1A1A1A),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          // Dashboard Tab (index 0)
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B35),
                    ),
                  ),
                );
              }

              if (state is DashboardError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFFF6B35),
                      ),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<DashboardBloc>().add(
                            const DashboardInitialized(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is! DashboardLoaded) {
                return const Center(child: Text('No data available'));
              }

              final data = state.data;
              return _buildDashboardContent(context, data);
            },
          ),
          // Orders Tab (index 1)
          const Center(
            child: Text(
              'Orders Page\nComing Soon',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          // Menu Tab (index 2)
          const MenuPage(),
          // More/Settings Tab (index 3)
          const SettingPage(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return HomeNavBar(
            currentIndex: _currentNavIndex,
            onTabChanged: _onNavTabChanged,
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const DashboardRefreshed());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards Row 1
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DashboardCard(
                    title: 'Orders Today',
                    value: data.ordersToday.toString(),
                    growth: '${data.ordersTodayGrowth.toStringAsFixed(0)}%',
                    icon: Icons.shopping_bag,
                    backgroundColor: const Color(0xFFFFE8DD),
                    iconColor: const Color(0xFFFF6B35),
                  ),
                  DashboardCard(
                    title: 'Revenue',
                    value: '₹${(data.revenue / 1000).toStringAsFixed(0)}K',
                    icon: Icons.money,
                    backgroundColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stats Cards Row 2
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DashboardCard(
                    title: 'Peak Hour',
                    value: data.peakHourTime,
                    subtitle: data.peakHourService,
                    icon: Icons.schedule,
                    backgroundColor: const Color(0xFFFFE8DD),
                    iconColor: const Color(0xFFFF6B35),
                  ),
                  DashboardCard(
                    title: 'Low Stock',
                    value: '${data.lowStockItems} items',
                    icon: Icons.warning_amber,
                    backgroundColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFFC107),
                    isAlert: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Quick Actions Section
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  QuickActionButton(
                    title: 'Add Menu Item',
                    subtitle: 'Last: Chicken Momo',
                    icon: Icons.restaurant,
                    backgroundColor: const Color(0xFFFFE8DD),
                    iconColor: const Color(0xFFFF6B35),
                    onTap: () {
                      context.go('/menu');
                    },
                  ),
                  QuickActionButton(
                    title: 'Categories',
                    subtitle: 'Manage Menu',
                    icon: Icons.category,
                    backgroundColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                    onTap: () {
                      context.push('/categories');
                    },
                  ),
                  QuickActionButton(
                    title: 'Staff QR',
                    subtitle: 'Share Kitchen',
                    icon: Icons.qr_code_2,
                    backgroundColor: const Color(0xFFF5F5F5),
                    iconColor: const Color(0xFF757575),
                    onTap: () {
                      context.go('/staff');
                    },
                  ),
                  QuickActionButton(
                    title: 'Reports',
                    subtitle: 'View Today\'s',
                    icon: Icons.bar_chart,
                    backgroundColor: const Color(0xFFF5F5F5),
                    iconColor: const Color(0xFF757575),
                    onTap: () {
                      context.go('/tables');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Live Status Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View All Orders')),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.liveOrders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = data.liveOrders[index];
                  return LiveStatusItem(
                    orderNumber: order.orderNumber,
                    status: order.status,
                    timestamp: order.timestamp,
                    tableNumber: order.tableNumber,
                    amount: order.amount,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
