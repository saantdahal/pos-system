import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/table_details/table_details_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_details/table_details_header.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_details/table_info_card.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_details/table_status_section.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_details/special_instructions_section.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_details/recent_orders_section.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_details/table_action_buttons.dart';

class WaiterTableDetails extends StatefulWidget {
  final String tableId;

  const WaiterTableDetails({super.key, required this.tableId});

  @override
  State<WaiterTableDetails> createState() => _WaiterTableDetailsState();
}

class _WaiterTableDetailsState extends State<WaiterTableDetails> {
  @override
  void initState() {
    super.initState();
    final tableIdInt = int.tryParse(widget.tableId) ?? 0;
    context.read<TableDetailsBloc>().add(LoadTableDetailsEvent(tableIdInt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: BlocBuilder<TableDetailsBloc, TableDetailsState>(
        builder: (context, state) {
          if (state is TableDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            );
          }

          if (state is TableDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error Loading Table Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      final tableIdInt = int.tryParse(widget.tableId) ?? 0;
                      context.read<TableDetailsBloc>().add(
                        LoadTableDetailsEvent(tableIdInt),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is TableDetailsLoaded) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      TableDetailsHeader(
                        tableNumber: state.table.tableNumber,
                        onBackPressed: () => context.pop(),
                        onMenuPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Menu options coming soon'),
                              backgroundColor: const Color(0xFF22C55E),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),

                      // Table Info Card
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: TableInfoCard(
                          tableNumber: state.table.tableNumber,
                          capacity: state.table.capacity,
                        ),
                      ),

                      // Table Status Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TableStatusSection(
                          currentStatus: state.table.status,
                          onStatusChanged: (newStatus) {
                            context.read<TableDetailsBloc>().add(
                              UpdateTableStatusEvent(newStatus),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Special Instructions Section
                      if (state.table.specialInstructions?.isNotEmpty ?? false)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: SpecialInstructionsSection(
                            instructions: state.table.specialInstructions ?? '',
                          ),
                        ),

                      SizedBox(height: 24.h),

                      // Recent Orders Section
                      if (state.table.recentOrders.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: RecentOrdersSection(
                            orders: state.table.recentOrders,
                            hasLiveOrders: state.table.hasLiveOrders,
                          ),
                        ),

                      SizedBox(height: 120.h), // Space for bottom buttons
                    ],
                  ),
                ),
                // Action Buttons - Fixed at Bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<TableDetailsBloc, TableDetailsState>(
                    builder: (context, state) {
                      final isLoading = state is TableDetailsUpdating;

                      if (state is! TableDetailsLoaded) {
                        return const SizedBox.shrink();
                      }

                      return TableActionButtons(
                        onCleanTable: () {
                          context.read<TableDetailsBloc>().add(
                            const CleanTableEvent(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Table marked for cleaning'),
                              backgroundColor: const Color(0xFFFFC107),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        onMarkReady: () {
                          context.read<TableDetailsBloc>().add(
                            const MarkTableReadyEvent(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Table marked as ready'),
                              backgroundColor: const Color(0xFF22C55E),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        onCallKitchen: () {
                          context.read<TableDetailsBloc>().add(
                            const CallKitchenEvent(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Kitchen called'),
                              backgroundColor: const Color(0xFF1976D2),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        isLoading: isLoading,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
