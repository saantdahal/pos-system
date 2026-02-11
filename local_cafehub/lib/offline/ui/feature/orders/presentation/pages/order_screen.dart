import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_filter.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/widgets/order_card.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/widgets/filter_bottom_sheet.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Load orders immediately
    context.read<OrderBloc>().add(LoadOrders());

    // Set up auto-refresh every 3 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        context.read<OrderBloc>().add(LoadOrders());
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context, OrderFilter currentFilter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(currentFilter: currentFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
        title: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            return Text(
              '${AppLocalizations.of(context)!.liveOrders}${state.allFilteredOrders.isNotEmpty ? ' (${state.allFilteredOrders.length})' : ''}',
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            );
          },
        ),
        actions: [
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              final isFilterActive = !state.filter.isEmpty;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: isFilterActive
                          ? Colors.orange
                          : Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () =>
                        _showFilterBottomSheet(context, state.filter),
                  ),
                  if (isFilterActive)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              context.read<OrderBloc>().add(LoadOrders());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state.status == OrderStatus.loading && state.orders.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }
              if (state.status == OrderStatus.error) {
                return Center(
                  child: Text(
                    'Error: ${state.errorMessage}',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
                );
              }

              // Show active filters
              if (!state.filter.isEmpty) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (state.filter.sortOrder == SortOrder.oldest)
                              _buildActiveFilterChip(
                                context,
                                AppLocalizations.of(context)!.oldestFirst,
                                () {
                                  context.read<OrderBloc>().add(
                                    UpdateFilter(
                                      state.filter.copyWith(
                                        sortOrder: SortOrder.newest,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ...state.filter.status.map(
                              (s) => _buildActiveFilterChip(context, s, () {
                                final newStatus = List<String>.from(
                                  state.filter.status,
                                )..remove(s);
                                context.read<OrderBloc>().add(
                                  UpdateFilter(
                                    state.filter.copyWith(status: newStatus),
                                  ),
                                );
                              }),
                            ),
                            if (state.filter.tableNumber != null)
                              _buildActiveFilterChip(
                                context,
                                '${AppLocalizations.of(context)!.table} ${state.filter.tableNumber}',
                                () {
                                  context.read<OrderBloc>().add(
                                    UpdateFilter(
                                      state.filter.copyWith(tableNumber: null),
                                    ), // Pass null to clear
                                  );
                                },
                              ),
                            TextButton(
                              onPressed: () {
                                context.read<OrderBloc>().add(
                                  const UpdateFilter(OrderFilter()),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.clearAllFilters,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: state.filteredOrders.isEmpty
                          ? _buildEmptyState(
                              context,
                              AppLocalizations.of(context)!.noMatchingOrders,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount:
                                  state.filteredOrders.length +
                                  (state.filteredOrders.length <
                                          state.allFilteredOrders.length
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index >= state.filteredOrders.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.read<OrderBloc>().add(
                                            LoadMoreOrders(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.loadMore,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final order = state.filteredOrders[index];
                                return OrderCard(order: order);
                              },
                            ),
                    ),
                  ],
                );
              }

              if (state.orders.isEmpty) {
                return _buildEmptyState(
                  context,
                  AppLocalizations.of(context)!.noOrdersYet,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount:
                    state.filteredOrders.length +
                    (state.filteredOrders.length <
                            state.allFilteredOrders.length
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index >= state.filteredOrders.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<OrderBloc>().add(LoadMoreOrders());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(AppLocalizations.of(context)!.loadMore),
                        ),
                      ),
                    );
                  }
                  final order = state.filteredOrders[index];
                  return OrderCard(order: order);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(
    BuildContext context,
    String label,
    VoidCallback onDeleted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.getSubtitleColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
