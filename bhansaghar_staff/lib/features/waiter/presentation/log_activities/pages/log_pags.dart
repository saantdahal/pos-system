import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/activity.dart';
import '../bloc/activities_bloc.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_stats_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_widget.dart';

class WaiterActivityLog extends StatefulWidget {
  const WaiterActivityLog({super.key});

  @override
  State<WaiterActivityLog> createState() => _WaiterActivityLogState();
}

class _WaiterActivityLogState extends State<WaiterActivityLog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();

    // Load initial data
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadActivities() {
    context.read<WaiterActivitiesBloc>().add(FetchTodayActivitiesEvent());
    context.read<WaiterActivitiesBloc>().add(FetchActivityStatsEvent(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            context.go('/waiter/profile');
          },
        ),

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WaiterActivitiesBloc>().add(RefreshActivitiesEvent());
        },
        child: TabBarView(
          controller: _tabController,
          children: [_buildTodayTab(), _buildHistoryTab()],
        ),
      ),
    );
  }

  /// Tab 1: Today's activities with stats
  Widget _buildTodayTab() {
    return BlocBuilder<WaiterActivitiesBloc, WaiterActivitiesState>(
      builder: (context, state) {
        if (state is WaiterActivitiesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WaiterActivitiesError) {
          return ErrorWidgetComponent(
            message: state.message,
            onRetry: _loadActivities,
          );
        }

        if (state is WaiterActivitiesEmpty) {
          return const EmptyState(
            title: 'No Activities Yet',
            description: 'Your activities will appear here',
            icon: Icons.history,
          );
        }

        if (state is WaiterActivitiesLoaded) {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.activities.length + 1,
            itemBuilder: (context, index) {
              // Add stats card at the top
              if (index == 0) {
                return BlocBuilder<WaiterActivitiesBloc, WaiterActivitiesState>(
                  builder: (context, statsState) {
                    if (statsState is WaiterActivitiesStatsLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ActivityStatsCard(stats: statsState.stats),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }

              final activity = state.activities[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActivityCard(activity: activity),
              );
            },
          );
        }

        return const EmptyState(
          title: 'No Activities',
          description: 'Start performing actions to see your activity log',
          icon: Icons.info,
        );
      },
    );
  }

  /// Tab 2: Activity history with filtering
  Widget _buildHistoryTab() {
    return BlocBuilder<WaiterActivitiesBloc, WaiterActivitiesState>(
      builder: (context, state) {
        if (state is WaiterActivitiesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WaiterActivitiesError) {
          return ErrorWidgetComponent(
            message: state.message,
            onRetry: () {
              context.read<WaiterActivitiesBloc>().add(
                FetchUserActivitiesEvent(days: 30),
              );
            },
          );
        }

        if (state is WaiterActivitiesEmpty) {
          return const EmptyState(
            title: 'No History',
            description: 'No activities found in the selected period',
            icon: Icons.search,
          );
        }

        if (state is WaiterActivitiesLoaded) {
          // Group activities by date
          final groupedActivities = _groupActivitiesByDate(state.activities);

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: groupedActivities.length,
            itemBuilder: (context, index) {
              final entry = groupedActivities.entries.elementAt(index);
              final date = entry.key;
              final activities = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...activities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityCard(activity: activity),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Group activities by date
  Map<DateTime, List<Activity>> _groupActivitiesByDate(
    List<Activity> activities,
  ) {
    final grouped = <DateTime, List<Activity>>{};

    for (final activity in activities) {
      final date = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );
      grouped.putIfAbsent(date, () => []).add(activity);
    }

    // Sort by date descending
    final sorted = Map<DateTime, List<Activity>>.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return sorted;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
