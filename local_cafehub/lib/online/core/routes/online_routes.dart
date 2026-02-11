import 'package:bhansa_ghar/online/ui/feature/menu/presentation/pages/menu_page.dart';
import 'package:bhansa_ghar/online/ui/feature/profile/page/edit_profile.dart';
import 'package:bhansa_ghar/online/ui/feature/restaurant/page/restaurant_details.dart';
import 'package:bhansa_ghar/online/ui/feature/settings/presentation/pages/setting.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/pages/staff_page.dart';
import 'package:bhansa_ghar/online/ui/feature/tables/presentation/pages/tables_qr.dart';
import 'package:bhansa_ghar/online/ui/feature/restaurant_setup/presentation/restaurant_setup.dart';
import 'package:bhansa_ghar/online/core/routes/go_router_refresh_stream.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/ui/feature/website/pages/website_page.dart';
import 'package:bhansa_ghar/online/ui/feature/website/bloc/website_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/pages/google_signin_screen.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/pages/otp_verification_screen.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/pages/profile_completion_screen.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/pages/mode_selection_screen.dart';
import 'package:bhansa_ghar/online/ui/feature/categories/presentation/pages/category.dart';
import 'package:bhansa_ghar/online/ui/feature/home/presentation/pages/online_homepage.dart';

class OtpVerificationRoute extends StatelessWidget {
  const OtpVerificationRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final goRouterState = GoRouterState.of(context);
    final extra = goRouterState.extra as Map<String, dynamic>?;
    final extraEmail = extra?['email'] as String?;
    final extraCode = extra?['code'] as String?;
    final authState = context.watch<OnlineAuthBloc>().state;
    final email =
        extraEmail ??
        (authState is NeedsOtpVerification ? authState.email : '');
    final code =
        extraCode ??
        (authState is NeedsOtpVerification ? authState.verificationCode : null);
    return OtpVerificationScreen(email: email, verificationCode: code);
  }
}

class ProfileCompletionRoute extends StatelessWidget {
  const ProfileCompletionRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<OnlineAuthBloc>().state;
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final extraEmail = extra?['email'] as String?;

    if (extraEmail != null && extraEmail.isNotEmpty) {
      return ProfileCompletionScreen(email: extraEmail);
    }

    if (authState is NeedsProfileCompletion && authState.email.isNotEmpty) {
      return ProfileCompletionScreen(email: authState.email);
    }

    // Fallback to repository if state doesn't have it
    return FutureBuilder<String?>(
      future: context.read<AuthRepository>().getUserEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final email = snapshot.data ?? '';
        return ProfileCompletionScreen(email: email);
      },
    );
  }
}

GoRouter createOnlineRouter(BuildContext context) {
  final authBloc = context.read<OnlineAuthBloc>();
  return GoRouter(
    initialLocation: '/google-signin',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<OnlineAuthBloc>().state;
      debugPrint(
        'Router redirect: current auth state = $authState, current location = ${state.matchedLocation}',
      );

      // If still loading/initial, don't redirect
      if (authState is AuthInitial || authState is AuthLoading) {
        debugPrint(
          'Router redirect: auth state is initial/loading, not redirecting',
        );
        return null;
      }

      final currentLocation = state.matchedLocation;

      if (authState is Unauthenticated) {
        if (currentLocation != '/google-signin') {
          debugPrint('Router redirect: redirecting to /google-signin');
          return '/google-signin';
        }
        return null;
      }

      if (authState is NeedsOtpVerification) {
        if (currentLocation != '/otp-verification') {
          debugPrint('Router redirect: redirecting to /otp-verification');
          return '/otp-verification';
        }
        return null;
      }

      if (authState is NeedsProfileCompletion) {
        if (currentLocation != '/profile-completion') {
          debugPrint('Router redirect: redirecting to /profile-completion');
          return '/profile-completion';
        }
        return null;
      }

      if (authState is NeedsModeSelection) {
        if (currentLocation != '/mode-selection') {
          debugPrint('Router redirect: redirecting to /mode-selection');
          return '/mode-selection';
        }
        return null;
      }

      if (authState is NeedsRestaurantSetup) {
        if (currentLocation != '/restaurant-setup') {
          debugPrint('Router redirect: redirecting to /restaurant-setup');
          return '/restaurant-setup';
        }
        return null;
      }

      if (authState is Authenticated) {
        // After authentication, redirect to dashboard if on auth screens
        if (currentLocation == '/google-signin' ||
            currentLocation == '/otp-verification' ||
            currentLocation == '/profile-completion' ||
            currentLocation == '/mode-selection' ||
            currentLocation == '/restaurant-setup') {
          debugPrint('Router redirect: redirecting to /dashboard');
          return '/dashboard';
        }
        return null;
      }

      // For auth failure, redirect to sign in
      if (authState is AuthFailure) {
        if (currentLocation != '/google-signin') {
          debugPrint(
            'Router redirect: auth failure, redirecting to /google-signin',
          );
          return '/google-signin';
        }
        return null;
      }

      debugPrint('Router redirect: no redirect needed');
      return null;
    },
    routes: [
      GoRoute(
        path: '/google-signin',
        builder: (context, state) => const GoogleSignInScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => const OtpVerificationRoute(),
      ),
      GoRoute(
        path: '/profile-completion',
        builder: (context, state) => const ProfileCompletionRoute(),
      ),
      GoRoute(
        path: '/mode-selection',
        builder: (context, state) => const ModeSelectionScreen(),
      ),

      GoRoute(path: '/staff', builder: (context, state) => const StaffPage()),
      GoRoute(
        path: '/restaurant-setup',
        builder: (context, state) {
          var profileData =
              (state.extra as Map<String, dynamic>?)?['profileData']
                  as Map<String, dynamic>?;

          // If profileData is not in extra, try to get it from Bloc state
          if (profileData == null) {
            final authState = context.read<OnlineAuthBloc>().state;
            if (authState is NeedsRestaurantSetup) {
              profileData = authState.profileData;
            }
          }

          return RestaurantSetupPage(
            restaurantName: profileData?['restaurantName'] as String?,
            restaurantAddress: profileData?['address'] as String?,
            restaurantPhone: profileData?['phone'] as String?,
            restaurantLatitude: profileData?['latitude'] as double?,
            restaurantLongitude: profileData?['longitude'] as double?,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const OnlineHomepage(),
      ),
      GoRoute(
        path: '/online-home',
        builder: (context, state) => const OnlineHomepage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/restaurant-details',
        builder: (context, state) => const RestaurantDetailsPage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(path: '/menu', builder: (context, state) => const MenuPage()),
      GoRoute(
        path: '/tables',
        builder: (context, state) => const TablesQRPage(),
      ),
      GoRoute(
        path: '/website',
        builder: (context, state) {
          debugPrint('Initializing WebsiteBloc route...');
          try {
            // Verify WebsiteBloc is available
            context.read<WebsiteBloc>();
            return const WebsiteSettingsPage();
          } catch (e) {
            debugPrint('Error: WebsiteBloc not found in context: $e');
            return Scaffold(
              appBar: AppBar(title: const Text('Website Settings')),
              body: Center(child: Text('Error loading page: $e')),
            );
          }
        },
      ),
      GoRoute(
        path: '/offline-home',
        builder: (BuildContext context, GoRouterState state) {
          // For now, navigate to offline home
          // In real app, this would be the offline router
          return Container(); // Placeholder
        },
      ),
    ],
  );
}
