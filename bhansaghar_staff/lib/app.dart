import 'package:bhansaghar_staff/core/api/interceptors/auth_interceptor.dart';
import 'package:bhansaghar_staff/core/routes/app_router.dart';
import 'package:bhansaghar_staff/core/theme/bloc/theme_bloc.dart';
import 'package:bhansaghar_staff/core/theme/theme.dart';
import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    // Create router after context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _router = createRouter(context, navigatorKey);
        });
      }
    });
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Show loading while router is being initialized
        if (_router == null) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp.router(
          title: 'Bhansaghar Staff',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
