import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  // Static colors that don't change with theme:
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const red = Colors.red;
  static const grey = Colors.grey;
  static const blue = Colors.blue;
  static const orange = Colors.orange;
  static const transparent = Colors.transparent;
  static const green = Colors.green;
  static const cyan = Colors.cyan;

  // Dark theme specific colors:
  static const backgroundDark = Color(0xFF1A1D2E);
  static const cardBackgroundDark = Color(0xFF2D3142);
  static const cardIconBgDark = Color(0xFF3D2E26);
  static const dialogBackgroundDark = Color(0xFF1E2A3A);
  static const textFieldDark = Color(0xFF2C3E50);
  static const notificationCardActiveBgDark = Color(0xFF2C2C2E);
  static const notificationCardInactiveBgDark = Color(0xFF3A3A3C);

  // Light theme specific colors:
  static const backgroundLight = Color(0xFFF5F5F5);
  static const cardBackgroundLight = Color(0xFFFFFFFF);
  static const cardIconBgLight = Color(0xFFFFF3E0);
  static const dialogBackgroundLight = Color(0xFFFFFFFF);
  static const textFieldLight = Color(0xFFF5F5F5);
  static const notificationCardActiveBgLight = Color(0xFFE3F2FD);
  static const notificationCardInactiveBgLight = Color(0xFFF5F5F5);

  // Gradient colors (work in both themes):
  static const glanceCardGradientStart = Color(0xFF6C63FF);
  static const glanceCardGradientEnd = Color(0xFF5A52D5);

  // Accent colors (work in both themes):
  static const cardIcon = Color(0xFFFF6B35);
  static const categoryIcon = Color(0xFF6C63FF);
  static const brandAccent = Color(0xFF6C7EFF);
  static const pinPadBackground = Color(0xFF2C3142);

  // Theme-aware color getters
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardBackgroundDark
        : cardBackgroundLight;
  }

  static Color getCardIconBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardIconBgDark
        : cardIconBgLight;
  }

  static Color getDialogBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dialogBackgroundDark
        : dialogBackgroundLight;
  }

  static Color getTextField(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textFieldDark
        : textFieldLight;
  }

  static Color getNotificationCardActiveBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? notificationCardActiveBgDark
        : notificationCardActiveBgLight;
  }

  static Color getNotificationCardInactiveBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? notificationCardInactiveBgDark
        : notificationCardInactiveBgLight;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? white : black;
  }

  static Color getSubtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? grey.shade400
        : Color.fromARGB(255, 191, 188, 188);
  }
}

class AppTheme {
  // For light theme:
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.blue,
        secondary: AppColors.orange,
        surface: AppColors.cardBackgroundLight,
        // background: AppColors.backgroundLight, // Deprecated, using scaffoldBackgroundColor instead
        error: AppColors.red,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        // onBackground: AppColors.black, // Deprecated, using onSurface instead
        onError: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackgroundLight,
        elevation: 2,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.black,
        displayColor: AppColors.black,
      ),
      iconTheme: IconThemeData(color: AppColors.black),
    );
  }

  // For dark theme:
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.blue,
        secondary: AppColors.orange,
        surface: AppColors.cardBackgroundDark,
        // background: AppColors.backgroundDark, // Deprecated, using scaffoldBackgroundColor instead
        error: AppColors.red,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        // onBackground: AppColors.white, // Deprecated, using onSurface instead
        onError: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackgroundDark,
        elevation: 2,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
      iconTheme: IconThemeData(color: AppColors.white),
    );
  }

  // Custom text style with responsive sizing
  static TextStyle primaryTextStyle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 16.sp : (screenWidth < 1200 ? 18 : 20);
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.normal,
    );
  }
}
