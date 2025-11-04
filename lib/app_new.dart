import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/config.dart';

// Temporary simple app while we build the UI
// We'll replace routes with proper navigation later
class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
      //routes: {
      //  '/': (context) => const HomePage(),
      //  // Add more routes as we build pages
      //},
    );
  }
}

// Temporary HomePage to showcase the design system
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema App'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido a Cinema',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Sistema de gestión de cine moderno',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            // We'll add navigation buttons here
          ],
        ),
      ),
    );
  }
}
