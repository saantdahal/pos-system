import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/profile_repository.dart';
import '../bloc/edit_profile_bloc.dart';
import '../widgets/edit_profile_form.dart';

class WaiterEditProfile extends StatelessWidget {
  const WaiterEditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WaiterEditProfileBloc(
        profileRepository: context.read<WaiterProfileRepository>(),
      )..add(LoadWaiterProfileEvent()),
      child: const WaiterEditProfileView(),
    );
  }
}

class WaiterEditProfileView extends StatefulWidget {
  const WaiterEditProfileView({super.key});

  @override
  State<WaiterEditProfileView> createState() => _WaiterEditProfileViewState();
}

class _WaiterEditProfileViewState extends State<WaiterEditProfileView> {
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
              context.go('/waiter');
            }
          },
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<WaiterEditProfileBloc, WaiterEditProfileState>(
          listener: (context, state) {
            if (state is WaiterEditProfileUpdated) {
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
            } else if (state is WaiterEditProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          child: BlocBuilder<WaiterEditProfileBloc, WaiterEditProfileState>(
            builder: (context, state) {
              if (state is WaiterEditProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is WaiterEditProfileLoaded) {
                return const WaiterEditProfileForm();
              } else if (state is WaiterEditProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<WaiterEditProfileBloc>().add(
                            LoadWaiterProfileEvent(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
