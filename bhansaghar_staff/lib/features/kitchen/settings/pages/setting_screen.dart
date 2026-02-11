import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansaghar_staff/core/repositories/profile_repository.dart';
import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/chef_profile_card.dart';
import '../widgets/kitchen_settings_colors.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/theme_option_card.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingsBloc(profileRepository: context.read<ProfileRepository>())
            ..add(LoadProfileEvent()),
      child: const SettingView(),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KitchenSettingsColors.background,
      appBar: AppBar(
        backgroundColor: KitchenSettingsColors.background,
        elevation: 0,
        title: Text(
          'KITCHEN SETTINGS',
          style: TextStyle(
            color: KitchenSettingsColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2421),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: KitchenSettingsColors.orangeAccent,
                  size: 20.r,
                ),
                onPressed: () {
                  context.go('/kitchen/profile');
                  // Handle help action
                },
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final bloc = context.read<SettingsBloc>();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChefProfileCard(
                  name: state.userProfile?.username,
                  role: state.userProfile?.role,
                  id: state.userProfile?.id.toString(),
                  resturentname: state.userProfile?.restaurant?.name,
                  imageUrl: state.userProfile?.avatar,
                  isLoading: state.isProfileLoading,
                ),
                SizedBox(height: 30.h),
                _buildSectionTitle('ORDERS & ALERTS'),
                SettingsSwitchTile(
                  icon: Icons.notifications_active,
                  title: 'Sound Alerts',
                  subtitle: 'Audio cues for new tickets',
                  value: state.soundAlerts,
                  onChanged: (val) => bloc.add(ToggleSoundAlerts(val)),
                ),
                SettingsSwitchTile(
                  icon: Icons.vibration,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibrate on touch and alerts',
                  value: state.hapticFeedback,
                  onChanged: (val) => bloc.add(ToggleHapticFeedback(val)),
                ),
                SettingsSwitchTile(
                  icon: Icons.flashlight_on,
                  title: 'Visual Flash',
                  subtitle: 'Screen pulse on new order',
                  value: state.visualFlash,
                  onChanged: (val) => bloc.add(ToggleVisualFlash(val)),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('ALERT VOLUME'),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2421),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${(state.alertVolume * 100).toInt()}%',
                        style: TextStyle(
                          color: KitchenSettingsColors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(
                      Icons.volume_down,
                      color: KitchenSettingsColors.textSecondary,
                      size: 20.r,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: KitchenSettingsColors.orangeAccent,
                          inactiveTrackColor:
                              KitchenSettingsColors.switchInactiveTrack,
                          thumbColor: Colors.white,
                          overlayColor: KitchenSettingsColors.orangeAccent
                              .withValues(alpha: 0.2),
                          trackHeight: 12.h,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 10.r,
                          ),
                        ),
                        child: Slider(
                          value: state.alertVolume,
                          onChanged: (val) => bloc.add(ChangeAlertVolume(val)),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.volume_up,
                      color: KitchenSettingsColors.orangeAccent,
                      size: 20.r,
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                _buildSectionTitle('APP THEME'),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ThemeOptionCard(
                      themeType: AppThemeType.light,
                      label: 'Light',
                      icon: Icons.wb_sunny_outlined,
                      isSelected: state.appTheme == AppThemeType.light,
                      onTap: () =>
                          bloc.add(const ChangeAppTheme(AppThemeType.light)),
                    ),
                    ThemeOptionCard(
                      themeType: AppThemeType.dark,
                      label: 'Dark',
                      icon: Icons.nightlight_round,
                      isSelected: state.appTheme == AppThemeType.dark,
                      onTap: () =>
                          bloc.add(const ChangeAppTheme(AppThemeType.dark)),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthLogoutRequested(),
                    ),
                    icon: Icon(Icons.logout, color: Colors.white, size: 24.r),
                    label: Text(
                      'LOG OUT STAFF',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'BhansaGhar Kitchen System v2.4.0',
                        style: TextStyle(
                          color: KitchenSettingsColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        'Handcrafted for culinary excellence',
                        style: TextStyle(
                          color: KitchenSettingsColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(
          color: KitchenSettingsColors.orangeAccent,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
