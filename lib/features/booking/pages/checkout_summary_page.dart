import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/models/seat.dart';
import '../../../core/models/booking.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/booking_provider.dart';
import 'payment_page.dart';

class CheckoutSummaryPage extends ConsumerStatefulWidget {
  const CheckoutSummaryPage({super.key});

  @override
  ConsumerState<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends ConsumerState<CheckoutSummaryPage> {
  bool _isCreatingBooking = false;
  final _promoCodeController = TextEditingController();

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  void _handleApplyPromoCode() {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un código promocional'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final success = ref.read(bookingProvider.notifier).applyPromoCode(code);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Promoción "$code" aplicada!'),
          backgroundColor: AppColors.success,
        ),
      );
      _promoCodeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código promocional inválido'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleRemovePromoCode() {
    ref.read(bookingProvider.notifier).removePromoCode();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Promoción removida'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _handleContinueToPayment() async {
    final bookingState = ref.read(bookingProvider);
    final authService = AuthService();

    // Check if user is authenticated
    if (!authService.isAuthenticated || authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para continuar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if this is a food-only order or a movie booking
    final isFoodOnlyOrder = bookingState.selectedShowtime == null || bookingState.selectedSeats.isEmpty;

    // Validate that there's something to purchase
    if (isFoodOnlyOrder && bookingState.foodCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos para comprar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // If not food-only, validate movie booking
    if (!isFoodOnlyOrder && (bookingState.selectedShowtime == null || bookingState.selectedSeats.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay asientos seleccionados'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingBooking = true;
    });

    try {
      // If it's a food-only order, skip booking creation and go directly to payment
      if (isFoodOnlyOrder) {
        // Navigate to payment page for food-only order
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentPage(),
            ),
          );
        }
      } else {
        // Create booking for movie + optional food
        final bookingService = ref.read(bookingServiceProvider);

        // Calculate ticket price (average of all selected seats)
        final ticketPrice = bookingState.seatsTotal / bookingState.selectedSeats.length;

        // Create booking request
        final request = CreateBookingRequest(
          userId: authService.currentUser!.uid,
          screeningId: bookingState.selectedShowtime!.id,
          seatNumbers: bookingState.selectedSeats.map((s) => s.seatLabel).toList(),
          ticketPrice: ticketPrice,
          foodOrderId: null, // TODO: Implement food order ID if needed
        );

        // Create booking
        final booking = await bookingService.createBooking(request);

        // Save booking ID and total from backend to state
        ref.read(bookingProvider.notifier).setBookingDetails(
          booking.id,
          booking.total,
        );

        // Navigate to payment page
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentPage(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la reserva: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final isFoodOnlyOrder = bookingState.selectedShowtime == null || bookingState.selectedSeats.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFoodOnlyOrder ? 'Resumen de Pedido' : 'Resumen de Compra',
          style: AppTypography.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Info Card (only if there's a movie selected)
                  if (bookingState.selectedMovie != null && bookingState.selectedShowtime != null) ...[
                    _buildMovieInfoCard(bookingState),
                    SizedBox(height: AppSpacing.lg),
                  ],

                  // Seats Summary (only if there are seats selected)
                  if (bookingState.selectedSeats.isNotEmpty) ...[
                    _buildSectionHeader('Asientos Seleccionados'),
                    SizedBox(height: AppSpacing.sm),
                    _buildSeatsCard(bookingState),
                    SizedBox(height: AppSpacing.lg),
                  ],

                  // Food Summary
                  if (bookingState.foodCart.isNotEmpty) ...[
                    _buildSectionHeader('Alimentos y Bebidas'),
                    SizedBox(height: AppSpacing.sm),
                    _buildFoodCard(bookingState),
                    SizedBox(height: AppSpacing.lg),
                  ],

                  // Promo Code Section
                  _buildSectionHeader('Código Promocional'),
                  SizedBox(height: AppSpacing.sm),
                  _buildPromoCodeSection(bookingState),
                  SizedBox(height: AppSpacing.lg),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
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

  Widget _buildPromoCodeSection(BookingState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPromo = state.promoCode != null;

    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: hasPromo
          ? Row(
              children: [
                Icon(Icons.local_offer, color: AppColors.success, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Código aplicado',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        state.promoCode!,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _handleRemovePromoCode,
                  icon: Icon(Icons.close, size: 18),
                  label: Text('Quitar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoCodeController,
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu código',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusSM,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusSM,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusSM,
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _handleApplyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text('Aplicar'),
                ),
              ],
            ),
    );
  }

  Widget _buildSeatsCard(BookingState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
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
                  CurrencyFormatter.formatCRC(seat.type.price),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
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
                  CurrencyFormatter.formatCRC(cartItem.totalPrice),
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
    final hasSeats = state.selectedSeats.isNotEmpty;
    final hasFood = state.foodTotal > 0;
    final hasPromo = state.promoCode != null && state.promoDiscount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Column(
        children: [
          // Show seats row only if there are seats selected
          if (hasSeats) _buildPriceRow('Asientos', state.seatsTotal),

          // Show food row if there's food
          if (hasFood) ...[
            if (hasSeats) Divider(height: AppSpacing.lg, color: AppColors.border),
            _buildPriceRow('Alimentos', state.foodTotal),
          ],

          // Show subtotal if there's a promo
          if (hasPromo) ...[
            Divider(height: AppSpacing.lg, color: AppColors.border),
            _buildPriceRow('Subtotal', state.subtotal),
            SizedBox(height: AppSpacing.xs),
            _buildDiscountRow('Descuento', state.promoDiscount),
          ],

          // Always show total
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
            CurrencyFormatter.formatCRC(amount),
            style: isTotal
                ? AppTypography.headlineSmall.copyWith(color: AppColors.primary)
                : AppTypography.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: AppColors.success, size: 16),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          Text(
            '- ${CurrencyFormatter.formatCRC(amount)}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a Pagar',
                  style: AppTypography.titleLarge,
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
            CinemaButton(
              text: _isCreatingBooking ? 'Creando reserva...' : 'Continuar al Pago',
              icon: Icons.payment,
              isFullWidth: true,
              size: ButtonSize.large,
              onPressed: _isCreatingBooking ? null : _handleContinueToPayment,
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
