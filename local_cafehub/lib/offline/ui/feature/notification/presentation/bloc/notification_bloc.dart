import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/domain/repositories/order_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/domain/repositories/notification_repository.dart';
import '../../data/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/services/tts_service.dart';
import 'package:flutter/material.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final OrderRepository _orderRepository;
  final NotificationRepository _notificationRepository;
  final LocalizationBloc _localizationBloc;
  final TtsService _ttsService;
  StreamSubscription? _orderSubscription;
  StreamSubscription? _serverNotificationSubscription;

  NotificationBloc({
    required OrderRepository orderRepository,
    required NotificationRepository notificationRepository,
    required LocalizationBloc localizationBloc,
    required TtsService ttsService,
    ServerBloc? serverBloc,
  }) : _orderRepository = orderRepository,
       _notificationRepository = notificationRepository,
       _localizationBloc = localizationBloc,
       _ttsService = ttsService,
       super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ClearNotification>(_onClearNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<ServerNotificationReceived>(_onServerNotificationReceived);
    on<NewOrderNotification>(_onNewOrderNotification);

    _orderSubscription = _orderRepository.onOrderAdded.listen((order) {
      add(NewOrderNotification(order));
    });

    // Listen to ServerBloc's order notification stream
    if (serverBloc != null) {
      debugPrint('[NotificationBloc] ServerBloc provided, setting up listener');
      _serverNotificationSubscription = serverBloc.onOrderNotification.listen((
        event,
      ) {
        add(
          ServerNotificationReceived(
            title: event['title'] ?? 'New Order',
            body: event['body'] ?? '',
            orderId: event['orderId'],
          ),
        );
      });
    }
  }

  Future<void> _onServerNotificationReceived(
    ServerNotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    final localizations = _getLocalizations();

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: localizations.newOrder,
      message: event.body,
      timestamp: DateTime.now(),
      type: NotificationType.order,
      isRead: false,
      orderId: event.orderId,
    );

    await _notificationRepository.addNotification(notification);

    // Announce via TTS
    await _announceNotification(notification.message);

    // Reload notifications to update the state
    add(LoadNotifications());
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    _serverNotificationSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      // Load notifications from repository
      final notifications = await _notificationRepository.getNotifications();
      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onNewOrderNotification(
    NewOrderNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final localizations = _getLocalizations();
    String tableNumber = event.order.tableNumber ?? localizations.unknownTable;

    // Remove "Table" prefix if present to avoid redundancy like "Table Table 2"
    if (tableNumber.trim().toLowerCase().startsWith('table')) {
      tableNumber = tableNumber.replaceAll(
        RegExp(r'^Table\s*', caseSensitive: false),
        '',
      );
    }

    final itemsList = event.order.items
        .map((item) => '${item.quantity}x ${item.name}')
        .join(', ');

    final message = localizations.tableOrderMessage(tableNumber, itemsList);
    final announcement = localizations.newOrderAnnouncement(
      tableNumber,
      itemsList,
    );

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: localizations.newOrderReceived,
      message: message,
      timestamp: DateTime.now(),
      type: NotificationType.order,
      isRead: false,
    );

    // Persist notification to repository
    await _notificationRepository.addNotification(notification);

    // Announce via TTS
    await _announceNotification(announcement);

    // Update state with new notification
    final updatedNotifications = [notification, ...state.notifications];
    emit(state.copyWith(notifications: updatedNotifications));
  }

  Future<void> _announceNotification(String message) async {
    final locale = _localizationBloc.state.locale;
    await _ttsService.setLanguage(locale.languageCode);
    await _ttsService.speak(message);
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Persist to repository
    await _notificationRepository.markAsRead(event.notificationId);

    // Update state
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == event.notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Persist to repository
    await _notificationRepository.markAllAsRead();

    // Update state
    final updatedNotifications = state.notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }

  Future<void> _onClearNotification(
    ClearNotification event,
    Emitter<NotificationState> emit,
  ) async {
    // Update state
    final updatedNotifications = state.notifications
        .where((notification) => notification.id != event.notificationId)
        .toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Persist to repository
    await _notificationRepository.clearAll();

    // Update state
    emit(state.copyWith(notifications: []));
  }

  /// Helper method to get localized strings based on current locale
  AppLocalizations _getLocalizations() {
    final locale = _localizationBloc.state.locale;
    return lookupAppLocalizations(locale);
  }
}
