import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_entry_widget.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_setup_confirm_step.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_setup_input_step.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_setup_success_step.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  int _currentStep =
      0; // 0: Verify Old, 1: Enter New, 2: Confirm New, 3: Success
  String _oldPin = '';
  String _newPin = '';
  String _confirmPin = '';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPinVerifiedSuccess) {
          // Old PIN verified, move to next step
          setState(() {
            _currentStep = 1;
            _oldPin = ''; // Clear old PIN for security
            _errorMessage = null;
          });
        } else if (state is AuthPinSetSuccess) {
          // New PIN set, show success
          setState(() {
            _currentStep = 3;
          });
        } else if (state is AuthFailure) {
          if (_currentStep == 0) {
            setState(() {
              _errorMessage = state.message;
              _oldPin = '';
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.getTextColor(context),
            ),
            onPressed: () {
              if (_currentStep > 0 && _currentStep < 3) {
                setState(() {
                  _currentStep--;
                  if (_currentStep == 0) _oldPin = '';
                  if (_currentStep == 1) _newPin = '';
                });
              } else {
                context.pop();
              }
            },
          ),
        ),
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
        return PinEntryWidget(
          key: const ValueKey('verify_old_pin'),
          pin: _oldPin,
          title: AppLocalizations.of(context)!.verifyOldPin,
          subtitle: AppLocalizations.of(context)!.enterCurrentPin,
          errorMessage: _errorMessage,
          onNumberPressed: (number) {
            if (_oldPin.length < 4) {
              setState(() {
                _errorMessage = null; // Clear error on new input
                _oldPin += number;
                if (_oldPin.length == 4) {
                  context.read<AuthBloc>().add(AuthPinVerified(_oldPin));
                }
              });
            }
          },
          onDeletePressed: () {
            if (_oldPin.isNotEmpty) {
              setState(() {
                _oldPin = _oldPin.substring(0, _oldPin.length - 1);
              });
            }
          },
        );
      case 1:
        return PinSetupInputStep(
          key: const ValueKey('enter_new_pin'),
          pin: _newPin,
          onNumberPressed: (number) {
            if (_newPin.length < 4) {
              setState(() {
                _newPin += number;
                if (_newPin.length == 4) {
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
            if (_newPin.isNotEmpty) {
              setState(() {
                _newPin = _newPin.substring(0, _newPin.length - 1);
              });
            }
          },
        );
      case 2:
        return PinSetupConfirmStep(
          key: const ValueKey('confirm_new_pin'),
          confirmPin: _confirmPin,
          onNumberPressed: (number) {
            if (_confirmPin.length < 4) {
              setState(() {
                _confirmPin += number;
                if (_confirmPin.length == 4) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (!mounted) return;
                    if (_newPin == _confirmPin) {
                      context.read<AuthBloc>().add(AuthPinSet(_newPin));
                    } else {
                      snackBar(
                        messageType: MessageType.error,
                        message: AppLocalizations.of(context)!.pinsDoNotMatch,
                      );

                      setState(() {
                        _confirmPin = '';
                      });
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
          key: const ValueKey('success'),
          onContinue: () {
            context.pop(); // Return to settings
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
