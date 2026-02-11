import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Trigger biometric authentication on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometric();
    });
  }

  void _triggerBiometric() {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });
    context.read<AuthBloc>().add(AuthBiometricRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPinVerifiedSuccess) {
          // Navigate to home on success
          context.go('/');
        } else if (state is AuthFailure) {
          // Show error inline
          setState(() {
            _errorMessage = state.message;
          });
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // Optionally show a message
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Coffee Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.getCardBackground(context),
                      ),
                      child: const Icon(
                        Icons.coffee,
                        size: 50,
                        color: AppColors.categoryIcon,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Title
                    Text(
                      AppLocalizations.of(context)!.adminAccess,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      AppLocalizations.of(context)!.confirmIdentityToContinue,
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Fingerprint Icon
                    GestureDetector(
                      onTap: _triggerBiometric,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blue.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          size: 70,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Tap to Unlock
                    Text(
                      AppLocalizations.of(context)!.tapToUnlock,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Biometric subtitle
                    Text(
                      AppLocalizations.of(context)!.useFingerprintOrFaceId,
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Error Message with Retry
                    if (_errorMessage != null)
                      Column(
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _triggerBiometric,
                            child: Text(
                              AppLocalizations.of(context)!.retry,
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 60),
                    // Use PIN / Password Button
                    TextButton(
                      onPressed: () {
                        context.go('/pin-login');
                      },
                      child: Text(
                        AppLocalizations.of(context)!.usePinPassword,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
