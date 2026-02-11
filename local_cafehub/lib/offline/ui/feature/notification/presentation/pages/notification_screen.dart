import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/bloc/notification_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/bloc/notification_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/bloc/notification_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/presentation/widgets/notification_card.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.notifications.isEmpty) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).iconTheme.color,
                ),
                color: AppColors.getCardBackground(context),
                onSelected: (value) {
                  if (value == 'mark_all_read') {
                    context.read<NotificationBloc>().add(MarkAllAsRead());
                  } else if (value == 'clear_all') {
                    _showClearAllDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(
                          Icons.done_all,
                          color: AppColors.getTextColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.markAllAsRead,
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, color: AppColors.red, size: 20),
                        SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.clearAll,
                          style: TextStyle(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          if (state.status == NotificationStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.red),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.errorLoadingNotifications,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ??
                        AppLocalizations.of(context)!.unknownError,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: AppColors.getSubtitleColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noNotifications,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.allCaughtUp,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final unreadCount = state.unreadCount;

          return Column(
            children: [
              // Stats Bar
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: AppColors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        unreadCount > 1
                            ? AppLocalizations.of(
                                context,
                              )!.unreadNotifications(unreadCount)
                            : AppLocalizations.of(
                                context,
                              )!.unreadNotification(unreadCount),
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              // Notifications List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return NotificationCard(
                      notification: notification,
                      onTap: () {
                        if (!notification.isRead) {
                          context.read<NotificationBloc>().add(
                            MarkAsRead(notification.id),
                          );
                        }
                      },
                      onDismiss: () {
                        context.read<NotificationBloc>().add(
                          ClearNotification(notification.id),
                        );
                        snackBar(
                          message: AppLocalizations.of(
                            context,
                          )!.notificationRemoved,
                          messageType: MessageType.success,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.getDialogBackground(context),
          title: Text(
            AppLocalizations.of(context)!.clearAllNotifications,
            style: TextStyle(color: AppColors.getTextColor(context)),
          ),
          content: Text(
            AppLocalizations.of(context)!.clearAllNotificationsConfirm,
            style: TextStyle(color: AppColors.getSubtitleColor(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: AppColors.getSubtitleColor(context)),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<NotificationBloc>().add(ClearAllNotifications());
                Navigator.pop(dialogContext);
              },
              child: Text(
                AppLocalizations.of(context)!.clearAll,
                style: const TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
