import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';

void main() {
  runApp(const ProviderScope(child: CinemaApp()));
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,        // Light mode (default)
      darkTheme: AppTheme.darkTheme,     // Dark mode
      themeMode: ThemeMode.system,       // Follows system preference
      home: const HomePage(),
    );
  }
}
