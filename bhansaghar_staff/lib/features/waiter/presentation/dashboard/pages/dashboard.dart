import 'package:flutter/material.dart' hide Table;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_grid.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/status_legend.dart';

class WaiterDashboard extends StatefulWidget {
  const WaiterDashboard({super.key});

  @override
  State<WaiterDashboard> createState() => _WaiterDashboardState();
}

class _WaiterDashboardState extends State<WaiterDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<WaiterDashboardBloc>().add(const WaiterDashboardInitialize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NAMASTE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Table Status',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            BlocBuilder<WaiterDashboardBloc, WaiterDashboardState>(
              builder: (context, state) {
                if (state is WaiterDashboardLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'RESTAURANT',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        state.restaurantName,
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const StatusLegend(),
          Expanded(
            child: BlocBuilder<WaiterDashboardBloc, WaiterDashboardState>(
              builder: (context, state) {
                if (state is WaiterDashboardInitial ||
                    state is WaiterDashboardLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading tables...'),
                      ],
                    ),
                  );
                }

                if (state is WaiterDashboardError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<WaiterDashboardBloc>().add(
                              const WaiterDashboardRefresh(),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is WaiterDashboardLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WaiterDashboardBloc>().add(
                        const WaiterDashboardRefresh(),
                      );
                      // Wait for the state to update
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: state.tables.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_restaurant,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tables available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TableGrid(
                            tables: state.tables,
                            onTableTap: (table) {
                              context.go('/waiter/table/${table.id}');
                            },
                          ),
                  );
                }

                return const Center(child: Text('No data available'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
