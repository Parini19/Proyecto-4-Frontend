import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/models/showtime.dart';
import '../../../core/models/seat.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/booking_provider.dart';
import '../widgets/seat_widget.dart';
import '../widgets/screen_indicator.dart';
import 'food_menu_page.dart';

class SeatSelectionPage extends ConsumerStatefulWidget {
  final MovieModel movie;
  final String showtime;

  const SeatSelectionPage({
    super.key,
    required this.movie,
    required this.showtime,
  });

  @override
  ConsumerState<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends ConsumerState<SeatSelectionPage> {
  Showtime? _selectedShowtime;

  @override
  void initState() {
    super.initState();
    // Set the movie in booking state
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(bookingProvider.notifier).setMovie(widget.movie);

      try {
        // Get showtimes and select the one matching the time
        final showtimes = await ref.read(showtimesProvider(widget.movie.id).future);

        if (showtimes.isEmpty) {
          // No showtimes available
          if (mounted) {
            Navigator.pop(context);
          }
          return;
        }

        final showtime = showtimes.firstWhere(
          (st) => st.timeFormatted == widget.showtime,
          orElse: () => showtimes.first,
        );

        if (mounted) {
          setState(() {
            _selectedShowtime = showtime;
          });

          ref.read(bookingProvider.notifier).setShowtime(showtime);
        }
      } catch (e) {
        print('Error loading showtimes: $e');
        if (mounted) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    if (_selectedShowtime == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: AppTypography.titleMedium,
            ),
            Text(
              '${_selectedShowtime!.cinemaHall} • ${_selectedShowtime!.timeFormatted}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Legend button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLegend(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Seat grid (scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                children: [
                  // Screen indicator
                  const ScreenIndicator(),

                  SizedBox(height: AppSpacing.xl),

                  // Seat grid
                  _buildSeatGrid(_selectedShowtime!.seats),

                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // Bottom bar with selection summary and continue button
          _buildBottomBar(context, bookingState),
        ],
      ),
    );
  }

  Widget _buildSeatGrid(List<Seat> seats) {
    // Group seats by row
    final Map<int, List<Seat>> seatsByRow = {};
    for (final seat in seats) {
      seatsByRow.putIfAbsent(seat.row, () => []).add(seat);
    }

    final rows = seatsByRow.keys.toList()..sort();

    return Column(
      children: rows.map((rowNumber) {
        final rowSeats = seatsByRow[rowNumber]!;
        rowSeats.sort((a, b) => a.number.compareTo(b.number));

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row label
              SizedBox(
                width: 30,
                child: Text(
                  String.fromCharCode(65 + rowNumber),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Seats
              ...rowSeats.map((seat) {
                // Add spacing in the middle for aisle
                final widgets = <Widget>[];

                if (seat.number == 7) {
                  widgets.add(SizedBox(width: AppSpacing.md));
                }

                widgets.add(
                  SeatWidget(
                    seat: seat,
                    onTap: () {
                      if (seat.status == SeatStatus.available ||
                          seat.status == SeatStatus.selected) {
                        ref.read(bookingProvider.notifier).toggleSeat(seat);
                      }
                    },
                    isSelected: ref
                        .read(bookingProvider.notifier)
                        .isSeatSelected(seat.id),
                  ),
                );

                return widgets;
              }).expand((w) => w),

              SizedBox(width: AppSpacing.sm),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: AppSpacing.pagePadding,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection summary
            if (state.hasSelection) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.seatCount} asiento${state.seatCount > 1 ? 's' : ''}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        state.selectedSeats.map((s) => s.seatLabel).join(', '),
                        style: AppTypography.labelMedium,
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.formatCRC(state.totalPrice),
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
            ],

            // Continue button
            CinemaButton(
              text: state.hasSelection
                  ? 'Continuar'
                  : 'Selecciona tus asientos',
              icon: Icons.arrow_forward,
              isFullWidth: true,
              size: ButtonSize.large,
              onPressed: state.hasSelection
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodMenuPage(),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showLegend(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLG),
            topRight: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: AppSpacing.borderRadiusRound,
                ),
              ),
            ),
            Text(
              'Leyenda de Asientos',
              style: AppTypography.headlineSmall,
            ),
            SizedBox(height: AppSpacing.lg),
            _buildLegendItem(
              color: AppColors.primary,
              label: 'Seleccionado',
            ),
            _buildLegendItem(
              color: AppColors.success,
              label: 'Disponible',
            ),
            _buildLegendItem(
              color: AppColors.vip,
              label: 'VIP - \$180',
            ),
            _buildLegendItem(
              color: isDark ? AppColors.darkTextSecondary.withOpacity(0.4) : AppColors.lightTextSecondary.withOpacity(0.5),
              label: 'Ocupado',
              icon: Icons.close,
            ),
            _buildLegendItem(
              color: AppColors.info,
              label: 'Accesible - \$120',
              icon: Icons.accessible,
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppSpacing.borderRadiusXS,
            ),
            child: icon != null
                ? Icon(icon, color: Colors.white, size: 20)
                : null,
          ),
          SizedBox(width: AppSpacing.md),
          Text(label, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
