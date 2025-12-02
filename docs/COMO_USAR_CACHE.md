# 🚀 Cómo Usar el Sistema de Caché con Riverpod

## 📋 Qué es y para qué sirve

El sistema de caché implementado reduce las lecturas de Firestore en un **95-98%** al mantener datos en memoria.

**Antes (sin caché):**
- Cada vez que entras a "Gestión de Películas" → 20 lecturas de Firestore
- Cada vez que cambias de página → 20 lecturas más
- **Total diario con 50 navegaciones**: ~1,000 lecturas

**Ahora (con caché):**
- Primera vez que entras → 20 lecturas (carga y almacena en memoria)
- Próximas 49 veces → 0 lecturas (usa datos en memoria)
- **Total diario**: ~20 lecturas ✅ **Reducción: 98%**

---

## 🔧 Cómo Usar el Caché en tus Páginas

### Opción 1: Usar el Provider Cacheado (Recomendado)

**Antes (sin caché):**
```dart
class MoviesManagementPage extends StatefulWidget {
  @override
  State<MoviesManagementPage> createState() => _MoviesManagementPageState();
}

class _MoviesManagementPageState extends State<MoviesManagementPage> {
  final MoviesService _moviesService = MoviesService();
  List<MovieModel> _movies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies(); // ← Esto llama al backend CADA VEZ
  }

  Future<void> _loadMovies() async {
    final movies = await _moviesService.getAllMovies(); // ← Lectura de Firestore
    setState(() {
      _movies = movies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) => MovieCard(movie: _movies[index]),
    );
  }
}
```

**Ahora (con caché) usando ConsumerWidget:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cached_data_providers.dart';

class MoviesManagementPage extends ConsumerWidget {
  const MoviesManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lee del caché - solo hace la petición HTTP UNA VEZ
    final moviesAsyncValue = ref.watch(cachedMoviesProvider);

    return moviesAsyncValue.when(
      // Cargando (solo la primera vez)
      loading: () => Center(child: CircularProgressIndicator()),

      // Error
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),

      // Datos listos (de caché o recién cargados)
      data: (movies) {
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => MovieCard(movie: movies[index]),
        );
      },
    );
  }
}
```

### Opción 2: Usar con StatefulWidget + Consumer

```dart
class MoviesManagementPage extends StatefulWidget {
  const MoviesManagementPage({super.key});

  @override
  State<MoviesManagementPage> createState() => _MoviesManagementPageState();
}

class _MoviesManagementPageState extends State<MoviesManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final moviesAsyncValue = ref.watch(cachedMoviesProvider);

        return moviesAsyncValue.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (movies) {
            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) => MovieCard(movie: movies[index]),
            );
          },
        );
      },
    );
  }
}
```

---

## 🔄 Cómo Refrescar el Caché Manualmente

Cuando creas, editas o eliminas una película, debes refrescar el caché:

```dart
import '../../core/providers/cached_data_providers.dart';

class MoviesManagementPage extends ConsumerWidget {
  const MoviesManagementPage({super.key});

  Future<void> _deleteMovie(WidgetRef ref, String movieId) async {
    // 1. Eliminar del backend
    await _moviesService.deleteMovie(movieId);

    // 2. Refrescar el caché para obtener la lista actualizada
    ref.read(cacheRefreshProvider.notifier).refreshMovies();

    // ← El provider automáticamente hará una nueva petición y actualizará la UI
  }

  Future<void> _addMovie(WidgetRef ref, MovieModel newMovie) async {
    // 1. Agregar al backend
    await _moviesService.addMovie(newMovie);

    // 2. Refrescar el caché
    ref.read(cacheRefreshProvider.notifier).refreshMovies();
  }

  // Para refrescar TODOS los datos de una vez (películas + funciones)
  void _refreshAll(WidgetRef ref) {
    ref.read(cacheRefreshProvider.notifier).refreshAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Botón de refresh manual
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(cacheRefreshProvider.notifier).refreshMovies(),
          ),
        ],
      ),
      // ... resto del código
    );
  }
}
```

---

## 📦 Providers Disponibles

### 1. `cachedMoviesProvider`
```dart
final moviesAsyncValue = ref.watch(cachedMoviesProvider);
// Tipo: AsyncValue<List<MovieModel>>
```

### 2. `cachedScreeningsProvider`
```dart
final screeningsAsyncValue = ref.watch(cachedScreeningsProvider);
// Tipo: AsyncValue<List<Screening>>
```

### 3. `cacheRefreshProvider`
```dart
// Refrescar solo películas
ref.read(cacheRefreshProvider.notifier).refreshMovies();

// Refrescar solo funciones
ref.read(cacheRefreshProvider.notifier).refreshScreenings();

// Refrescar TODO
ref.read(cacheRefreshProvider.notifier).refreshAll();
```

---

## ⚙️ Configuración de Main.dart

**Importante**: Asegúrate de que tu `main.dart` usa `ProviderScope`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope( // ← MUY IMPORTANTE
      child: MyApp(),
    ),
  );
}
```

---

## 🎯 Ejemplo Completo: Gestión de Películas con Caché

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cached_data_providers.dart';
import '../../core/models/movie_model.dart';
import '../../core/services/movies_service.dart';

class MoviesManagementPage extends ConsumerStatefulWidget {
  const MoviesManagementPage({super.key});

  @override
  ConsumerState<MoviesManagementPage> createState() => _MoviesManagementPageState();
}

class _MoviesManagementPageState extends ConsumerState<MoviesManagementPage> {
  final MoviesService _moviesService = MoviesService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final moviesAsyncValue = ref.watch(cachedMoviesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Películas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refrescar datos',
            onPressed: () {
              ref.read(cacheRefreshProvider.notifier).refreshMovies();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar película',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Lista de películas (desde caché)
          Expanded(
            child: moviesAsyncValue.when(
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando películas desde backend...'),
                    Text('(Esto solo pasa una vez)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: $error'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(cacheRefreshProvider.notifier).refreshMovies();
                      },
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (movies) {
                // Filtrar películas por búsqueda
                final filteredMovies = _searchQuery.isEmpty
                    ? movies
                    : movies.where((m) =>
                        m.title.toLowerCase().contains(_searchQuery)).toList();

                if (filteredMovies.isEmpty) {
                  return Center(child: Text('No se encontraron películas'));
                }

                return ListView.builder(
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = filteredMovies[index];
                    return ListTile(
                      title: Text(movie.title),
                      subtitle: Text('Rating: ${movie.rating}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editMovie(movie),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteMovie(movie.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addNewMovie,
      ),
    );
  }

  Future<void> _deleteMovie(String movieId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar esta película?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _moviesService.deleteMovie(movieId);

        // ⭐ Refrescar caché después de eliminar
        ref.read(cacheRefreshProvider.notifier).refreshMovies();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Película eliminada')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editMovie(MovieModel movie) {
    // TODO: Abrir formulario de edición
    // Después de editar, llamar:
    // ref.read(cacheRefreshProvider.notifier).refreshMovies();
  }

  void _addNewMovie() {
    // TODO: Abrir formulario de nueva película
    // Después de crear, llamar:
    // ref.read(cacheRefreshProvider.notifier).refreshMovies();
  }
}
```

---

## 📊 Monitoreo del Caché

Puedes ver en la consola cuándo se cargan los datos:

```
🎬 [CACHE] Loading movies from backend... (this should happen ONCE)
🎬 [CACHE] Loaded 20 movies - now cached in memory
```

Si ves este mensaje más de una vez sin que hayas refrescado manualmente, hay un problema.

---

## ⚠️ Advertencias Importantes

1. **No mezclar caché con llamadas directas:**
   ```dart
   // ❌ MAL - Esto NO actualizará el caché
   final movies = await _moviesService.getAllMovies();

   // ✅ BIEN - Usa el provider cacheado
   final moviesAsyncValue = ref.watch(cachedMoviesProvider);
   ```

2. **Siempre refrescar después de modificar datos:**
   ```dart
   // Después de CREATE, UPDATE o DELETE:
   ref.read(cacheRefreshProvider.notifier).refreshMovies();
   ```

3. **No usar `ref.watch` dentro de funciones async:**
   ```dart
   // ❌ MAL
   Future<void> someFunction() async {
     final movies = ref.watch(cachedMoviesProvider); // Error!
   }

   // ✅ BIEN
   Widget build(BuildContext context, WidgetRef ref) {
     final movies = ref.watch(cachedMoviesProvider);
   }
   ```

---

## 🎉 Beneficios

✅ **Reducción del 95-98% en lecturas de Firestore**
✅ **App más rápida** (datos en memoria)
✅ **Menos costo** (menos lecturas = menos gasto)
✅ **Mejor UX** (no hay delays al navegar)
✅ **Simple de usar** (un solo provider para todos)

---

**Creado**: 28 de Noviembre, 2025
**Versión**: 1.0
