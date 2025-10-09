import 'package:flutter/material.dart';
import 'theme1.dart' as brown_theme;
import 'theme2.dart' as blue_theme;
import '../providers/providers.dart';

class ThemeManager {
  static ThemeData getLightTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.brown:
        return brown_theme.MaterialTheme(ThemeData.light().textTheme).light();
      case AppThemeType.blue:
        return blue_theme.MaterialTheme(ThemeData.light().textTheme).light();
    }
  }

  static ThemeData getDarkTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.brown:
        return brown_theme.MaterialTheme(ThemeData.dark().textTheme).dark();
      case AppThemeType.blue:
        return blue_theme.MaterialTheme(ThemeData.dark().textTheme).dark();
    }
  }

  static String getThemeName(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.brown:
        return 'Brown Theme';
      case AppThemeType.blue:
        return 'Blue Theme';
    }
  }

  static Color getThemePreviewColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.brown:
        return const Color(0xff8f4c38);
      case AppThemeType.blue:
        return const Color(0xff415f91);
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
      case 'excellent':
        return const Color(0xFF29B6F6);
      case 'warning':
      case 'moderate':
        return const Color(0xFFF59E0B);
      case 'critical':
      case 'poor':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF1565C0);
    }
  }
}