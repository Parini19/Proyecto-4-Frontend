import 'package:flutter/material.dart';
import '../../../core/services/claims_service.dart';
import '../../../core/models/claim_ticket.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class ClaimsManagementPage extends StatefulWidget {
  const ClaimsManagementPage({super.key});

  @override
  State<ClaimsManagementPage> createState() => _ClaimsManagementPageState();
}

class _ClaimsManagementPageState extends State<ClaimsManagementPage> {
  final ClaimsService _claimsService = ClaimsService();
  List<ClaimTicket> _allClaims = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusFilters = ['All', 'Open', 'InProgress', 'Closed'];

  @override
  void initState() {
    super.initState();
    _loadAllClaims();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllClaims() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final claims = await _claimsService.getAllClaimsForAdmin();
      setState(() {
        _allClaims = claims;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ClaimTicket> get _filteredClaims {
    var claims = _allClaims;

    // Filter by status
    if (_selectedStatus != 'All') {
      claims = claims.where((claim) => claim.status == _selectedStatus).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      claims = claims.where((claim) {
        return claim.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            claim.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            claim.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            claim.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by creation date (newest first)
    claims.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return claims;
  }

  Future<void> _updateClaimStatus(ClaimTicket claim, String newStatus) async {
    try {
      final updatedClaim = claim.copyWith(
        status: newStatus,
        closedAt: newStatus == 'Closed' ? DateTime.now() : null,
      );
      
      await _claimsService.updateClaim(updatedClaim);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado del reclamo actualizado exitosamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      _loadAllClaims(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el estado: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.report_problem,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Reclamos y Quejas',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Administra todos los reclamos y quejas de los usuarios',
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _loadAllClaims,
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Search and filters row
                if (!isMobile) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por título, descripción, usuario o email...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          underline: SizedBox(),
                          items: _statusFilters.map((status) {
                            final count = status == 'All'
                                ? _allClaims.length
                                : _allClaims.where((c) => c.status == status).length;
                            return DropdownMenuItem(
                              value: status,
                              child: Text('$status ($count)'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Mobile layout
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar reclamos...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statusFilters.map((status) {
                        final isSelected = _selectedStatus == status;
                        final count = status == 'All'
                            ? _allClaims.length
                            : _allClaims.where((c) => c.status == status).length;

                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('$status ($count)'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = status;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(isDark, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isMobile) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Cargando reclamos...',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              SizedBox(height: 16),
              Text(
                'Error al cargar reclamos',
                style: AppTypography.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                _error!,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAllClaims,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredClaims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _selectedStatus != 'All'
                  ? Icons.search_off
                  : Icons.inbox_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedStatus != 'All'
                  ? 'No se encontraron reclamos'
                  : 'No hay reclamos registrados',
              style: AppTypography.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedStatus != 'All'
                  ? 'Prueba cambiar los filtros de búsqueda'
                  : 'Los reclamos aparecerán aquí cuando los usuarios los envíen',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredClaims.length,
      itemBuilder: (context, index) {
        return _buildClaimCard(_filteredClaims[index], isDark, isMobile);
      },
    );
  }

  Widget _buildClaimCard(ClaimTicket claim, bool isDark, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showClaimDetails(claim);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Usuario: ${claim.userEmail.isNotEmpty ? claim.userEmail : claim.userId}',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  _buildStatusChip(claim.status, isDark),
                  SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action.startsWith('status:')) {
                        final newStatus = action.substring(7);
                        _updateClaimStatus(claim, newStatus);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'status:Open',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: AppColors.warning),
                            SizedBox(width: 8),
                            Text('Marcar como Abierto'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status:InProgress',
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_bottom, size: 16, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Marcar en Progreso'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status:Closed',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: AppColors.success),
                            SizedBox(width: 8),
                            Text('Marcar como Cerrado'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Description
              Text(
                claim.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 16),

              // Footer Row
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(claim.createdAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  Spacer(),
                  if (claim.isClosed && claim.closedAt != null) ...[
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Cerrado ${_formatDate(claim.closedAt!)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'Open':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        icon = Icons.schedule;
        break;
      case 'InProgress':
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        icon = Icons.hourglass_bottom;
        break;
      case 'Closed':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      default:
        backgroundColor = (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant);
        textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        icon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            _getStatusDisplayName(status),
            style: AppTypography.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'Open':
        return 'Abierto';
      case 'InProgress':
        return 'En Progreso';
      case 'Closed':
        return 'Cerrado';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ahora mismo';
    }
  }

  void _showClaimDetails(ClaimTicket claim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.report_problem, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(child: Text('Detalles del Reclamo')),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID:', claim.id),
                _buildDetailRow('Usuario ID:', claim.userId),
                _buildDetailRow('Email:', claim.userEmail),
                _buildDetailRow('Estado:', claim.statusDisplayName),
                _buildDetailRow('Creado:', _formatFullDate(claim.createdAt)),
                if (claim.closedAt != null)
                  _buildDetailRow('Cerrado:', _formatFullDate(claim.closedAt!)),
                SizedBox(height: 16),
                Text(
                  'Título:',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(claim.title, style: AppTypography.bodyMedium),
                SizedBox(height: 16),
                Text(
                  'Descripción:',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(claim.description, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          if (!claim.isClosed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateClaimStatus(claim, 'Closed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: Text('Marcar Resuelto'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year} a las ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}