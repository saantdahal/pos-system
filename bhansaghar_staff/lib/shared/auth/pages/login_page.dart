import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import 'package:bhansaghar_staff/core/models/auth_models.dart';
import 'package:bhansaghar_staff/shared/auth/widgets/google_login_button.dart';
import 'package:bhansaghar_staff/shared/auth/widgets/qr_scan_button.dart';
import 'package:bhansaghar_staff/shared/auth/widgets/login_header_section.dart';
import 'package:bhansaghar_staff/shared/auth/widgets/login_footer_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else if (state is AuthAuthenticated) {
            setState(() => _isLoading = false);
            final user = state.user;
            if (user.role == UserRole.waiter) {
              context.go('/waiter');
            } else if (user.role == UserRole.kitchen) {
              context.go('/kitchen');
            } else {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid user role. Access denied.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is AuthError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // Header Section
                  const LoginHeaderSection(),
                  SizedBox(height: 48.h),
                  // Google Login Button
                  GoogleLoginButton(isLoading: _isLoading),
                  SizedBox(height: 12.h),
                  // QR Scan Button (opens scanner modal with gallery option inside)
                  QRScanButton(isLoading: _isLoading),
                  SizedBox(height: 24.h),
                  // Footer Section
                  LoginFooterSection(
                    onHelpPressed: () {
                      // Show help dialog
                    },
                    onContactAdminPressed: () {
                      // Contact admin
                    },
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
