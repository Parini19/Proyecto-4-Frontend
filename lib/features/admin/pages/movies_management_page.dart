import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/widgets/image_picker_field.dart';
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
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay películas en el servidor\n\nAsegúrate de que el backend esté ejecutándose\ny tenga películas en la base de datos.'
                  : 'No se encontraron películas\nque coincidan con "$_searchQuery"',
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final crossAxisCount = isMobile ? 2 : 4;

    return GridView.builder(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 0.6 : 0.55,
        crossAxisSpacing: isMobile ? AppSpacing.sm : AppSpacing.md,
        mainAxisSpacing: isMobile ? AppSpacing.sm : AppSpacing.md,
      ),
      itemCount: _filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];
        return _buildMovieCard(movie, isDark, isMobile);
      },
    );
  }

  Widget _buildMovieCard(MovieModel movie, bool isDark, bool isMobile) {
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
            flex: isMobile ? 3 : 4,
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
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
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
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
                              size: isMobile ? 40 : 64,
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
                            size: isMobile ? 40 : 64,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Movie Info
          Padding(
            padding: isMobile
                ? EdgeInsets.all(AppSpacing.sm)
                : AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.title,
                  style: (isMobile ? AppTypography.titleSmall : AppTypography.titleMedium).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  movie.genre,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: isMobile ? 10 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile) SizedBox(height: AppSpacing.xs),
                if (!isMobile)
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          movie.duration,
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          movie.rating,
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: isMobile ? AppSpacing.xs : AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showAddEditDialog(context, isDark, movie: movie),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 4 : AppSpacing.xs,
                            horizontal: isMobile ? 4 : 8,
                          ),
                        ),
                        child: Text(
                          'Editar',
                          style: TextStyle(fontSize: isMobile ? 10 : 12),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: isMobile ? 32 : 40,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: AppColors.error, size: isMobile ? 16 : 20),
                        onPressed: () => _showDeleteDialog(context, movie),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
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
    final ratingController = TextEditingController(text: movie?.rating ?? '');
    final classificationController = TextEditingController(text: movie?.classification ?? '');

    // Variable to store selected image in base64
    String? selectedPosterBase64;

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
                ImagePickerField(
                  initialImageUrl: movie?.posterUrl,
                  onImageSelected: (base64Image) {
                    selectedPosterBase64 = base64Image;
                  },
                  label: 'Poster de la Película',
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
                  posterUrl: movie?.posterUrl ?? '', // Keep existing URL if updating and no new image
                );

                bool success;
                if (movie == null) {
                  // Create new movie with optional image upload
                  success = await _moviesService.createMovie(newMovie, posterBase64: selectedPosterBase64);
                } else {
                  // Update existing movie with optional new image
                  success = await _moviesService.updateMovie(newMovie, posterBase64: selectedPosterBase64);
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
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Optimistic update: Update local state immediately
                  setState(() {
                    if (movie == null) {
                      // Add new movie
                      _movies.add(newMovie);
                    } else {
                      // Update existing movie
                      final index = _movies.indexWhere((m) => m.id == movie.id);
                      if (index != -1) {
                        _movies[index] = newMovie;
                      }
                    }
                    // Update filtered list
                    _filteredMovies = _searchQuery.isEmpty
                        ? List.from(_movies)
                        : _movies.where((m) =>
                            m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            m.genre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            (m.director?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
                          ).toList();
                  });

                  // Then refresh from backend after a delay to confirm
                  Future.delayed(Duration(milliseconds: 1500)).then((_) {
                    if (mounted) {
                      _loadMovies();
                    }
                  });
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
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Optimistic update: Remove movie from local state immediately
                  setState(() {
                    _movies.removeWhere((m) => m.id == movie.id);
                    _filteredMovies.removeWhere((m) => m.id == movie.id);
                  });

                  // Then refresh from backend after a delay to confirm
                  Future.delayed(Duration(milliseconds: 1500)).then((_) {
                    if (mounted) {
                      _loadMovies();
                    }
                  });
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
            isDark: isDark,
          ),
          _buildStatItem(
            icon: Icons.visibility,
            label: 'Mostrando',
            value: '$filteredCount',
            color: AppColors.success,
            isDark: isDark,
          ),
          _buildStatItem(
            icon: Icons.category,
            label: 'Géneros',
            value: '$genres',
            color: AppColors.warning,
            isDark: isDark,
          ),
          _buildStatItem(
            icon: Icons.cloud_done,
            label: 'Estado',
            value: 'Conectado',
            color: AppColors.success,
            isDark: isDark,
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
    required bool isDark,
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
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
