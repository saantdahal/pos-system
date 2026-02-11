import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/pin_entry_widget.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = '';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPinVerifiedSuccess) {
          context.go('/'); // Navigate to home on success
        } else if (state is AuthFailure) {
          setState(() {
            _errorMessage = state.message;
            _pin = '';
          });
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // Optionally show a message or just do nothing
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: PinEntryWidget(
                      pin: _pin,
                      title: AppLocalizations.of(context)!.welcomeBack,
                      subtitle: AppLocalizations.of(context)!.enterPinToLogin,
                      errorMessage: _errorMessage,
                      onNumberPressed: (number) {
                        if (_pin.length < 4) {
                          setState(() {
                            _errorMessage = null; // Clear error on new input
                            _pin += number;
                            if (_pin.length == 4) {
                              // Verify PIN via Bloc
                              context.read<AuthBloc>().add(
                                AuthPinVerified(_pin),
                              );
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
