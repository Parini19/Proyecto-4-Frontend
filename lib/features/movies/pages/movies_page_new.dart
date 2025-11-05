import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/movie.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../widgets/movie_card.dart';
import '../../booking/pages/seat_selection_page.dart';

class MoviesPageNew extends StatefulWidget {
  const MoviesPageNew({super.key});

  @override
  State<MoviesPageNew> createState() => _MoviesPageNewState();
}

class _MoviesPageNewState extends State<MoviesPageNew> {
  List<Movie> _movies = mockMovies;
  String _selectedGenre = 'Todos';
  final PageController _carouselController = PageController();
  int _currentCarouselPage = 0;
  late final Timer _carouselTimer;

  final List<String> _genres = [
    'Todos',
    'Acción',
    'Terror',
    'Drama',
    'Anime',
    'Comedia',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll carousel every 4 seconds
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        final nextPage = (_currentCarouselPage + 1) % _movies.length;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Cartelera',
                style: AppTypography.headlineSmall,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Genre Filter
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.horizontalMD,
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenre == genre;

                  return Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGenre = genre;
                          // TODO: Filter movies by genre
                        });
                      },
                      backgroundColor: AppColors.surfaceVariant,
                      selectedColor: AppColors.primary,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusRound,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // En Cartelera Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.horizontalMD,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'En Cartelera',
                    style: AppTypography.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Ver todas
                    },
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
            ),
          ),

          // Auto-rotating Carousel
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 420,
                  child: PageView.builder(
                    controller: _carouselController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCarouselPage = index;
                      });
                    },
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: AppSpacing.horizontalMD,
                        child: GestureDetector(
                          onTap: () => _showMovieDetail(context, _movies[index]),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              borderRadius: AppSpacing.borderRadiusLG,
                              boxShadow: AppColors.elevatedShadow,
                            ),
                            child: MovieCard(
                              movie: _movies[index],
                              onTap: () => _showMovieDetail(context, _movies[index]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Carousel Indicators
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _movies.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentCarouselPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentCarouselPage == index
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Próximos Estrenos Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.horizontalMD,
              child: const Text(
                'Próximos Estrenos',
                style: AppTypography.headlineSmall,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // Grid of upcoming movies
          SliverPadding(
            padding: AppSpacing.horizontalMD,
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final movie = _movies[index % _movies.length];
                  return MovieCard(
                    movie: movie,
                    onTap: () => _showMovieDetail(context, movie),
                  );
                },
                childCount: 4,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  void _showMovieDetail(BuildContext context, Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MovieDetailSheet(movie: movie),
    );
  }
}

// Movie Detail Bottom Sheet
class MovieDetailSheet extends StatelessWidget {
  final Movie movie;

  const MovieDetailSheet({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusLG),
              topRight: Radius.circular(AppSpacing.radiusLG),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppSpacing.borderRadiusRound,
                    ),
                  ),
                ),

                // Poster
                Center(
                  child: ClipRRect(
                    borderRadius: AppSpacing.borderRadiusMD,
                    child: Image.network(
                      movie.posterUrl,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          width: 200,
                          color: AppColors.surfaceVariant,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Imagen no disponible',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          width: 200,
                          color: AppColors.surfaceVariant,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        movie.title,
                        style: AppTypography.displaySmall,
                      ),

                      SizedBox(height: AppSpacing.sm),

                      // Metadata
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _buildMetadataChip(
                            Icons.access_time,
                            movie.durationFormatted,
                          ),
                          _buildMetadataChip(
                            Icons.category,
                            movie.classification,
                          ),
                          _buildMetadataChip(
                            Icons.star,
                            movie.rating.toStringAsFixed(1),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // Description
                      Text(
                        'Sinopsis',
                        style: AppTypography.titleLarge,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        movie.description,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // Details
                      _buildDetailRow('Director', movie.director),
                      _buildDetailRow('Género', movie.genre),

                      SizedBox(height: AppSpacing.lg),

                      // Showtimes
                      Text(
                        'Horarios Disponibles',
                        style: AppTypography.titleLarge,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: movie.showtimes.map((time) {
                          return ChoiceChip(
                            label: Text(time),
                            selected: false,
                            onSelected: (selected) {
                              if (selected) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeatSelectionPage(
                                      movie: movie.toMovieModel(),
                                      showtime: time,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Buy Button
                      CinemaButton(
                        text: 'Seleccionar Horario',
                        icon: Icons.confirmation_number,
                        isFullWidth: true,
                        size: ButtonSize.large,
                        onPressed: () {
                          // Scroll up to showtimes section
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona un horario arriba'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.textSecondary),
      label: Text(label, style: AppTypography.labelMedium),
      backgroundColor: AppColors.surfaceVariant,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
