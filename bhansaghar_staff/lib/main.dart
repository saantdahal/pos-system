import 'package:bhansaghar_staff/app.dart';
import 'package:bhansaghar_staff/core/api/api_client.dart';
import 'package:bhansaghar_staff/core/api/interceptors/auth_interceptor.dart';
import 'package:bhansaghar_staff/core/repositories/auth_repository.dart';
import 'package:bhansaghar_staff/core/services/dio_service.dart';
import 'package:bhansaghar_staff/core/services/table_service.dart';
import 'package:bhansaghar_staff/core/services/websocket_service.dart';
import 'package:bhansaghar_staff/core/theme/bloc/theme_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/inventory/bloc/inventory_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/inventory/repositories/inventory_repository.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/repositories/kitchen_repository.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/activity_repository.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/log_activities/bloc/activities_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/profile_repository.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/table_repository.dart';
import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize HydratedBloc
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  // Initialize dependencies
  final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
  final dio = Dio();
  final dioService = DioService(dio, customBaseUrl: apiUrl);

  final apiClient = ApiClient(dio, baseUrl: apiUrl);

  final authRepository = AuthRepository(
    apiClient: apiClient,
    dioService: dioService,
  );

  final authBloc = AuthBloc(authRepository: authRepository);

  // Set logout callback
  dioService.logoutCallback = () {
    debugPrint('🔑 LOGOUT CALLBACK: Triggering logout');
    authBloc.add(const AuthLogoutRequested());
  };

  // Open token box for interceptor
  final tokenBox = await Hive.openBox<String>(AuthRepository.authStateBoxName);
  dio.interceptors.add(AuthInterceptor(dioService, tokenBox));

  final kitchenRepository = KitchenRepository(apiClient);
  final inventoryRepository = InventoryRepository(apiClient);
  final profileRepository = WaiterProfileRepositoryImpl(
    apiClient: apiClient,
    dioService: dioService,
  );
  final webSocketService = WebSocketService();
  final tableService = TableService(apiClient: apiClient);
  final tableRepository = WaiterTableRepositoryImpl(tableService: tableService);
  final activityRepository = ActivityRepository(dio: dio);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => apiClient),
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
        RepositoryProvider<KitchenRepository>(create: (_) => kitchenRepository),
        RepositoryProvider<InventoryRepository>(
          create: (_) => inventoryRepository,
        ),
        RepositoryProvider<WaiterProfileRepository>(
          create: (_) => profileRepository,
        ),
        RepositoryProvider<WebSocketService>(create: (_) => webSocketService),
        RepositoryProvider<WaiterTableRepository>(
          create: (_) => tableRepository,
        ),
        RepositoryProvider<ActivityRepository>(
          create: (_) => activityRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
          BlocProvider<KitchenOrdersBloc>(
            create: (context) => KitchenOrdersBloc(
              repository: kitchenRepository,
              webSocketService: webSocketService,
            ),
          ),
          BlocProvider<InventoryBloc>(
            create: (context) => InventoryBloc(inventoryRepository),
          ),
          BlocProvider<WaiterDashboardBloc>(
            create: (context) => WaiterDashboardBloc(
              waiterTableRepository: tableRepository,
              profileRepository: profileRepository,
            ),
          ),
          BlocProvider<WaiterActivitiesBloc>(
            create: (context) =>
                WaiterActivitiesBloc(activityRepository: activityRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
