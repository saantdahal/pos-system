import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/profile_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu.dart';

class WaiterProfilePage extends StatefulWidget {
  const WaiterProfilePage({super.key});

  @override
  State<WaiterProfilePage> createState() => _WaiterProfilePageState();
}

class _WaiterProfilePageState extends State<WaiterProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final profileRepository = context.read<WaiterProfileRepository>();
        return WaiterProfileBloc(profileRepository: profileRepository)
          ..add(const FetchWaiterProfileEvent());
      },
      child: BlocListener<WaiterProfileBloc, WaiterProfileState>(
        listener: (context, state) {
          if (state is WaiterLogoutSuccess) {
            // Trigger AuthBloc logout to update app-level auth state
            // This will emit AuthUnauthenticated which GoRouter will handle
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: BlocBuilder<WaiterProfileBloc, WaiterProfileState>(
            builder: (context, state) {
              if (state is WaiterProfileLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF22C55E),
                  ),
                );
              }

              if (state is WaiterLogoutSuccess) {
                // Listener handles navigation, just return empty while transitioning
                return const SizedBox.shrink();
              }

              // Regular profile content
              return SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 24.w),
                          IconButton(
                            onPressed: () {
                              context.go('/waiter/editprofile');
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24.r,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    if (state is WaiterProfileLoaded)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            children: [
                              SizedBox(height: 20.h),
                              // Profile Header
                              ProfileHeader(
                                name: state.name,
                                role: state.role,
                                location: state.location,
                                profileImageUrl: state.profileImageUrl,
                                isVerified: state.isVerified,
                              ),
                              SizedBox(height: 32.h),
                              // Stats Card
                              ProfileStats(
                                ordersServedToday: state.ordersServedToday,
                              ),
                              SizedBox(height: 24.h),
                              // Menu Items
                              ProfileMenu(
                                onLogout: () {
                                  context.read<WaiterProfileBloc>().add(
                                    const WaiterLogoutEvent(),
                                  );
                                },
                              ),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      )
                    else if (state is WaiterProfileError)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48.sp,
                              ),
                              SizedBox(height: 16.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  state.message,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<WaiterProfileBloc>().add(
                                    const FetchWaiterProfileEvent(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Center(
                          child: Text(
                            'Unknown state',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
