import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'features/home/home_page.dart';
import 'features/auth/login_page.dart';
import 'features/admin/pages/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AuthService().initialize();
  await ApiService().initialize();

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
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // Check if user is authenticated and redirect accordingly
    if (authService.isAuthenticated) {
      if (authService.isAdmin) {
        return const AdminDashboard();
      } else {
        return const HomePage();
      }
    } else {
      return const LoginPage();
    }
  }
}
