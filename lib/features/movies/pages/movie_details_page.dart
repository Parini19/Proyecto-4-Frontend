import 'package:flutter/material.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../booking/pages/seat_selection_page.dart';

class MovieDetailsPage extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailsPage({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section con poster
            _buildHeroSection(context, size, isDark, isDesktop, isTablet),

            // Información de la película
            Padding(
              padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 30 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y rating
                  _buildTitleSection(isDark, isDesktop),

                  SizedBox(height: AppSpacing.lg),

                  // Info quick
                  _buildQuickInfo(isDark),

                  SizedBox(height: AppSpacing.xxl),

                  // Sinopsis
                  _buildSynopsisSection(isDark, isDesktop),

                  SizedBox(height: AppSpacing.xxl),

                  // Cast
                  if (movie.cast != null && movie.cast!.isNotEmpty)
                    _buildCastSection(isDark, isDesktop),

                  if (movie.cast != null && movie.cast!.isNotEmpty)
                    SizedBox(height: AppSpacing.xxl),

                  // Horarios disponibles
                  _buildShowtimesSection(context, isDark, isDesktop, isTablet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Size size, bool isDark, bool isDesktop, bool isTablet) {
    return Stack(
      children: [
        // Background con gradiente de la película
        Container(
          height: isDesktop ? 600 : (isTablet ? 500 : 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(int.parse(movie.colors[0].replaceFirst('#', '0xff'))),
                Color(int.parse(movie.colors[1].replaceFirst('#', '0xff'))),
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
              ],
            ),
          ),
        ),

        // Overlay oscuro
        Container(
          height: isDesktop ? 600 : (isTablet ? 500 : 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
              ],
            ),
          ),
        ),

        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.5),
              padding: EdgeInsets.all(12),
            ),
          ),
        ),

        // Contenido del hero
        Positioned(
          bottom: 40,
          left: isDesktop ? 60 : (isTablet ? 40 : 20),
          right: isDesktop ? 60 : (isTablet ? 40 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título grande
              Text(
                movie.title,
                style: TextStyle(
                  fontSize: isDesktop ? 64 : (isTablet ? 48 : 36),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),

              SizedBox(height: 16),

              // Quick info
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.star, movie.rating),
                  _buildInfoChip(Icons.access_time, movie.duration),
                  if (movie.year != null)
                    _buildInfoChip(Icons.calendar_today, movie.year!),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(bool isDark, bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.genre,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  movie.classification,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo(bool isDark) {
    return Row(
      children: [
        if (movie.director != null) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Director',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  movie.director!,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (movie.year != null) ...[
          SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Año',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                movie.year!,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSynopsisSection(bool isDark, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinopsis',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          movie.description,
          style: AppTypography.bodyLarge.copyWith(
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection(bool isDark, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reparto',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: movie.cast!.map((actor) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    actor,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildShowtimesSection(BuildContext context, bool isDark, bool isDesktop, bool isTablet) {
    if (movie.showtimes == null || movie.showtimes!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios Disponibles',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Selecciona un horario para continuar',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Grid de horarios
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: movie.showtimes!.length,
          itemBuilder: (context, index) {
            final showtime = movie.showtimes![index];
            return _buildShowtimeCard(context, showtime, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildShowtimeCard(BuildContext context, String showtime, bool isDark) {
    return InkWell(
      onTap: () {
        // Navegar a selección de asientos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeatSelectionPage(
              movie: movie,
              showtime: showtime,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                showtime,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
