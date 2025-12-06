import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_rose.dart';
import '../theme/theme_leaves.dart';

enum AppThemeType { rose, leaves }

class ThemeNotifier extends Notifier<AppThemeType> {
  @override
  AppThemeType build() {
    return AppThemeType.rose; // Default theme
  }

  void setTheme(AppThemeType theme) {
    state = theme;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeType>(
  ThemeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final lightThemeProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(themeProvider);
  final textTheme = Typography.material2021().englishLike;

  switch (themeType) {
    case AppThemeType.rose:
      return ThemeRose(textTheme).light();
    case AppThemeType.leaves:
      return ThemeLeaves(textTheme).light();
  }
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(themeProvider);
  final textTheme = Typography.material2021().englishLike;

  switch (themeType) {
    case AppThemeType.rose:
      return ThemeRose(textTheme).theme(ThemeRose.darkScheme());
    case AppThemeType.leaves:
      return ThemeLeaves(textTheme).theme(ThemeLeaves.darkScheme());
  }
});
