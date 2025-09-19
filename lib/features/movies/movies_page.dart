import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

class MoviesPage extends ConsumerStatefulWidget {
  const MoviesPage({super.key});
  @override
  ConsumerState<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends ConsumerState<MoviesPage> {
  List<MovieDto>? movies;
  String? error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final api = ApiClient();
      final data = await api.getMovies();
      setState(() => movies = data);
    } catch (_) {
      setState(() => error = 'Error cargando películas');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (error != null) {body = Center(child: Text(error!));}
    else if (movies == null) {body = const Center(child: CircularProgressIndicator());}
    else if (movies!.isEmpty) {body = const Center(child: Text('Sin datos'));}
    else {
      body = ListView.separated(
        itemCount: movies!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final m = movies![i];
          return ListTile(leading: const Icon(Icons.movie), title: Text(m.title), subtitle: Text('${m.year}'));
        },
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Películas')), body: body);
  }
}
