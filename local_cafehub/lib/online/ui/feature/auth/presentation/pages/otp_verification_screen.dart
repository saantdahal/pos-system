import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'dart:async';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? verificationCode;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.verificationCode,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _resendTimer = 120; // 2 minutes
  bool _canResend = false;
  Timer? _timer;
  bool _isDisposed = false;
  bool _controllerDisposed = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _resendTimer = 120;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) return; // Check if widget is still active

      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length == 6) {
      context.read<OnlineAuthBloc>().add(
        OtpVerificationRequested(
          email: widget.email,
          code: _otpController.text,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
    }
  }

  void _resendOtp() {
    if (_canResend) {
      context.read<OnlineAuthBloc>().add(
        ResendOtpRequested(email: widget.email),
      );
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnlineAuthBloc, OnlineAuthState>(
      listener: (context, state) {
        if (_isDisposed || !mounted) {
          return; // Prevent actions if widget is disposed
        }
        if (state is NeedsProfileCompletion) {
          context.push('/profile-completion', extra: {'email': widget.email});
        } else if (state is Authenticated) {
          context.go('/dashboard');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is OtpResent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Email Verification')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter the verification code sent to your email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.verificationCode != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Dev Code: ${widget.verificationCode}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 30),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                autoDisposeControllers: false,
                onChanged: (value) {},
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey[200],
                  selectedFillColor: Colors.blue[50],
                ),
              ),
              const SizedBox(height: 30),
              BlocBuilder<OnlineAuthBloc, OnlineAuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Verify Code'),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _canResend ? _resendOtp : null,
                child: Text(
                  _canResend ? 'Resend OTP' : 'Resend OTP in ${_resendTimer}s',
                  style: TextStyle(
                    color: _canResend ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    if (!_controllerDisposed) {
      _otpController.dispose();
      _controllerDisposed = true;
    }
    super.dispose();
  }
}
