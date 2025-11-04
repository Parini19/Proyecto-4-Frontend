import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/models/movie.dart';

class MoviesManagementPage extends StatefulWidget {
  const MoviesManagementPage({super.key});

  @override
  State<MoviesManagementPage> createState() => _MoviesManagementPageState();
}

class _MoviesManagementPageState extends State<MoviesManagementPage> {
  List<Movie> _movies = []; // Will be loaded from API
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    // TODO: Load from API
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
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
            icon: Icon(Icons.refresh),
            onPressed: _loadMovies,
            tooltip: 'Actualizar',
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
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
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildMoviesGrid(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesGrid(bool isDark) {
    // Mock data for demonstration
    final mockMovies = List.generate(
      8,
      (index) => {
        'title': 'Película ${index + 1}',
        'genre': ['Acción', 'Drama', 'Ciencia Ficción'][index % 3],
        'duration': 120 + (index * 10),
        'rating': 4.0 + (index % 2),
      },
    );

    return GridView.builder(
      padding: AppSpacing.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: mockMovies.length,
      itemBuilder: (context, index) {
        final movie = mockMovies[index];
        return _buildMovieCard(movie, isDark);
      },
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie, bool isDark) {
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
          // Movie Poster Placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLG),
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

          // Movie Info
          Padding(
            padding: AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title'],
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  movie['genre'],
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
                      '${movie['duration']} min',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '${movie['rating']}',
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
                      onPressed: () => _showDeleteDialog(context, movie['title']),
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

  void _showAddEditDialog(BuildContext context, bool isDark, {Map<String, dynamic>? movie}) {
    final titleController = TextEditingController(text: movie?['title'] ?? '');
    final genreController = TextEditingController(text: movie?['genre'] ?? '');
    final durationController = TextEditingController(
      text: movie?['duration']?.toString() ?? '',
    );
    final descriptionController = TextEditingController();
    final releaseDateController = TextEditingController();

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
                  label: 'Fecha de Estreno',
                  controller: releaseDateController,
                  hint: 'DD/MM/YYYY',
                  prefixIcon: Icons.calendar_today,
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
            onPressed: () {
              // TODO: Save to API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    movie == null
                        ? 'Película agregada exitosamente'
                        : 'Película actualizada exitosamente',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String movieTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Película'),
        content: Text('¿Estás seguro que deseas eliminar "$movieTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete from API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Película eliminada'),
                  backgroundColor: AppColors.error,
                ),
              );
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
}
