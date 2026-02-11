import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/core/bloc/mode/mode_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/theme/theme_bloc.dart';
import 'package:bhansa_ghar/offline/core/constants/string.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/routes/routes.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/online/core/routes/online_routes.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap everything in a Builder to get context with provider access
    return Builder(
      builder: (ctx) {
        final localeState = ctx.watch<LocalizationBloc>().state;
        final modeState = ctx.watch<ModeBloc>().state;
        final themeState = ctx.watch<ThemeBloc>().state;

        debugPrint('MyApp build - mode: ${modeState.mode}');

        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (screenContext, child) {
            // Create router based on mode - only access AuthBloc if offline
            final GoRouter router;
            if (modeState.mode == AppMode.online) {
              router = createOnlineRouter(screenContext);
            } else {
              // Use the Builder's context (ctx) which has provider access
              final authBloc = Provider.of<AuthBloc>(ctx, listen: false);
              router = createAppRouter(authBloc);
            }

            return MaterialApp.router(
              title: appName,
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeState.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              locale: localeState.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        );
      },
    );
  }
}
