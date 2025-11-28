import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/models/booking.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

final bookingServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return BookingService(dio);
});

final userBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final authService = AuthService();
  final userId = authService.currentUser?.uid ?? '';

  if (userId.isEmpty) {
    return [];
  }

  return await bookingService.getUserBookings(userId);
});

class MyTicketsPage extends ConsumerWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Mis Boletos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No tienes boletos',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '¡Reserva tu primera película!',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Separate active and past bookings
          final now = DateTime.now();
          final activeBookings = bookings
              .where((b) => b.status == 'confirmed' || b.status == 'pending')
              .toList();
          final pastBookings = bookings
              .where((b) => b.status == 'cancelled' || b.status == 'completed')
              .toList();

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              if (activeBookings.isNotEmpty) ...[
                _buildSectionHeader('Próximos', isDark),
                SizedBox(height: 16),
                ...activeBookings.map((booking) => _buildTicketCard(booking, isDark, context)),
                SizedBox(height: 32),
              ],
              if (pastBookings.isNotEmpty) ...[
                _buildSectionHeader('Pasados', isDark),
                SizedBox(height: 16),
                ...pastBookings.map((booking) => _buildTicketCard(booking, isDark, context)),
              ],
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
                'Error al cargar boletos',
                style: TextStyle(color: AppColors.error),
              ),
              SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.headlineSmall.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTicketCard(Booking booking, bool isDark, BuildContext context) {
    final isActive = booking.status == 'confirmed' || booking.status == 'pending';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTicketDetails(context, booking, isDark),
          borderRadius: AppSpacing.borderRadiusLG,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: AppSpacing.borderRadiusLG,
              border: isActive
                  ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 2)
                  : null,
              boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                // QR Code Section
                Container(
                  width: 120,
                  height: 140,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isActive ? AppColors.primaryGradient : null,
                    color: isActive ? null : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: AppSpacing.borderRadiusLG.topLeft,
                      bottomLeft: AppSpacing.borderRadiusLG.bottomLeft,
                    ),
                  ),
                  child: isActive
                      ? QrImageView(
                          data: booking.id,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(8),
                        )
                      : Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.white.withOpacity(0.7),
                        ),
                ),

                // Ticket Info
                Expanded(
                  child: Padding(
                    padding: AppSpacing.paddingMD,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Película #${booking.id.substring(0, 8)}',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status),
                                borderRadius: AppSpacing.borderRadiusSM,
                              ),
                              child: Text(
                                _getStatusLabel(booking.status),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(Icons.event_seat, '${booking.seatNumbers.join(", ")}', isDark),
                        SizedBox(height: 4),
                        _buildInfoRow(Icons.confirmation_number, '${booking.ticketQuantity} ${booking.ticketQuantity > 1 ? "boletos" : "boleto"}', isDark),
                        SizedBox(height: 4),
                        _buildInfoRow(Icons.account_balance_wallet, '₡${booking.total.toStringAsFixed(0)}', isDark),
                        SizedBox(height: 4),
                        _buildInfoRow(Icons.calendar_today, _formatDate(booking.createdAt), isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white70 : Colors.black87),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmado';
      case 'pending':
        return 'Pendiente';
      case 'cancelled':
        return 'Cancelado';
      case 'completed':
        return 'Completado';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showTicketDetails(BuildContext context, Booking booking, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLG),
            topRight: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // Handle
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
              'Detalles del Boleto',
              style: AppTypography.headlineSmall,
            ),
            SizedBox(height: 24),

            // Large QR Code
            if (booking.status == 'confirmed' || booking.status == 'pending')
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusLG,
                ),
                child: QrImageView(
                  data: booking.id,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),

            SizedBox(height: 32),

            // Booking Details
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow('ID de Reserva', booking.id),
                  _buildDetailRow('Estado', _getStatusLabel(booking.status)),
                  _buildDetailRow('Asientos', booking.seatNumbers.join(", ")),
                  _buildDetailRow('Cantidad', '${booking.ticketQuantity} boletos'),
                  _buildDetailRow('Precio por boleto', '₡${booking.ticketPrice.toStringAsFixed(0)}'),
                  _buildDetailRow('Subtotal boletos', '₡${booking.subtotalTickets.toStringAsFixed(0)}'),
                  if (booking.subtotalFood > 0)
                    _buildDetailRow('Comida', '₡${booking.subtotalFood.toStringAsFixed(0)}'),
                  _buildDetailRow('Impuesto', '₡${booking.tax.toStringAsFixed(0)}'),
                  Divider(height: 32),
                  _buildDetailRow('Total', '₡${booking.total.toStringAsFixed(0)}', isTotal: true),
                  if (booking.confirmedAt != null)
                    _buildDetailRow('Confirmado', _formatDate(booking.confirmedAt!)),
                  _buildDetailRow('Creado', _formatDate(booking.createdAt)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.bodyLarge,
          ),
          Text(
            value,
            style: isTotal
                ? AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
                : AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }
}
