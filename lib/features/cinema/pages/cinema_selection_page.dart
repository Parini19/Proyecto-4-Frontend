import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/cinema_location.dart';
import '../../../core/providers/cinema_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';

/// Página para que el usuario seleccione su cine preferido
class CinemaSelectionPage extends ConsumerWidget {
  final bool showBackButton;

  const CinemaSelectionPage({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cinemasAsync = ref.watch(cinemasProvider);
    final selectedCinema = ref.watch(selectedCinemaProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Selecciona tu Cine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
      ),
      body: cinemasAsync.when(
        data: (cinemas) {
          if (cinemas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 80, color: AppColors.textSecondary),
                  SizedBox(height: 24),
                  Text(
                    'No hay cines disponibles',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group cinemas by city
          final cinemasesByCity = <String, List<CinemaLocation>>{};
          for (var cinema in cinemas.where((c) => c.isActive)) {
            cinemasesByCity.putIfAbsent(cinema.city, () => []).add(cinema);
          }

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              // Header
              Text(
                '¿Dónde quieres ver tu película?',
                style: AppTypography.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'Selecciona tu cine favorito para ver las películas y funciones disponibles',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32),

              // Cinemas grouped by city
              ...cinemasesByCity.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 16),
                      child: Row(
                        children: [
                          Icon(Icons.location_city, color: AppColors.secondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entry.value.map((cinema) => _buildCinemaCard(
                          context,
                          ref,
                          cinema,
                          selectedCinema,
                          isDark,
                        )),
                    SizedBox(height: 24),
                  ],
                );
              }).toList(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text(
                'Error al cargar cines',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaCard(
    BuildContext context,
    WidgetRef ref,
    CinemaLocation cinema,
    CinemaLocation? selectedCinema,
    bool isDark,
  ) {
    final isSelected = selectedCinema?.id == cinema.id;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(selectedCinemaProvider.notifier).selectCinema(cinema);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cine seleccionado: ${cinema.name}'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );

            // Go back after selection
            Future.delayed(Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            });
          },
          borderRadius: AppSpacing.borderRadiusLG,
          child: Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: AppSpacing.borderRadiusLG,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : isDark
                      ? AppColors.elevatedShadow
                      : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                // Icon/Image placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                  child: Icon(
                    Icons.movie_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),

                // Cinema info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cinema.name,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppSpacing.borderRadiusSM,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Seleccionado',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cinema.address,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            cinema.phone,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
