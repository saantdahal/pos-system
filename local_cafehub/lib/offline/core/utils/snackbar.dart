import 'package:flutter/material.dart';

enum MessageType { error, success }

SnackBar snackBar({
  required String message,
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
  Duration? duration,
}) {
  Widget? effectiveIcon;
  Color? effectiveBackgroundColor;

  if (messageType != null) {
    switch (messageType) {
      case MessageType.error:
        effectiveIcon = const Icon(Icons.error, color: Colors.white);
        effectiveBackgroundColor = Colors.red;
        break;
      case MessageType.success:
        effectiveIcon = const Icon(Icons.check_circle, color: Colors.white);
        effectiveBackgroundColor = Colors.green;
        break;
    }
  } else {
    effectiveIcon = icon;
    effectiveBackgroundColor = backgroundColor;
  }

  return SnackBar(
    padding: EdgeInsets.all(10),
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: [
        if (effectiveIcon != null) effectiveIcon,
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: effectiveBackgroundColor,
    duration: duration ?? const Duration(seconds: 3),
  );
}

void showSnackBar(
  BuildContext context,
  String message, {
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    snackBar(
      message: message,
      messageType: messageType,
      icon: icon,
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}
