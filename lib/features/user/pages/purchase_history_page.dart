import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/booking.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

final bookingHistoryServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return BookingService(dio);
});

final userHistoryProvider = FutureProvider<List<Booking>>((ref) async {
  final bookingService = ref.watch(bookingHistoryServiceProvider);
  final authService = AuthService();
  final userId = authService.currentUser?.uid ?? '';

  if (userId.isEmpty) {
    return [];
  }

  final allBookings = await bookingService.getUserBookings(userId);
  // Sort by most recent first
  allBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return allBookings;
});

class PurchaseHistoryPage extends ConsumerWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(userHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Sin historial de compras',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tus compras aparecerán aquí',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate total stats
          final totalSpent = bookings
              .where((b) => b.status == 'confirmed' || b.status == 'completed')
              .fold<double>(0, (sum, b) => sum + b.total);
          final totalTickets = bookings
              .where((b) => b.status == 'confirmed' || b.status == 'completed')
              .fold<int>(0, (sum, b) => sum + b.ticketQuantity);

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              // Stats Summary
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Gastado',
                      '₡${totalSpent.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      AppColors.success,
                      isDark,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Boletos',
                      '$totalTickets',
                      Icons.confirmation_number,
                      AppColors.primary,
                      isDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Transactions
              Text(
                'Transacciones',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              ...bookings.map((booking) => _buildHistoryItem(booking, isDark)),
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
                'Error al cargar historial',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Booking booking, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: _getStatusColor(booking.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.2),
              borderRadius: AppSpacing.borderRadiusMD,
            ),
            child: Icon(
              _getStatusIcon(booking.status),
              color: _getStatusColor(booking.status),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reserva #${booking.id.substring(0, 8)}',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${booking.ticketQuantity} boleto${booking.ticketQuantity > 1 ? "s" : ""} • ${booking.seatNumbers.length} asiento${booking.seatNumbers.length > 1 ? "s" : ""}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDate(booking.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₡${booking.total.toStringAsFixed(0)}',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(booking.status),
                ),
              ),
              SizedBox(height: 4),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
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
}
