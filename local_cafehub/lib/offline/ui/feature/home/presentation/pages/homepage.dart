import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/bloc/theme/theme_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/ui/feature/home/presentation/widgets/action_card_widget.dart';
import 'package:bhansa_ghar/offline/ui/feature/home/presentation/widgets/card_widget.dart';
import 'package:bhansa_ghar/offline/ui/feature/home/presentation/widgets/category_card_widget.dart';
import 'package:bhansa_ghar/offline/ui/feature/home/presentation/widgets/header_notification_widget.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/bloc/notification_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/bloc/notification_state.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with notification
                    BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, notificationState) {
                        return HeaderWithNotification(
                          greeting: AppLocalizations.of(context)!.welcomeBack,
                          userName: AppLocalizations.of(context)!.admin,
                          notificationCount: notificationState.notifications
                              .where((n) => !n.isRead)
                              .length,
                          onNotificationTap: () {
                            context.go('/notifications');
                          },
                        );
                      },
                    ),
                    SizedBox(height: 32.h),

                    // At a Glance Card
                    BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        final activeOrders = state.orders.where((order) {
                          return [
                            'Received',
                            'Preparing',
                            'Ready',
                          ].contains(order.status);
                        }).length;

                        final pendingOrders = state.orders.where((order) {
                          return order.status == 'Pending';
                        }).length;

                        return GlanceCard(
                          activeOrders: activeOrders,
                          pendingOrders: pendingOrders,
                          onRefresh: () {
                            context.read<OrderBloc>().add(LoadOrders());
                          },
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Grid of Action Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.0,
                      children: [
                        ActionCard(
                          icon: Icons.restaurant_menu,
                          label: AppLocalizations.of(context)!.menu,
                          onTap: () {
                            context.go('/menu');
                          },
                        ),
                        ActionCard(
                          icon: Icons.receipt_long,
                          label: AppLocalizations.of(context)!.orders,
                          onTap: () {
                            context.go('/orders');
                          },
                        ),
                        ActionCard(
                          icon: Icons.qr_code_2,
                          label: AppLocalizations.of(context)!.qrCodes,
                          onTap: () {
                            context.go('/qr');
                          },
                        ),
                        ActionCard(
                          icon: Icons.settings,
                          label: AppLocalizations.of(context)!.settings,
                          onTap: () {
                            context.go('/settings');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Manage Categories Section
                    ManageCategoriesCard(
                      title: AppLocalizations.of(context)!.manageCategories,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.manageCategoriesSubtitle,
                      icon: Icons.category,
                      onTap: () {
                        context.go('/category');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
