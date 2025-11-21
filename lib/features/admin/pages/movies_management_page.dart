import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/services/movies_service.dart';

class MoviesManagementPage extends StatefulWidget {
  const MoviesManagementPage({super.key});

  @override
  State<MoviesManagementPage> createState() => _MoviesManagementPageState();
}

class _MoviesManagementPageState extends State<MoviesManagementPage> {
  List<MovieModel> _movies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final MoviesService _moviesService = MoviesService();

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('📽️ Cargando películas desde el backend...');
      final movies = await _moviesService.getAllMovies();
      print('📽️ Películas cargadas: ${movies.length}');
      
      setState(() {
        _movies = movies;
        _filteredMovies = movies;
        _isLoading = false;
      });
      
      if (movies.isEmpty) {
        print('⚠️ No se encontraron películas en el backend');
      }
    } catch (e) {
      print('❌ Error cargando películas: $e');
      setState(() {
        _error = 'Error cargando películas del servidor: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testBackendConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 16),
            Text('Probando conexión con el backend...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final movies = await _moviesService.getAllMovies();
      ScaffoldMessenger.of(context).clearSnackBars();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Resultado de Conexión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Backend conectado exitosamente'),
              SizedBox(height: 8),
              Text('🎬 Películas encontradas: ${movies.length}'),
              if (movies.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('📋 Ejemplos:'),
                ...movies.take(3).map((movie) => Padding(
                  padding: EdgeInsets.only(left: 16, top: 4),
                  child: Text('• ${movie.title}'),
                )),
              ],
              SizedBox(height: 8),
              Text('🌐 URL: https://localhost:7238/api/movies/get-all-movies'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
            if (movies.isEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddEditDialog(context, Theme.of(context).brightness == Brightness.dark);
                },
                child: Text('Agregar Primera Película'),
              ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error de Conexión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❌ No se pudo conectar al backend'),
              SizedBox(height: 8),
              Text('🔍 Error: $e'),
              SizedBox(height: 8),
              Text('🛠️ Verifica que:'),
              Text('• El backend esté ejecutándose en https://localhost:7238'),
              Text('• No haya problemas de CORS'),
              Text('• El certificado SSL sea válido'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadMovies();
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }
  }

  void _filterMovies(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMovies = _movies;
      } else {
        _filteredMovies = _movies
            .where((movie) =>
                movie.title.toLowerCase().contains(query.toLowerCase()) ||
                movie.genre.toLowerCase().contains(query.toLowerCase()) ||
                (movie.director?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Gestión de Películas',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _testBackendConnection,
            tooltip: 'Probar Conexión Backend',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMovies,
            tooltip: 'Actualizar',
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar (when movies are loaded)
          if (_movies.isNotEmpty && !_isLoading) _buildStatsBar(isDark),
          
          // Search and Add Bar
          Container(
            padding: AppSpacing.pagePadding,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar películas...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterMovies,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                CinemaButton(
                  text: 'Nueva Película',
                  icon: Icons.add,
                  onPressed: () => _showAddEditDialog(context, isDark),
                ),
              ],
            ),
          ),

          // Movies Grid
          Expanded(
            child: _buildMoviesContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesContent(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMovies,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No hay películas en el servidor\n\nAsegúrate de que el backend esté ejecutándose\ny tenga películas en la base de datos.'
                  : 'No se encontraron películas\nque coincidan con "$_searchQuery"',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _filterMovies(''),
                child: const Text('Ver todas las películas'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: AppSpacing.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.55, // Adjusted for standard movie poster ratio (2:3.6)
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: _filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];
        return _buildMovieCard(movie, isDark);
      },
    );
  }

  Widget _buildMovieCard(MovieModel movie, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Movie Poster
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLG),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLG),
                ),
                child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                    ? Image.network(
                        movie.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.3),
                                AppColors.secondary.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.movie,
                              size: 64,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.secondary.withOpacity(0.2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.movie,
                            size: 64,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Movie Info
          Padding(
            padding: AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  movie.genre,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                    SizedBox(width: 4),
                    Text(
                      movie.duration,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      movie.rating,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showAddEditDialog(context, isDark, movie: movie),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        ),
                        child: Text('Editar'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    IconButton(
                      icon: Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _showDeleteDialog(context, movie),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, bool isDark, {MovieModel? movie}) {
    final titleController = TextEditingController(text: movie?.title ?? '');
    final genreController = TextEditingController(text: movie?.genre ?? '');
    final durationController = TextEditingController(
      text: movie?.duration.replaceAll(' min', '') ?? '',
    );
    final descriptionController = TextEditingController(text: movie?.description ?? '');
    final directorController = TextEditingController(text: movie?.director ?? '');
    final yearController = TextEditingController(text: movie?.year ?? '');
    final posterUrlController = TextEditingController(text: movie?.posterUrl ?? '');
    final ratingController = TextEditingController(text: movie?.rating ?? '');
    final classificationController = TextEditingController(text: movie?.classification ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          movie == null ? 'Nueva Película' : 'Editar Película',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CinemaTextField(
                  label: 'Título',
                  controller: titleController,
                  hint: 'Nombre de la película',
                  prefixIcon: Icons.title,
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'Género',
                  controller: genreController,
                  hint: 'Acción, Drama, etc.',
                  prefixIcon: Icons.category,
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'Duración (minutos)',
                  controller: durationController,
                  hint: '120',
                  prefixIcon: Icons.access_time,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'Año',
                  controller: yearController,
                  hint: '2024',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'Director',
                  controller: directorController,
                  hint: 'Nombre del director',
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'URL del Poster',
                  controller: posterUrlController,
                  hint: 'https://ejemplo.com/poster.jpg',
                  prefixIcon: Icons.image,
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'Rating',
                  controller: ratingController,
                  hint: '8.5',
                  prefixIcon: Icons.star,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'Clasificación',
                  controller: classificationController,
                  hint: 'PG-13, R, PG, etc.',
                  prefixIcon: Icons.badge,
                ),
                SizedBox(height: AppSpacing.md),
                CinemaTextField(
                  label: 'Descripción',
                  controller: descriptionController,
                  hint: 'Sinopsis de la película',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          CinemaButton(
            text: movie == null ? 'Agregar' : 'Guardar',
            onPressed: () async {
              // Validate required fields
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('El título es requerido'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(context); // Close dialog first

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 16),
                      Text(movie == null ? 'Creando película...' : 'Actualizando película...'),
                    ],
                  ),
                  duration: Duration(seconds: 30),
                ),
              );

              try {
                // Create MovieModel from form data
                final newMovie = MovieModel(
                  id: movie?.id ?? '', // Empty for new movies, backend will generate
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  rating: ratingController.text.trim().isEmpty ? '0.0' : ratingController.text.trim(),
                  duration: '${durationController.text.trim()} min',
                  genre: genreController.text.trim(),
                  classification: classificationController.text.trim().isEmpty ? 'NR' : classificationController.text.trim(),
                  colors: ['#E6A23C', '#F56C6C', '#1A1A1A'], // Default colors
                  director: directorController.text.trim(),
                  cast: null,
                  year: yearController.text.trim(),
                  showtimes: null,
                  trailer: null,
                  posterUrl: posterUrlController.text.trim(),
                );

                bool success;
                if (movie == null) {
                  // Create new movie
                  success = await _moviesService.createMovie(newMovie);
                } else {
                  // Update existing movie
                  success = await _moviesService.updateMovie(newMovie);
                }

                // Clear loading snackbar
                ScaffoldMessenger.of(context).clearSnackBars();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        movie == null
                            ? 'Película creada exitosamente'
                            : 'Película actualizada exitosamente',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadMovies(); // Refresh the list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        movie == null
                            ? 'Error al crear la película'
                            : 'Error al actualizar la película',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers when dialog closes
      titleController.dispose();
      genreController.dispose();
      durationController.dispose();
      descriptionController.dispose();
      directorController.dispose();
      yearController.dispose();
      posterUrlController.dispose();
      ratingController.dispose();
      classificationController.dispose();
    });
  }

  void _showDeleteDialog(BuildContext context, MovieModel movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Película'),
        content: Text('¿Estás seguro que deseas eliminar "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              
              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 16),
                      Text('Eliminando película...'),
                    ],
                  ),
                  duration: Duration(seconds: 30),
                ),
              );

              try {
                final success = await _moviesService.deleteMovie(movie.id);
                
                // Clear the loading snackbar
                ScaffoldMessenger.of(context).clearSnackBars();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Película eliminada exitosamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadMovies(); // Refresh the list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar la película'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(bool isDark) {
    final totalMovies = _movies.length;
    final filteredCount = _filteredMovies.length;
    final genres = _movies.map((movie) => movie.genre).toSet().length;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusMD,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.movie_outlined,
            label: 'Total',
            value: '$totalMovies',
            color: AppColors.primary,
          ),
          _buildStatItem(
            icon: Icons.visibility,
            label: 'Mostrando',
            value: '$filteredCount',
            color: AppColors.success,
          ),
          _buildStatItem(
            icon: Icons.category,
            label: 'Géneros',
            value: '$genres',
            color: AppColors.warning,
          ),
          _buildStatItem(
            icon: Icons.cloud_done,
            label: 'Estado',
            value: 'Conectado',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
