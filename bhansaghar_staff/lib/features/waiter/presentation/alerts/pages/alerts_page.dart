import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/alerts/bloc/alerts_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/alerts/widgets/alerts_category_section.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/alerts/widgets/alerts_header.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/alerts/widgets/alerts_tab_bar.dart';

class WaiterAlertScreen extends StatefulWidget {
  const WaiterAlertScreen({super.key});

  @override
  State<WaiterAlertScreen> createState() => _WaiterAlertScreenState();
}

class _WaiterAlertScreenState extends State<WaiterAlertScreen> {
  late WaiterAlertsBloc _alertsBloc;
  String _activeTab = 'all';

  @override
  void initState() {
    super.initState();
    _alertsBloc = context.read<WaiterAlertsBloc>();
    _alertsBloc.add(const LoadAlertsEvent(tab: 'all'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: BlocBuilder<WaiterAlertsBloc, WaiterAlertsState>(
        builder: (context, state) {
          if (state is WaiterAlertsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            );
          }

          if (state is WaiterAlertsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[400],
                    size: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<WaiterAlertsBloc>().add(
                        LoadAlertsEvent(tab: _activeTab),
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

          if (state is WaiterAlertsLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlertsHeader(
                    unreadCount: state.unreadCount,
                    onMarkAllAsRead: () {
                      context.read<WaiterAlertsBloc>().add(
                        const MarkAllAlertsAsReadEvent(),
                      );
                    },
                  ),
                  SizedBox(height: 8.h),
                  Container(color: Colors.grey[800], height: 0.5),
                  AlertsTabBar(
                    activeTab: _activeTab,
                    onTabChanged: (tab) {
                      setState(() {
                        _activeTab = tab;
                      });
                      context.read<WaiterAlertsBloc>().add(ChangeTabEvent(tab));
                    },
                  ),
                  Container(color: Colors.grey[800], height: 0.5),
                  if (state.recentAlerts.isEmpty && state.earlierAlerts.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              color: Colors.grey[600],
                              size: 48.sp,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No alerts yet',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    AlertsCategorySection(
                      title: 'RECENT',
                      alerts: state.recentAlerts,
                      onAlertTap: (alertId) {
                        context.read<WaiterAlertsBloc>().add(
                          MarkAlertAsReadEvent(alertId),
                        );
                      },
                    ),
                    if (state.earlierAlerts.isNotEmpty)
                      AlertsCategorySection(
                        title: 'EARLIER',
                        alerts: state.earlierAlerts,
                        onAlertTap: (alertId) {
                          context.read<WaiterAlertsBloc>().add(
                            MarkAlertAsReadEvent(alertId),
                          );
                        },
                      ),
                  ],
                  SizedBox(height: 32.h),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
