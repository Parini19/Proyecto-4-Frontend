import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/ticket.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/auth_service.dart';

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final authService = AuthService();

    if (!authService.isAuthenticated || authService.currentUser == null) {
      setState(() {
        _isLoading = false;
        _error = 'Debes iniciar sesión para ver tus tickets';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ticketService = ref.read(ticketServiceProvider);
      final tickets = await ticketService.getUserTickets(authService.currentUser!.uid);

      // Sort tickets: active first, then by show time
      tickets.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.showTime.compareTo(a.showTime);
      });

      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar tickets: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tickets', style: AppTypography.headlineSmall),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: AppSpacing.lg),
              Text(_error!, style: AppTypography.bodyLarge, textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _loadTickets,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 120,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'No tienes tickets todavía',
                style: AppTypography.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Tus tickets comprados aparecerán aquí',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: AppSpacing.pagePadding,
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return _buildTicketCard(ticket);
        },
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final dateFormatter = DateFormat('dd MMM yyyy', 'es');
    final timeFormatter = DateFormat('HH:mm');
    final isActive = ticket.isActive;
    final isExpired = ticket.isExpired;
    final isUsed = ticket.isUsed;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: InkWell(
        onTap: () => _showTicketDetails(ticket),
        borderRadius: AppSpacing.borderRadiusMD,
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.movieTitle,
                      style: AppTypography.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(isActive, isExpired, isUsed),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Ticket details
              _buildDetailRow(Icons.event, 'Sala', ticket.theaterRoomName),
              _buildDetailRow(Icons.event_seat, 'Asiento', ticket.seatNumber),
              _buildDetailRow(
                Icons.calendar_today,
                'Fecha',
                dateFormatter.format(ticket.showTime),
              ),
              _buildDetailRow(
                Icons.access_time,
                'Hora',
                timeFormatter.format(ticket.showTime),
              ),

              if (!isActive) ...[
                SizedBox(height: AppSpacing.sm),
                if (isUsed)
                  Text(
                    'Usado: ${DateFormat('dd MMM yyyy HH:mm').format(ticket.usedAt!)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  )
                else if (isExpired)
                  Text(
                    'Expirado: ${DateFormat('dd MMM yyyy HH:mm').format(ticket.expiresAt)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],

              if (isActive) ...[
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQRCode(ticket),
                        icon: const Icon(Icons.qr_code_2, size: 20),
                        label: const Text('Ver QR'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadTicket(ticket),
                        icon: const Icon(Icons.download, size: 20),
                        label: const Text('Descargar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, bool isExpired, bool isUsed) {
    Color color;
    String label;
    IconData icon;

    if (isUsed) {
      color = AppColors.info;
      label = 'Usado';
      icon = Icons.check_circle;
    } else if (isExpired) {
      color = AppColors.error;
      label = 'Expirado';
      icon = Icons.cancel;
    } else if (isActive) {
      color = AppColors.success;
      label = 'Activo';
      icon = Icons.check_circle_outline;
    } else {
      color = AppColors.warning;
      label = 'Inactivo';
      icon = Icons.warning_amber;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusRound,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          SizedBox(width: AppSpacing.xs),
          Text(
            '$label: ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketDetails(Ticket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLG),
            topRight: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusRound,
              ),
            ),

            Text('Detalles del Ticket', style: AppTypography.titleLarge),
            SizedBox(height: AppSpacing.lg),

            // QR Code
            if (ticket.isActive) ...[
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.md),
                child: QrImageView(
                  data: ticket.qrCodeData,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Presenta este código en la entrada',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],

            // Ticket info
            _buildDetailRow(Icons.movie, 'Película', ticket.movieTitle),
            _buildDetailRow(Icons.event, 'Sala', ticket.theaterRoomName),
            _buildDetailRow(Icons.event_seat, 'Asiento', ticket.seatNumber),
            _buildDetailRow(
              Icons.confirmation_number,
              'ID',
              ticket.id.substring(0, 8).toUpperCase(),
            ),

            SizedBox(height: AppSpacing.lg),

            if (ticket.isActive)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadTicket(ticket);
                },
                icon: const Icon(Icons.download),
                label: const Text('Descargar PDF'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showQRCode(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Código QR', style: AppTypography.titleLarge),
              SizedBox(height: AppSpacing.md),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.md),
                child: QrImageView(
                  data: ticket.qrCodeData,
                  version: QrVersions.auto,
                  size: 250,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                ticket.seatNumber,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Presenta este código en la entrada',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadTicket(Ticket ticket) async {
    final ticketService = ref.read(ticketServiceProvider);
    final url = ticketService.getTicketDownloadUrl(ticket.id);

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el enlace de descarga'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
