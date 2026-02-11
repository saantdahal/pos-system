import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';
import 'package:bhansa_ghar/online/core/repositories/staff_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/website_repository.dart';
import 'package:bhansa_ghar/online/core/api/website_api_client.dart';
import 'package:bhansa_ghar/online/ui/feature/website/bloc/website_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bhansa_ghar/online/core/services/dio_service.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/category_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/restaurant_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/table_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/profile_repository.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/domain/repositories/menu_repository.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/online/ui/feature/categories/presentation/bloc/category_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/restaurant_setup/bloc/restaurant_setup.dart';
import 'package:bhansa_ghar/online/ui/feature/home/presentation/bloc/dashboard_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/bloc/menu_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/tables/presentation/bloc/table_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/settings/presentation/bloc/setting_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/theme/theme_bloc.dart';
import 'package:bhansa_ghar/core/bloc/mode/mode_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/bloc/staff_bloc.dart';

import 'package:provider/single_child_widget.dart';

Future<List<SingleChildWidget>> getOnlineRepositories() async {
  // Initialize Preferences Service
  final preferencesService = PreferencesService();
  await preferencesService.initialize();

  // Initialize Hive for tokens
  await Hive.openBox<String>('auth_tokens');
  // Initialize Hive for auth state
  await Hive.openBox<String>('auth_state');

  debugPrint('Creating online repositories...');
  return [
    RepositoryProvider<DioService>(
      create: (context) {
        debugPrint('Initializing DioService...');
        final baseUrl = dotenv.env['BaseUrl'] ?? 'http://10.0.2.2:8000/api/';
        return DioService(baseUrl: baseUrl);
      },
    ),
    RepositoryProvider<PreferencesService>.value(value: preferencesService),
    RepositoryProvider<AuthRepository>(
      create: (context) {
        debugPrint('Initializing AuthRepository...');
        final dioService = context.read<DioService>();
        return AuthRepository(
          apiClient: dioService.client,
          dioService: dioService,
        );
      },
    ),
    RepositoryProvider<RestaurantRepository>(
      create: (context) {
        debugPrint('Initializing RestaurantRepository...');
        final dioService = context.read<DioService>();
        return RestaurantRepository(apiClient: dioService.client);
      },
    ),
    RepositoryProvider<CategoryRepository>(
      create: (context) {
        debugPrint('Initializing CategoryRepository...');
        final dioService = context.read<DioService>();
        return CategoryRepository(apiClient: dioService.client);
      },
    ),
    RepositoryProvider<MenuRepository>(
      create: (context) {
        debugPrint('Initializing MenuRepository...');
        final dioService = context.read<DioService>();
        return MenuRepository(dio: dioService.dio);
      },
    ),
    RepositoryProvider<TableRepository>(
      create: (context) {
        debugPrint('Initializing TableRepository...');
        final dioService = context.read<DioService>();
        return TableRepository(apiClient: dioService.client);
      },
    ),
    RepositoryProvider<StaffRepository>(
      create: (context) {
        debugPrint('Initializing StaffRepository...');
        final dioService = context.read<DioService>();
        return StaffRepository(apiClient: dioService.client);
      },
    ),
    RepositoryProvider<ProfileRepository>(
      create: (context) {
        debugPrint('Initializing ProfileRepository...');
        final dioService = context.read<DioService>();
        return ProfileRepository(apiClient: dioService.client);
      },
    ),
    RepositoryProvider<WebsiteApiClient>(
      create: (context) {
        debugPrint('Initializing WebsiteApiClient...');
        final dioService = context.read<DioService>();
        return WebsiteApiClient(dioService.dio);
      },
    ),
    RepositoryProvider<WebsiteRepository>(
      create: (context) {
        debugPrint('Initializing WebsiteRepository...');
        final apiClient = context.read<WebsiteApiClient>();
        return WebsiteRepository(apiClient);
      },
    ),
  ];
}

List<SingleChildWidget> getOnlineBlocs() {
  debugPrint('getOnlineBlocs() called');
  return [
    BlocProvider<OnlineAuthBloc>(
      create: (context) {
        debugPrint('Initializing OnlineAuthBloc...');
        final authRepo = context.read<AuthRepository>();
        return OnlineAuthBloc(authRepository: authRepo)..add(AuthStarted());
      },
    ),
    BlocProvider<RestaurantSetupBloc>(
      create: (context) {
        debugPrint('Initializing RestaurantSetupBloc...');
        final restaurantRepo = context.read<RestaurantRepository>();
        return RestaurantSetupBloc(restaurantRepository: restaurantRepo);
      },
    ),
    BlocProvider<DashboardBloc>(
      create: (context) {
        debugPrint('Initializing DashboardBloc...');
        return DashboardBloc();
      },
    ),
    BlocProvider<CategoryBloc>(
      create: (context) {
        debugPrint('Initializing CategoryBloc...');
        final categoryRepo = context.read<CategoryRepository>();
        return CategoryBloc(categoryRepository: categoryRepo);
      },
    ),
    BlocProvider<MenuBloc>(
      create: (context) {
        debugPrint('Initializing MenuBloc...');
        final menuRepo = context.read<MenuRepository>();
        return MenuBloc(menuRepository: menuRepo);
      },
    ),
    BlocProvider<TableBloc>(
      create: (context) {
        debugPrint('Initializing TableBloc...');
        final tableRepo = context.read<TableRepository>();
        return TableBloc(tableRepository: tableRepo);
      },
    ),
    BlocProvider<StaffBloc>(
      create: (context) {
        debugPrint('Initializing StaffBloc...');
        final staffRepo = context.read<StaffRepository>();
        return StaffBloc(staffRepository: staffRepo);
      },
    ),
    BlocProvider<SettingBloc>(
      create: (context) {
        debugPrint('Initializing SettingBloc...');
        final authRepo = context.read<AuthRepository>();
        final profileRepo = context.read<ProfileRepository>();
        final themeBloc = context.read<ThemeBloc>();
        final modeBloc = context.read<ModeBloc>();
        return SettingBloc(
          authRepository: authRepo,
          profileRepository: profileRepo,
          themeBloc: themeBloc,
          modeBloc: modeBloc,
        );
      },
    ),
    BlocProvider<WebsiteBloc>(
      create: (context) {
        debugPrint('Initializing WebsiteBloc...');
        final websiteRepo = context.read<WebsiteRepository>();
        return WebsiteBloc(websiteRepo);
      },
    ),
  ];
}
