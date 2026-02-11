import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/services/biometric_service.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';

class SecuritySettingsSection extends StatefulWidget {
  const SecuritySettingsSection({super.key});

  @override
  State<SecuritySettingsSection> createState() =>
      _SecuritySettingsSectionState();
}

class _SecuritySettingsSectionState extends State<SecuritySettingsSection> {
  late BiometricService _biometricService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _biometricService = RepositoryProvider.of<BiometricService>(context);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.getSubtitleColor(context),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool isPinSet = false;
        if (authState is AuthPinVerifiedSuccess ||
            authState is AuthPinSetSuccess ||
            authState is AuthPinLocked) {
          isPinSet = true;
        } else if (authState is AuthFailure) {
          isPinSet = authState.isPinSet;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(AppLocalizations.of(context)!.credentials),
            const SizedBox(height: 12),
            SettingItem(
              icon: Icons.pin,
              title: AppLocalizations.of(context)!.setupPin,
              subtitle: AppLocalizations.of(context)!.setNewPin,
              onTap: isPinSet
                  ? null
                  : () {
                      context.push('/pin-setup');
                    },
              trailing: isPinSet
                  ? const Icon(Icons.check, color: Colors.green)
                  : const Icon(Icons.chevron_right, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: isPinSet ? 1.0 : 0.5,
              child: SettingItem(
                icon: Icons.lock_outline,
                title: AppLocalizations.of(context)!.changePin,
                subtitle: AppLocalizations.of(context)!.updatePin,
                onTap: isPinSet
                    ? () {
                        context.push('/change-pin');
                      }
                    : null,
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            if (isPinSet)
              SettingItem(
                icon: Icons.lock_open,
                title: AppLocalizations.of(context)!.turnOffPin,
                subtitle: AppLocalizations.of(context)!.removePinSecurity,
                onTap: () => _showTurnOffPinDialog(context),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            const SizedBox(height: 32),
            _buildSectionHeader(AppLocalizations.of(context)!.biometrics),
            const SizedBox(height: 12),
            FutureBuilder<bool>(
              future: _biometricService.isDeviceSupported(),
              builder: (context, snapshot) {
                final isDeviceSupported = snapshot.data ?? false;
                final subtitle = isDeviceSupported
                    ? AppLocalizations.of(context)!.biometricSubtitle
                    : AppLocalizations.of(context)!.biometricNotAvailable;

                return Opacity(
                  opacity: isPinSet && isDeviceSupported ? 1.0 : 0.5,
                  child: SettingItem(
                    icon: Icons.fingerprint,
                    title: AppLocalizations.of(context)!.enableBiometricLogin,
                    subtitle: subtitle,
                    trailing: Switch(
                      value: isPinSet
                          ? _biometricService.isBiometricEnabled()
                          : false,
                      onChanged: isPinSet && isDeviceSupported
                          ? (value) => _handleBiometricToggle(value)
                          : null,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.blue,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showTurnOffPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isBiometricEnabled = _biometricService.isBiometricEnabled();
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.turnOffPinTitle),
          content: Text(
            isBiometricEnabled
                ? AppLocalizations.of(context)!.turnOffPinMessageWithBiometric
                : AppLocalizations.of(context)!.turnOffPinMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(AuthPinDisabled());
              },
              child: Text(
                AppLocalizations.of(context)!.turnOff,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      final isSupported = await _biometricService.isDeviceSupported();
      if (!isSupported) {
        if (!mounted) return;
        snackBar(
          message: AppLocalizations.of(context)!.biometricNotAvailableMessage,
          messageType: MessageType.error,
        );
        return;
      }

      final authenticated = await _biometricService.authenticate();
      if (!mounted) return;

      if (authenticated) {
        context.read<AuthBloc>().add(const AuthBiometricEnabled(true));
        snackBar(
          message: AppLocalizations.of(context)!.biometricEnabled,
          messageType: MessageType.success,
        );
        setState(() {}); // Refresh UI
      } else {
        snackBar(
          message: AppLocalizations.of(context)!.biometricFailed,
          messageType: MessageType.error,
        );
      }
    } else {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.disableBiometricTitle),
          content: Text(AppLocalizations.of(context)!.disableBiometricMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppLocalizations.of(context)!.disable,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      context.read<AuthBloc>().add(const AuthBiometricEnabled(false));
      snackBar(
        message: AppLocalizations.of(context)!.biometricDisabled,
        messageType: MessageType.success,
      );
      setState(() {}); // Refresh UI
    }
  }
}
