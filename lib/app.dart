import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/theme/theme_manager.dart';
import 'src/screens/dashboard_screen.dart';
import 'src/providers/providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedTheme = ref.watch(selectedThemeProvider);

    return MaterialApp(
      title: 'TRASI',
      theme: ThemeManager.getLightTheme(selectedTheme),
      darkTheme: ThemeManager.getDarkTheme(selectedTheme),
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}
