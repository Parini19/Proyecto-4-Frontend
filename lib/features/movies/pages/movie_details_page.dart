import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/models/showtime.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../booking/pages/seat_selection_page.dart';
import '../../booking/providers/booking_provider.dart';

class MovieDetailsPage extends ConsumerWidget {
  final MovieModel movie;

  const MovieDetailsPage({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // App bar con back button
          SliverAppBar(
            expandedHeight: isDesktop ? 400 : (isTablet ? 350 : 300),
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(isDark),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: _buildContent(context, ref, isDark, isDesktop, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    final hasColors = movie.colors.isNotEmpty;
    final defaultColors = ['#1a1a1a', '#3a3a3a'];
    final color1 = hasColors
        ? Color(int.parse(movie.colors[0].replaceFirst('#', '0xff')))
        : Color(int.parse(defaultColors[0].replaceFirst('#', '0xff')));
    final color2 = hasColors && movie.colors.length > 1
        ? Color(int.parse(movie.colors[1].replaceFirst('#', '0xff')))
        : Color(int.parse(defaultColors[1].replaceFirst('#', '0xff')));

    return Stack(
      fit: StackFit.expand,
      children: [
        // Poster background
        if (movie.posterUrl != null && movie.posterUrl!.isNotEmpty)
          Image.network(
            movie.posterUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color1, color2],
                  ),
                ),
              );
            },
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color1, color2],
              ),
            ),
          ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, bool isDark, bool isDesktop, bool isTablet) {
    final hasColors = movie.colors.isNotEmpty;
    final defaultColors = ['#1a1a1a', '#3a3a3a'];
    final color1 = hasColors
        ? Color(int.parse(movie.colors[0].replaceFirst('#', '0xff')))
        : Color(int.parse(defaultColors[0].replaceFirst('#', '0xff')));
    final color2 = hasColors && movie.colors.length > 1
        ? Color(int.parse(movie.colors[1].replaceFirst('#', '0xff')))
        : Color(int.parse(defaultColors[1].replaceFirst('#', '0xff')));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : (isTablet ? 60 : 24),
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster card + Título (layout horizontal en desktop)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster card flotante
                _buildPosterCard(color1, color2, isDark),
                SizedBox(width: 32),
                // Título y metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              movie.title,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              movie.classification,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildInfoRow(),
                    ],
                  ),
                ),
              ],
            )
          else
            // Mobile/Tablet: Poster pequeño al lado del título
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini poster
                _buildMiniPosterCard(color1, color2, isDark, isTablet),
                SizedBox(width: 16),
                // Título y badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: isTablet ? 36 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          movie.classification,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          SizedBox(height: isDesktop ? 0 : 16),

          // Info row para mobile/tablet
          if (!isDesktop) ...[
            _buildInfoRow(),
            SizedBox(height: 16),
          ],

          SizedBox(height: 40),

          // Sinopsis
          Text(
            'Sinopsis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            movie.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
            ),
          ),

          SizedBox(height: 40),

          // Director y detalles
          if (movie.director != null || movie.year != null) ...[
            Text(
              'Detalles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            if (movie.director != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.movie_creation, size: 20, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text(
                      'Director: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        movie.director!,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),

            if (movie.genre.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.category, size: 20, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text(
                      'Género: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        movie.genre,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 40),
          ],

          // Cast
          if (movie.cast != null && movie.cast!.isNotEmpty) ...[
            Text(
              'Reparto',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: movie.cast!.map((actor) {
                return Chip(
                  avatar: Icon(Icons.person, size: 18, color: AppColors.primary),
                  label: Text(actor),
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                );
              }).toList(),
            ),
            SizedBox(height: 40),
          ],

          // Horarios
          _buildShowtimes(context, ref, isDark, isDesktop, isTablet),
        ],
      ),
    );
  }

  Widget _buildPosterCard(Color color1, Color color2, bool isDark) {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: (movie.posterUrl != null && movie.posterUrl!.isNotEmpty)
            ? Image.network(
                movie.posterUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPosterFallback(color1, color2);
                },
              )
            : _buildPosterFallback(color1, color2),
      ),
    );
  }

  Widget _buildMiniPosterCard(Color color1, Color color2, bool isDark, bool isTablet) {
    final size = isTablet ? 120.0 : 100.0;
    final height = isTablet ? 180.0 : 150.0;

    return Container(
      width: size,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: (movie.posterUrl != null && movie.posterUrl!.isNotEmpty)
            ? Image.network(
                movie.posterUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPosterFallback(color1, color2);
                },
              )
            : _buildPosterFallback(color1, color2),
      ),
    );
  }

  Widget _buildPosterFallback(Color color1, Color color2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie,
          size: 60,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        _buildInfoItem(Icons.star, movie.rating, Colors.amber),
        _buildInfoItem(Icons.access_time, movie.duration, AppColors.textSecondary),
        if (movie.year != null)
          _buildInfoItem(Icons.calendar_today, movie.year!, AppColors.textSecondary),
        _buildInfoItem(Icons.category, movie.genre.split(',').first.trim(), AppColors.primary),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildShowtimes(BuildContext context, WidgetRef ref, bool isDark, bool isDesktop, bool isTablet) {
    // Si la película es de próximos estrenos (isNew == true), mostrar mensaje en lugar de horarios
    if (movie.isNew == true) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.notifications_active, size: 64, color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Próximamente en Cines',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Esta película aún no está en cartelera',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    CinemaButton(
                      text: 'Notificarme cuando esté disponible',
                      icon: Icons.notifications_outlined,
                      variant: ButtonVariant.primary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Te notificaremos cuando ${movie.title} esté disponible!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si la película está en cartelera (isNew == false), mostrar horarios normalmente
    final showtimesAsync = ref.watch(showtimesProvider(movie.id));

    return showtimesAsync.when(
      data: (showtimes) {
        if (showtimes.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'No hay horarios disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_seat, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text(
                  'Horarios Disponibles',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Selecciona tu horario y reserva tus asientos',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24),

            // Grid de horarios
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: showtimes.map((showtime) {
                return _buildShowtimeButton(context, showtime, isDark);
              }).toList(),
            ),
            SizedBox(height: 40),
          ],
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Error al cargar horarios',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildShowtimeButton(BuildContext context, Showtime showtime, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeatSelectionPage(
                movie: movie,
                showtime: showtime.timeFormatted,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hora
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    showtime.timeFormatted,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              // Cinema Name
              if (showtime.cinemaName != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Text(
                      showtime.cinemaName!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
              ],
              // Sala
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.meeting_room, color: Colors.white70, size: 14),
                  SizedBox(width: 6),
                  Text(
                    showtime.cinemaHall,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
