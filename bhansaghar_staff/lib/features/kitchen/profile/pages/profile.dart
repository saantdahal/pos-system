import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansaghar_staff/core/repositories/profile_repository.dart';
import 'package:bhansaghar_staff/core/repositories/auth_repository.dart';
import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import 'package:bhansaghar_staff/core/models/auth_models.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_form.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        profileRepository: context.read<ProfileRepository>(),
        authRepository: context.read<AuthRepository>(),
      )..add(LoadProfileEvent()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.r),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              // If can't pop, navigate to the appropriate home screen based on role
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                if (user.role == UserRole.waiter) {
                  context.go('/waiter');
                } else if (user.role == UserRole.kitchen) {
                  context.go('/kitchen');
                } else {
                  context.go('/role-select');
                }
              } else {
                context.go('/login');
              }
            }
          },
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
              // Navigate back after successful update
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted &&
                    context.mounted &&
                    GoRouter.of(context).canPop()) {
                  context.pop();
                }
              });
            } else if (state is EmailUpdateRequested) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            } else if (state is EmailUpdateVerified) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
              // Navigate back after successful email update
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted &&
                    context.mounted &&
                    GoRouter.of(context).canPop()) {
                  context.pop();
                }
              });
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                return ProfileForm(profile: state.profile);
              } else if (state is ProfileUpdating) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileUpdated) {
                return ProfileForm(profile: state.profile);
              } else if (state is ProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProfileBloc>().add(LoadProfileEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
