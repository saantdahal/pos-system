import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/core/bloc/mode/mode_bloc.dart';
import 'package:go_router/go_router.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String? _selectedMode;

  void _selectMode(String mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  void _confirmSelection() async {
    if (_selectedMode != null) {
      context.read<OnlineAuthBloc>().add(
        ModeSelectionRequested(_selectedMode!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnlineAuthBloc, OnlineAuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is NeedsRestaurantSetup) {
          // Mode must be Online
          context.read<ModeBloc>().add(const ModeChanged(AppMode.online));
          context.go(
            '/restaurant-setup',
            extra: {'profileData': state.profileData},
          );
        } else if (state is Authenticated) {
          // Check selected mode from user or state if available.
          // Since we just selected it, we know what it is from _selectedMode.
          if (_selectedMode == 'offline') {
            context.read<ModeBloc>().add(const ModeChanged(AppMode.offline));
            // Offline router should handle this, or we go to offline dashboard
            // Note: Context.go might fail if router switches immediately.
            // But app.dart rebuilding MaterialApp might handle it.
          } else {
            context.read<ModeBloc>().add(const ModeChanged(AppMode.online));
            context.go('/dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Select App Mode'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Choose your preferred mode',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'You can change this later in settings',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Online Mode Option
              _buildModeOption(
                title: 'Online Mode',
                subtitle:
                    'Access cloud features, real-time updates, and online services',
                icon: Icons.cloud_outlined,
                mode: 'online',
                features: [
                  'Real-time order management',
                  'Cloud data synchronization',
                  'Online payment processing',
                  'Customer notifications',
                ],
              ),

              const SizedBox(height: 24),

              // Offline Mode Option
              _buildModeOption(
                title: 'Offline Mode',
                subtitle: 'Work without internet, local data storage',
                icon: Icons.phone_android_outlined,
                mode: 'offline',
                features: [
                  'Offline order processing',
                  'Local data storage',
                  'Basic reporting',
                  'Manual sync when online',
                ],
              ),

              const Spacer(),

              // Confirm Button
              ElevatedButton(
                onPressed: _selectedMode != null ? _confirmSelection : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String mode,
    required List<String> features,
  }) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () => _selectMode(mode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
