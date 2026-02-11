import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bhansa_ghar/core/bloc/mode/mode_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/theme/theme_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';
import 'package:bhansa_ghar/offline/core/constants/string.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/routes/routes.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/init/offline_main.dart';
import 'package:bhansa_ghar/offline/core/services/notification_service.dart';
import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';
import 'package:bhansa_ghar/offline/core/utils/error_builder.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/core/init/online_main.dart';
import 'package:bhansa_ghar/online/core/routes/online_routes.dart';
import 'package:bhansa_ghar/offline/core/services/pin_service.dart';
import 'package:bhansa_ghar/offline/core/services/biometric_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("WidgetsFlutterBinding initialized.");

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  debugPrint("Orientation set.");

  // Load environment variables
  await dotenv.load(fileName: ".env");
  debugPrint("Dotenv loaded.");

  // Initialize notification service
  await NotificationService().initialize();
  debugPrint("NotificationService initialized.");

  // Initialize Hive
  await Hive.initFlutter();
  debugPrint("Hive initialized.");

  // Initialize HydratedBloc
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  debugPrint("HydratedBloc storage initialized.");

  // Initialize PreferencesService early for LocalizationBloc
  final preferencesService = PreferencesService();
  await preferencesService.initialize();
  debugPrint("PreferencesService initialized.");

  // Get offline repositories (includes Hive setup)
  debugPrint("Getting offline repositories...");
  final offlineRepos = await getOfflineRepositories();
  debugPrint("Offline repositories fetched.");

  // Get online repositories
  debugPrint('Fetching online repositories...');
  final onlineRepos = await getOnlineRepositories();
  debugPrint('Online repositories fetched: ${onlineRepos.length}');

  // Custom error widget
  initializeErrorWidget();
  debugPrint("Error widget initialized.");

  runApp(
    MultiRepositoryProvider(
      providers: [...offlineRepos, ...onlineRepos],
      child: MultiBlocProvider(
        providers: [
          // LocalizationBloc must be first
          BlocProvider(
            create: (context) => LocalizationBloc(preferencesService),
          ),
          // Core blocs (ModeBloc, ThemeBloc) must be provided directly
          BlocProvider(create: (_) => ModeBloc()),
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(
            create: (context) => AuthBloc(
              pinService: context.read<PinService>(),
              biometricService: context.read<BiometricService>(),
            ),
          ),
        ],
        child: Builder(
          builder: (coreContext) {
            // This context has access to core providers
            return BlocBuilder<ModeBloc, ModeState>(
              builder: (modeContext, modeState) {
                debugPrint('App build - mode: ${modeState.mode}');

                // Conditionally provide blocs based on mode
                return MultiBlocProvider(
                  key: ValueKey(
                    modeState.mode,
                  ), // Force rebuild when mode changes
                  providers: modeState.mode == AppMode.offline
                      ? getOfflineBlocs()
                      : getOnlineBlocs(),
                  child: BlocBuilder<LocalizationBloc, LocalizationState>(
                    bloc: BlocProvider.of<LocalizationBloc>(coreContext),
                    builder: (localeContext, localeState) {
                      return BlocBuilder<ThemeBloc, ThemeState>(
                        bloc: BlocProvider.of<ThemeBloc>(coreContext),
                        builder: (themeContext, themeState) {
                          return Builder(
                            builder: (builderContext) {
                              debugPrint("Building router...");
                              // Create router based on mode - use builderContext which has access to mode-specific blocs
                              final router = modeState.mode == AppMode.online
                                  ? createOnlineRouter(builderContext)
                                  : createAppRouter(
                                      BlocProvider.of<AuthBloc>(
                                        coreContext,
                                        listen: false,
                                      ),
                                    );
                              debugPrint("Router created.");

                              return ScreenUtilInit(
                                designSize: const Size(360, 690),
                                minTextAdapt: true,
                                splitScreenMode: true,
                                builder: (screenContext, child) {
                                  debugPrint("Building MaterialApp...");
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
                                    localizationsDelegates:
                                        AppLocalizations.localizationsDelegates,
                                    supportedLocales:
                                        AppLocalizations.supportedLocales,
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}
