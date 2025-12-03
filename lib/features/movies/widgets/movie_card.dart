import 'package:flutter/material.dart';
import '../../../core/models/movie.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360; // Extra small screens
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Padding(
          padding: EdgeInsets.only(right: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Poster Image with "NUEVO" badge
            Flexible(
              child: Stack(
              children: [
                // Poster - Conditionally disable on very small screens
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusMD,
                  child: AspectRatio(
                    aspectRatio: AppSpacing.posterAspectRatio,
                    child: isSmallMobile
                        ? _buildFallbackPoster() // Always use fallback on extra small screens
                        : Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackPoster();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
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

                // NEW Badge
                if (movie.isNew)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppSpacing.borderRadiusXS,
                      ),
                      child: Text(
                        'NUEVO',
                        style: AppTypography.badge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Rating
                Positioned(
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: AppSpacing.borderRadiusXS,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.star,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),

            SizedBox(height: AppSpacing.sm),

            // Title
            Text(
              movie.title,
              style: AppTypography.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: AppSpacing.xs),

            // Genre & Duration
            Text(
              '${movie.genre} • ${movie.durationFormatted}',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: AppSpacing.xs),

            // Classification
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: AppSpacing.borderRadiusXS,
              ),
              child: Text(
                movie.classification,
                style: AppTypography.labelSmall,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFallbackPoster() {
    // Create a gradient based on movie genre or use default colors
    final gradientColors = _getGenreColors(movie.genre);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 32,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              movie.title,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  List<Color> _getGenreColors(String genre) {
    final lowerGenre = genre.toLowerCase();
    
    if (lowerGenre.contains('acción') || lowerGenre.contains('action')) {
      return [Color(0xFFE53E3E), Color(0xFFD32F2F)];
    } else if (lowerGenre.contains('comedia') || lowerGenre.contains('comedy')) {
      return [Color(0xFFFF8A00), Color(0xFFF57C00)];
    } else if (lowerGenre.contains('drama')) {
      return [Color(0xFF2196F3), Color(0xFF1976D2)];
    } else if (lowerGenre.contains('terror') || lowerGenre.contains('horror')) {
      return [Colors.purple.shade700, Colors.purple.shade900];
    } else if (lowerGenre.contains('ciencia') || lowerGenre.contains('sci')) {
      return [Color(0xFF6366F1), Color(0xFF4F46E5)];
    } else if (lowerGenre.contains('aventura') || lowerGenre.contains('adventure')) {
      return [Color(0xFF10B981), Color(0xFF059669)];
    } else {
      return [Color(0xFF64748B), Color(0xFF475569)];
    }
  }
}
