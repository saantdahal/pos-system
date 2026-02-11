import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/pages/category_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/home/presentation/pages/homepage.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/pages/menu_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/pages/order_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/pages/guidance_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/pages/settings_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/qr/presentation/pages/qr_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/pages/notification_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/pages/pin_setup_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/pages/pin_login_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/pages/biometric_login_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/pages/change_pin_screen.dart';
import 'package:bhansa_ghar/offline/ui/feature/splash/presentation/splash_screen.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggingIn = state.uri.toString() == '/pin-login';
      final isBiometricLogin = state.uri.toString() == '/biometric-login';
      final isSplash = state.uri.toString() == '/splash';

      if (authState is AuthBiometricRequired) {
        return isBiometricLogin ? null : '/biometric-login';
      }

      if (authState is AuthPinLocked) {
        return isLoggingIn ? null : '/pin-login';
      }

      if (authState is AuthPinVerifiedSuccess) {
        if (isLoggingIn || isBiometricLogin) {
          return '/';
        }
      }

      // Allow users to access app without PIN
      // They can set up PIN from Settings when they want
      if (authState is AuthPinSetupRequired) {
        // Allow staying on splash
        if (isSplash) return null;
      }

      if (authState is AuthFailure) {
        // Allow staying on splash
        if (isSplash) return null;
        return '/'; // Fallback to home on error
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const Homepage();
        },
        routes: [
          GoRoute(
            path: '/menu',
            builder: (BuildContext context, GoRouterState state) {
              return const MenuScreen();
            },
          ),
          GoRoute(
            path: '/orders',
            builder: (BuildContext context, GoRouterState state) {
              return const OrderScreen();
            },
          ),

          GoRoute(
            path: '/category',
            builder: (BuildContext context, GoRouterState state) {
              return const CategoryScreen();
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsScreen();
            },
          ),
          GoRoute(
            path: '/qr',
            builder: (BuildContext context, GoRouterState state) {
              return const QrScreen();
            },
          ),
          GoRoute(
            path: '/notifications',
            builder: (BuildContext context, GoRouterState state) {
              return const NotificationScreen();
            },
          ),
          GoRoute(
            path: '/pin-setup',
            builder: (BuildContext context, GoRouterState state) {
              return const PinSetupScreen();
            },
          ),
          GoRoute(
            path: '/pin-login',
            builder: (BuildContext context, GoRouterState state) {
              return const PinLoginScreen();
            },
          ),
          GoRoute(
            path: '/change-pin',
            builder: (BuildContext context, GoRouterState state) {
              return const ChangePinScreen();
            },
          ),
          GoRoute(
            path: '/biometric-login',
            builder: (BuildContext context, GoRouterState state) {
              return const BiometricLoginScreen();
            },
          ),

          GoRoute(
            path: '/guidance',
            builder: (BuildContext context, GoRouterState state) {
              return const GuidanceScreen();
            },
          ),
        ],
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
