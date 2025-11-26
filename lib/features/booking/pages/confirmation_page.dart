import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/services/auth_service.dart';
import '../providers/booking_provider.dart';

class ConfirmationPage extends ConsumerWidget {
  final String bookingId;
  final String invoiceNumber;
  final int ticketsGenerated;

  const ConfirmationPage({
    super.key,
    required this.bookingId,
    required this.invoiceNumber,
    required this.ticketsGenerated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final authService = AuthService();
    final userEmail = authService.currentUser?.email ?? 'usuario@ejemplo.com';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: AppSpacing.xxl),

                      // Success icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 80,
                          color: AppColors.success,
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      Text(
                        '¡Compra Exitosa!',
                        style: AppTypography.displaySmall,
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppSpacing.md),

                      Text(
                        'Hemos enviado la confirmación a',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppSpacing.xs),

                      Text(
                        userEmail,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppSpacing.xxl),

                      // Booking details
                      Container(
                        padding: AppSpacing.pagePadding,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppSpacing.borderRadiusMD,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Código de Reserva', bookingId.substring(0, 8).toUpperCase()),
                            Divider(height: AppSpacing.lg, color: AppColors.border),
                            _buildInfoRow('Número de Factura', invoiceNumber),
                            Divider(height: AppSpacing.lg, color: AppColors.border),
                            _buildInfoRow('Boletos Generados', ticketsGenerated.toString()),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Booking details summary
                      if (bookingState.selectedMovie != null) ...[
                        _buildDetailRow(
                          'Película',
                          bookingState.selectedMovie!.title,
                        ),
                        if (bookingState.selectedShowtime != null) ...[
                          _buildDetailRow(
                            'Sala',
                            bookingState.selectedShowtime!.cinemaHall,
                          ),
                          _buildDetailRow(
                            'Horario',
                            bookingState.selectedShowtime!.timeFormatted,
                          ),
                        ],
                        _buildDetailRow(
                          'Asientos',
                          bookingState.selectedSeats
                              .map((s) => s.seatLabel)
                              .join(', '),
                        ),
                        _buildDetailRow(
                          'Total Pagado',
                          '\$${bookingState.totalPrice.toStringAsFixed(2)}',
                        ),
                      ],

                      SizedBox(height: AppSpacing.xxl),

                      // Information message
                      Container(
                        padding: AppSpacing.paddingMD,
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: AppSpacing.borderRadiusMD,
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.info),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Tus boletos digitales con códigos QR han sido enviados a tu correo electrónico',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Column(
                children: [
                  CinemaButton(
                    text: 'Ver Mis Tickets',
                    icon: Icons.confirmation_number,
                    isFullWidth: true,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      // TODO: Navigate to tickets tab
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {
                      // Reset booking state
                      ref.read(bookingProvider.notifier).reset();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Volver a Inicio'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
