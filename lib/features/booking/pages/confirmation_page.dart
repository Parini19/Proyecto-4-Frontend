import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../providers/booking_provider.dart';

class ConfirmationPage extends ConsumerWidget {
  final String email;

  const ConfirmationPage({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final confirmationCode = _generateConfirmationCode();

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
                        'Compra Exitosa!',
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
                        email,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppSpacing.xxl),

                      // Confirmation code
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
                            Text(
                              'Código de Confirmación',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              confirmationCode,
                              style: AppTypography.displaySmall.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Muestra este código en el cine',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // QR Code placeholder
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppSpacing.borderRadiusMD,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 120,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Código QR',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Booking details
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

  String _generateConfirmationCode() {
    final random = Random();
    final code = List.generate(
      6,
      (index) => random.nextInt(10).toString(),
    ).join();
    return code;
  }
}
