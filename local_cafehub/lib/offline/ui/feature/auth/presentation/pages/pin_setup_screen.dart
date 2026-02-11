import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_setup_confirm_step.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_setup_input_step.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_setup_success_step.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_setup_welcome_step.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  int _currentStep = 0;
  String _pin = '';
  String _confirmPin = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPinSetSuccess) {
          if (mounted) {
            setState(() {
              _currentStep = 3;
            });
          }
        } else if (state is AuthFailure) {
          snackBar(messageType: MessageType.error, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return PinSetupWelcomeStep(
          onGetStarted: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
      case 1:
        return PinSetupInputStep(
          pin: _pin,
          onNumberPressed: (number) {
            if (_pin.length < 4) {
              setState(() {
                _pin += number;
                if (_pin.length == 4) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    setState(() {
                      _currentStep = 2;
                    });
                  });
                }
              });
            }
          },
          onDeletePressed: () {
            if (_pin.isNotEmpty) {
              setState(() {
                _pin = _pin.substring(0, _pin.length - 1);
              });
            }
          },
        );
      case 2:
        return PinSetupConfirmStep(
          confirmPin: _confirmPin,
          onNumberPressed: (number) {
            if (_confirmPin.length < 4) {
              setState(() {
                _confirmPin += number;
                if (_confirmPin.length == 4) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (!mounted) return;
                    if (_pin == _confirmPin) {
                      // PIN matched, save it via Bloc
                      context.read<AuthBloc>().add(AuthPinSet(_pin));
                    } else {
                      // PIN doesn't match
                      if (mounted) {
                        snackBar(
                          messageType: MessageType.error,
                          message: AppLocalizations.of(context)!.pinsDoNotMatch,
                        );
                        setState(() {
                          _confirmPin = '';
                        });
                      }
                    }
                  });
                }
              });
            }
          },
          onDeletePressed: () {
            if (_confirmPin.isNotEmpty) {
              setState(() {
                _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
              });
            }
          },
        );
      case 3:
        return PinSetupSuccessStep(
          onContinue: () {
            // Navigate to home or login
            context.go('/'); // Navigate to home
          },
        );
      default:
        return PinSetupWelcomeStep(
          onGetStarted: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
    }
  }
}
