import 'package:bhansaghar_staff/core/models/auth_models.dart';
import 'package:bhansaghar_staff/features/kitchen/homepage/pages/homepage.dart';
import 'package:bhansaghar_staff/features/kitchen/inventory/pages/inventory_page.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/pages/kitchen_orders_page.dart';
import 'package:bhansaghar_staff/features/kitchen/homepage/pages/kitchen_main_screen.dart';
import 'package:bhansaghar_staff/features/kitchen/profile/pages/profile.dart';
import 'package:bhansaghar_staff/features/kitchen/settings/pages/setting_screen.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/edit_profile/pages/edit_profile.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/log_activities/pages/log_pags.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/bloc/order_details/order_details_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/pages/orders_details.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/table_details/table_details_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/pages/tables_details.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/profile/pages/profile_page.dart';
import 'package:bhansaghar_staff/features/waiter/waiter_shell.dart';
import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import 'package:bhansaghar_staff/shared/auth/pages/login_page.dart';
import 'package:bhansaghar_staff/shared/auth/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

GoRouter createRouter(
  BuildContext context,
  GlobalKey<NavigatorState> navigatorKey,
) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    refreshListenable: _RouterRefreshStream(context),
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isSplash = state.matchedLocation == '/';
      final isAuthPage = state.matchedLocation == '/login';

      if (isSplash) {
        return null; // Let splash handle auth check
      }

      if (!isAuthenticated) {
        if (isAuthPage) {
          return null;
        }
        return '/login';
      }

      if (isAuthenticated && isAuthPage) {
        // ignore: unnecessary_type_check
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          if (user.role == UserRole.waiter) {
            return '/waiter';
          } else if (user.role == UserRole.kitchen) {
            return '/kitchen';
          }
        }
        return '/role-select';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // Waiter Routes (Shell for Bottom Nav)
      GoRoute(
        path: '/waiter',
        builder: (context, state) => const WaiterShell(),
        routes: [
          GoRoute(
            path: 'order/:id',
            builder: (context, state) {
              final orderId = int.parse(state.pathParameters['id']!);
              return BlocProvider(
                create: (context) => OrderDetailsBloc(),
                child: OrderDetailsPage(orderId: orderId),
              );
            },
          ),
          GoRoute(
            path: 'table/:id',
            builder: (context, state) {
              final tableId = state.pathParameters['id']!;
              return BlocProvider(
                create: (context) => TableDetailsBloc(),
                child: WaiterTableDetails(tableId: tableId),
              );
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const WaiterProfilePage(),
          ),
        ],
      ),

      // Kitchen Routes (Shell for Bottom Nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return KitchenMainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kitchen',
                builder: (context, state) => const KitchenHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kitchen/orders',
                builder: (context, state) => const KitchenOrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kitchen/inventory',
                builder: (context, state) => const KitchenInventoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kitchen/settings',
                builder: (context, state) => const SettingScreen(),
              ),
            ],
          ),
        ],
      ),

      // Profile Page (Separate from navbar)
      GoRoute(
        path: '/kitchen/profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // Waiter edit profile page:
      GoRoute(
        path: '/waiter/editprofile',
        builder: (context, state) => const WaiterEditProfile(),
      ),

      // Waiter activity log page:
      GoRoute(
        path: '/waiter/activitylogs',
        builder: (context, state) => const WaiterActivityLog(),
      ),

      // Root redirect
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            if (user.role == UserRole.waiter) {
              return '/waiter';
            } else if (user.role == UserRole.kitchen) {
              return '/kitchen';
            }
            return '/role-select';
          }
          return '/login';
        },
      ),
    ],
  );
}

class _RouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  _RouterRefreshStream(BuildContext context) {
    _subscription = context.read<AuthBloc>().stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
