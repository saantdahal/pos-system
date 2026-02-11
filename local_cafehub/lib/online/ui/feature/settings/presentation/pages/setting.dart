import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../bloc/setting_bloc.dart';
import '../../../profile/widget/profile_card.dart';
import '../widgets/settings_tile.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingBloc is now provided globally, so we just trigger load event
    context.read<SettingBloc>().add(LoadSettingsEvent());
    return const SettingView();
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SettingBloc, SettingState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          // Navigate to login screen
          context.go('/');
        } else if (state is SettingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          if (state is SettingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingError) {
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
                      context.read<SettingBloc>().add(LoadSettingsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SettingLoaded) {
            return Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
                      ProfileCard(
                        email: state.userEmail,
                        restaurantName: state.restaurantName,
                        username: state.username,
                        avatar: state.avatar,
                      ),
                      SizedBox(height: 24.h),

                      // Edit Profile Button
                      SettingsTile(
                        icon: Icons.edit,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.r,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        onTap: () {
                          context.push('/edit-profile');
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Restaurant Details Button (only for admins)
                      if (state.userRole == 'admin') ...[
                        SettingsTile(
                          icon: Icons.business,
                          title: 'Restaurant Details',
                          subtitle: 'Update your restaurant information',
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.r,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          onTap: () {
                            context.push('/restaurant-details');
                          },
                        ),
                        SizedBox(height: 12.h),
                      ],

                      SettingsTile(
                        icon: Icons.public_rounded,
                        title: 'Website',
                        subtitle: 'Update your Website',
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.r,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        onTap: () {
                          context.push('/website');
                        },
                      ),
                      SizedBox(height: 12.h),

                      // App Settings Section
                      Text(
                        'APP SETTINGS',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Theme Toggle
                      SettingsTile(
                        icon: state.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        title: 'Theme',
                        subtitle: state.isDarkMode ? 'Dark mode' : 'Light mode',
                        trailing: Switch(
                          value: state.isDarkMode,
                          onChanged: (value) {
                            context.read<SettingBloc>().add(
                              ToggleThemeSettingEvent(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Offline Mode Switch
                      SettingsTile(
                        icon: Icons.cloud_off,
                        title: 'Switch to Offline Mode',
                        subtitle: 'Work without internet connection',
                        iconColor: theme.colorScheme.secondary,
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.r,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        onTap: () {
                          _showOfflineModeDialog(context);
                        },
                      ),
                      SizedBox(height: 32.h),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                          icon: Icon(Icons.logout, size: 20.r),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // App Version
                      Center(
                        child: Text(
                          'BhansaGhar v1.0.0',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showOfflineModeDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cloud_off, color: theme.colorScheme.primary),
            SizedBox(width: 8),
            const Text('Switch to Offline Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switching to offline mode will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoItem('• Work without internet connection'),
            _buildInfoItem('• Store data locally on your device'),
            _buildInfoItem('• Keep your account tokens (for switching back)'),
            _buildInfoItem('• Require app restart'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can switch back to online mode anytime from settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SettingBloc>().add(SwitchToOfflineModeEvent());
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Switched to offline mode. Please restart the app.',
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: theme.colorScheme.error),
            SizedBox(width: 8),
            const Text('Logout'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logging out will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoItem('• Clear all authentication tokens'),
            _buildInfoItem('• Remove your session'),
            _buildInfoItem('• Sign you out from Google'),
            _buildInfoItem('• Require login to access online features'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your local restaurant and menu data will be preserved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SettingBloc>().add(LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
