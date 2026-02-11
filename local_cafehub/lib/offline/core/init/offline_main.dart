import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bhansa_ghar/offline/core/services/notification_service.dart';
import 'package:bhansa_ghar/offline/core/services/pin_service.dart';
import 'package:bhansa_ghar/offline/core/services/background_service.dart';
import 'package:bhansa_ghar/offline/core/services/biometric_service.dart';
import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';
import 'package:bhansa_ghar/offline/core/services/tts_service.dart';
import 'package:bhansa_ghar/offline/server/server_service.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/domain/menu_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/bloc/menu_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/domain/repositories/order_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/domain/repositories/category_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/qr/presentation/bloc/qr_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/bloc/notification_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/bloc/notification_event.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/data/menu_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/data/models/order_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/data/models/category.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/data/models/table.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/domain/repositories/table_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/presentation/bloc/table_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/data/notification_model.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/domain/repositories/notification_repository.dart';

import 'package:provider/single_child_widget.dart';

Future<List<SingleChildWidget>> getOfflineRepositories() async {
  // Initialize Preferences Service
  final preferencesService = PreferencesService();
  await preferencesService.initialize();

  // Initialize TTS Service
  final ttsService = TtsService();
  await ttsService.initialize(preferencesService);

  // Initialize Background Service
  try {
    await BackgroundService.initializeService();
  } catch (e) {
    debugPrint('Failed to initialize background service: $e');
  }

  // Delete old order box if it exists (migration for new price fields)
  try {
    if (await Hive.boxExists('orders')) {
      await Hive.deleteBoxFromDisk('orders');
    }
  } catch (e) {
    debugPrint('Error deleting old orders box: $e');
  }

  Hive.registerAdapter(MenuItemAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TableModelAdapter());
  Hive.registerAdapter(NotificationModelAdapter());
  Hive.registerAdapter(NotificationTypeAdapter());
  await Hive.openBox<bool>('menus');
  final authBox = await Hive.openBox('auth');

  // HydratedBloc storage initialized in online_main.dart

  return [
    RepositoryProvider<MenuRepository>(create: (context) => MenuRepository()),
    RepositoryProvider<OrderRepository>(create: (context) => OrderRepository()),
    RepositoryProvider<CategoryRepository>(
      create: (context) => CategoryRepository(),
    ),
    RepositoryProvider<TableRepository>(create: (context) => TableRepository()),
    RepositoryProvider<NotificationRepository>(
      create: (context) => NotificationRepository(),
    ),
    RepositoryProvider<PinService>(create: (context) => PinService(authBox)),
    RepositoryProvider<BiometricService>(
      create: (context) => BiometricService(authBox),
    ),
    RepositoryProvider<PreferencesService>.value(value: preferencesService),
    RepositoryProvider<TtsService>.value(value: ttsService),
    RepositoryProvider<ServerService>(
      create: (context) => ServerService(
        menuRepository: context.read<MenuRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        tableRepository: context.read<TableRepository>(),
        orderRepository: context.read<OrderRepository>(),
        notificationService: NotificationService(),
        localizationBloc: LocalizationBloc(preferencesService),
        preferencesService: preferencesService,
      ),
    ),
  ];
}

List<SingleChildWidget> getOfflineBlocs() {
  return [
    BlocProvider<ServerBloc>(
      create: (context) => ServerBloc()..add(CheckServerStatus()),
    ),
    BlocProvider<MenuBloc>(
      create: (context) =>
          MenuBloc(menuRepository: context.read<MenuRepository>()),
    ),
    BlocProvider<OrderBloc>(
      create: (context) => OrderBloc(
        orderRepository: context.read<OrderRepository>(),
        serverBloc: context.read<ServerBloc>(),
      )..add(LoadOrders()),
    ),
    BlocProvider<CategoryBloc>(
      create: (context) =>
          CategoryBloc(categoryRepository: context.read<CategoryRepository>()),
    ),
    BlocProvider<TableBloc>(
      create: (context) =>
          TableBloc(tableRepository: context.read<TableRepository>()),
    ),
    BlocProvider<QrBloc>(create: (context) => QrBloc()),
    BlocProvider<NotificationBloc>(
      create: (context) => NotificationBloc(
        orderRepository: context.read<OrderRepository>(),
        notificationRepository: context.read<NotificationRepository>(),
        localizationBloc: context.read<LocalizationBloc>(),
        serverBloc: context.read<ServerBloc>(),
        ttsService: context.read<TtsService>(),
      )..add(LoadNotifications()),
    ),
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        pinService: context.read<PinService>(),
        biometricService: context.read<BiometricService>(),
      )..add(AuthCheckRequested()),
    ),
  ];
}
