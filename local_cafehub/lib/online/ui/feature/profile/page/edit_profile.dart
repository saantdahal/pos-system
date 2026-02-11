import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/core/repositories/profile_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/core/services/dio_service.dart';
import '../bloc/profile_bloc.dart';
import '../../settings/presentation/bloc/setting_bloc.dart';
import '../widget/profile_form.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        profileRepository: ProfileRepository(
          apiClient: ApiClient(
            context.read<DioService>().dio,
            baseUrl: context.read<DioService>().baseUrl,
          ),
        ),
        authRepository: context.read<AuthRepository>(),
        settingBloc: context.read<SettingBloc>(),
      )..add(LoadProfileEvent()),
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
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
          onPressed: () => context.pop(),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
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
              if (mounted && context.mounted) context.pop();
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
              if (mounted && context.mounted) context.pop();
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
            }

            if (state is ProfileLoaded ||
                state is ProfileUpdated ||
                state is EmailUpdateVerified) {
              final profile = state is ProfileLoaded
                  ? state.profile
                  : state is ProfileUpdated
                  ? state.profile
                  : (state as EmailUpdateVerified).profile;

              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: ProfileForm(profile: profile),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.r,
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(LoadProfileEvent());
                      },
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
    );
  }
}
