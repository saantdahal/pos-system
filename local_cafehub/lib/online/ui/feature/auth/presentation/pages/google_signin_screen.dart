import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_state.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnlineAuthBloc, OnlineAuthState>(
      listener: (context, state) {
        if (state is NeedsOtpVerification) {
          context.push(
            '/otp-verification',
            extra: {'email': state.email, 'code': state.verificationCode},
          );
        } else if (state is NeedsProfileCompletion) {
          context.push('/profile-completion');
        } else if (state is Authenticated) {
          context.go('/dashboard');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Admin Login')),
        body: Center(
          child: BlocBuilder<OnlineAuthBloc, OnlineAuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const CircularProgressIndicator();
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to BhansaGhar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('Please sign in to manage your restaurant'),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      context.read<OnlineAuthBloc>().add(
                        GoogleLoginRequested(),
                      );
                    },
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
