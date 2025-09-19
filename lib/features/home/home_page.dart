import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/config.dart';
import 'package:go_router/go_router.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(apiClientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cinema Web')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('API: ${AppConfig.apiBaseUrl}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  try {
                    final h = await api.health();
                    if (!context.mounted) return;
                    showDialog(context: context, builder: (_) =>
                      AlertDialog(title: const Text('Health'), content: Text(h.toString())));
                  } catch (_) {
                    if (!context.mounted) return;
                    showDialog(context: context, builder: (_) =>
                      const AlertDialog(title: Text('Health'), content: Text('Error llamando /health')));
                  }
                },
                child: const Text('Probar /health'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.go('/movies'),
                child: const Text('Ver películas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
