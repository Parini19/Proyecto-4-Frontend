import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_page.dart';
import 'features/movies/movies_page.dart';
import 'features/auth/login_page.dart';

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomePage()),
        GoRoute(path: '/movies', builder: (_, __) => const MoviesPage()),
        GoRoute(path: '/login', builder: (_, __) => LoginPage()),
      ],
    );

    return MaterialApp.router(
      title: 'Cinema Web',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: router,
    );
  }
}
