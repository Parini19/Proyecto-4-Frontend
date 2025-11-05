import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/models/seat.dart';
import '../providers/booking_provider.dart';
import 'payment_page.dart';

class CheckoutSummaryPage extends ConsumerWidget {
  const CheckoutSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Compra', style: AppTypography.headlineSmall),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Info Card
                  _buildMovieInfoCard(bookingState),

                  SizedBox(height: AppSpacing.lg),

                  // Seats Summary
                  _buildSectionHeader('Asientos Seleccionados'),
                  SizedBox(height: AppSpacing.sm),
                  _buildSeatsCard(bookingState),

                  SizedBox(height: AppSpacing.lg),

                  // Food Summary
                  if (bookingState.foodCart.isNotEmpty) ...[
                    _buildSectionHeader('Alimentos y Bebidas'),
                    SizedBox(height: AppSpacing.sm),
                    _buildFoodCard(bookingState),
                    SizedBox(height: AppSpacing.lg),
                  ],

                  // Price Breakdown
                  _buildSectionHeader('Desglose de Precios'),
                  SizedBox(height: AppSpacing.sm),
                  _buildPriceBreakdown(bookingState),

                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // Bottom bar with total and continue button
          _buildBottomBar(context, bookingState),
        ],
      ),
    );
  }

  Widget _buildMovieInfoCard(BookingState state) {
    if (state.selectedMovie == null || state.selectedShowtime == null) {
      return const SizedBox.shrink();
    }

    final movie = state.selectedMovie!;
    final showtime = state.selectedShowtime!;

    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Row(
        children: [
          // Poster
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusSM,
            child: Image.network(
              movie.posterUrl ?? 'https://via.placeholder.com/300x450?text=No+Image',
              width: 80,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 120,
                  color: AppColors.surfaceVariant,
                  child: Icon(Icons.movie, color: AppColors.textTertiary),
                );
              },
            ),
          ),

          SizedBox(width: AppSpacing.md),

          // Movie details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: AppTypography.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  showtime.cinemaHall,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      showtime.timeFormatted,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.titleLarge,
    );
  }

  Widget _buildSeatsCard(BookingState state) {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Column(
        children: state.selectedSeats.map((seat) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getSeatColor(seat.type),
                        borderRadius: AppSpacing.borderRadiusXS,
                      ),
                      child: Center(
                        child: Text(
                          seat.seatLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      _getSeatTypeName(seat.type),
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
                Text(
                  '\$${seat.type.price.toStringAsFixed(2)}',
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFoodCard(BookingState state) {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Column(
        children: state.foodCart.map((cartItem) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '${cartItem.quantity}x',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          cartItem.foodItem.name,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceBreakdown(BookingState state) {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Column(
        children: [
          _buildPriceRow('Asientos', state.seatsTotal),
          if (state.foodTotal > 0) ...[
            Divider(height: AppSpacing.lg, color: AppColors.border),
            _buildPriceRow('Alimentos', state.foodTotal),
          ],
          Divider(height: AppSpacing.lg, color: AppColors.border),
          _buildPriceRow(
            'Total',
            state.totalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.titleLarge
                : AppTypography.bodyLarge,
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? AppTypography.headlineSmall.copyWith(color: AppColors.primary)
                : AppTypography.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a Pagar',
                  style: AppTypography.titleLarge,
                ),
                Text(
                  '\$${state.totalPrice.toStringAsFixed(2)}',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            CinemaButton(
              text: 'Continuar al Pago',
              icon: Icons.payment,
              isFullWidth: true,
              size: ButtonSize.large,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeatColor(SeatType type) {
    switch (type) {
      case SeatType.regular:
        return AppColors.success;
      case SeatType.vip:
        return AppColors.warning;
      case SeatType.wheelchair:
        return AppColors.info;
    }
  }

  String _getSeatTypeName(SeatType type) {
    switch (type) {
      case SeatType.regular:
        return 'Regular';
      case SeatType.vip:
        return 'VIP';
      case SeatType.wheelchair:
        return 'Accesible';
    }
  }
}
