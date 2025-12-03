import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/audit_log.dart';
import '../../../core/services/audit_log_service.dart';
import '../../../core/services/config_service.dart';
import '../../../core/providers/service_providers.dart';

class AuditLogManagementPage extends ConsumerStatefulWidget {
  const AuditLogManagementPage({super.key});

  @override
  ConsumerState<AuditLogManagementPage> createState() =>
      _AuditLogManagementPageState();
}

class _AuditLogManagementPageState
    extends ConsumerState<AuditLogManagementPage> {
  List<AuditLog> _logs = [];
  List<AuditLog> _filteredLogs = [];
  bool _isLoading = true;
  bool _auditLoggingEnabled = false;
  bool _isTogglingAudit = false;
  String _searchQuery = '';
  String? _selectedAction;
  String? _selectedEntityType;
  String? _selectedSeverity;
  DateTime? _startDate;
  DateTime? _endDate;

  final ConfigService _configService = ConfigService();

  final List<String> _actions = [
    'All',
    'CREATE',
    'UPDATE',
    'DELETE',
    'VIEW',
    'LOGIN',
    'LOGOUT'
  ];
  final List<String> _entityTypes = [
    'All',
    'Movie',
    'Booking',
    'User',
    'Screening',
    'TheaterRoom',
    'FoodCombo'
  ];
  final List<String> _severities = ['All', 'Info', 'Warning', 'Error', 'Critical'];

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
    _loadAuditLoggingStatus();
  }

  Future<void> _loadAuditLoggingStatus() async {
    try {
      final enabled = await _configService.getAuditLoggingStatus();
      setState(() {
        _auditLoggingEnabled = enabled;
      });
    } catch (e) {
      print('Error loading audit logging status: $e');
    }
  }

  Future<void> _toggleAuditLogging(bool value) async {
    setState(() => _isTogglingAudit = true);

    try {
      final success = await _configService.setAuditLogging(value);

      if (success) {
        setState(() {
          _auditLoggingEnabled = value;
          _isTogglingAudit = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? '✅ Auditoría ACTIVADA - Los logs se guardarán en Firestore'
                    : '⚠️ Auditoría DESACTIVADA - No se guardarán logs',
              ),
              backgroundColor: value ? AppColors.success : AppColors.warning,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() => _isTogglingAudit = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cambiar estado de auditoría'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isTogglingAudit = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoading = true);

    try {
      final auditLogService = ref.read(auditLogServiceProvider);
      final logs = await auditLogService.getAllAuditLogs();

      setState(() {
        _logs = logs;
        _filteredLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audit logs: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _logs.where((log) {
        final matchesSearch = _searchQuery.isEmpty ||
            log.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesAction = _selectedAction == null ||
            _selectedAction == 'All' ||
            log.action == _selectedAction;

        final matchesEntityType = _selectedEntityType == null ||
            _selectedEntityType == 'All' ||
            log.entityType == _selectedEntityType;

        final matchesSeverity = _selectedSeverity == null ||
            _selectedSeverity == 'All' ||
            log.severity == _selectedSeverity;

        final matchesDateRange = (_startDate == null || log.timestamp.isAfter(_startDate!)) &&
            (_endDate == null || log.timestamp.isBefore(_endDate!.add(const Duration(days: 1))));

        return matchesSearch &&
            matchesAction &&
            matchesEntityType &&
            matchesSeverity &&
            matchesDateRange;
      }).toList();
    });
  }

  Future<void> _seedLogs() async {
    try {
      final auditLogService = ref.read(auditLogServiceProvider);
      await auditLogService.seedAuditLogs(count: 50);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('50 audit logs seeded successfully')),
        );
        _loadAuditLogs();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding logs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark),
          _buildFilters(isDark),
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.cinemaGradient : null,
        color: isDark ? null : AppColors.lightSurfaceElevated,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Buttons
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Bitácora',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadAuditLogs,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Actualizar', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _seedLogs,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Seed', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: isDark ? AppColors.glowShadow : null,
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bitácora del Sistema',
                        style: AppTypography.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Registro de acciones y eventos del sistema',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _seedLogs,
                  icon: const Icon(Icons.add),
                  label: const Text('Seed Logs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _loadAuditLogs,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          SizedBox(height: isMobile ? AppSpacing.sm : AppSpacing.xl),

          // Audit Toggle
          Container(
            padding: isMobile
                ? EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _auditLoggingEnabled ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _auditLoggingEnabled ? AppColors.success : AppColors.warning,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _auditLoggingEnabled ? Icons.check_circle : Icons.warning,
                  color: _auditLoggingEnabled ? AppColors.success : AppColors.warning,
                  size: isMobile ? 16 : 20,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Auditoría',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 12,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      _auditLoggingEnabled ? 'ACTIVADA' : 'DESACTIVADA',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        color: _auditLoggingEnabled ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _isTogglingAudit
                    ? SizedBox(
                        width: isMobile ? 16 : 20,
                        height: isMobile ? 16 : 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _auditLoggingEnabled,
                        onChanged: _toggleAuditLogging,
                        activeColor: AppColors.success,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMD,
              ),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          SizedBox(height: isMobile ? AppSpacing.sm : AppSpacing.md),

          // Filters
          if (isMobile)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAction ?? 'All',
                        decoration: InputDecoration(
                          labelText: 'Acción',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                          ),
                        ),
                        items: _actions.map((action) {
                          return DropdownMenuItem(value: action, child: Text(action));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedAction = value);
                          _applyFilters();
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedEntityType ?? 'All',
                        decoration: InputDecoration(
                          labelText: 'Entidad',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                          ),
                        ),
                        items: _entityTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedEntityType = value);
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _selectedSeverity ?? 'All',
                  decoration: InputDecoration(
                    labelText: 'Severidad',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMD,
                    ),
                  ),
                  items: _severities.map((severity) {
                    return DropdownMenuItem(value: severity, child: Text(severity));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSeverity = value);
                    _applyFilters();
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAction ?? 'All',
                    decoration: InputDecoration(
                      labelText: 'Acción',
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                      ),
                    ),
                    items: _actions.map((action) {
                      return DropdownMenuItem(value: action, child: Text(action));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedAction = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEntityType ?? 'All',
                    decoration: InputDecoration(
                      labelText: 'Tipo de Entidad',
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                      ),
                    ),
                    items: _entityTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedEntityType = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSeverity ?? 'All',
                    decoration: InputDecoration(
                      labelText: 'Severidad',
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                      ),
                    ),
                    items: _severities.map((severity) {
                      return DropdownMenuItem(value: severity, child: Text(severity));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSeverity = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No hay registros de auditoría',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    // Calculate stats
    final totalLogs = _filteredLogs.length;
    final errorLogs = _filteredLogs.where((log) => log.severity == 'Error' || log.severity == 'Critical').length;
    final todayLogs = _filteredLogs.where((log) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      return logDate.isAtSameMomentAs(today);
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        Container(
          padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingMD,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isMobile ? 'Total' : 'Total Logs',
                  totalLogs.toString(),
                  Icons.list_alt,
                  AppColors.primary,
                  isDark,
                ),
              ),
              SizedBox(width: isMobile ? AppSpacing.xs : AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  isMobile ? 'Hoy' : 'Hoy',
                  todayLogs.toString(),
                  Icons.today,
                  Colors.blue,
                  isDark,
                ),
              ),
              SizedBox(width: isMobile ? AppSpacing.xs : AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  isMobile ? 'Errores' : 'Errores',
                  errorLogs.toString(),
                  Icons.error,
                  AppColors.error,
                  isDark,
                ),
              ),
            ],
          ),
        ),

        // Logs list
        Expanded(
          child: isMobile ? _buildLogsList(isDark) : _buildLogsTableView(isDark),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: isDark ? null : LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        color: isDark ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isMobile ? 14 : 20),
              SizedBox(width: isMobile ? 4 : AppSpacing.xs),
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 2 : AppSpacing.xs),
          Text(
            value,
            style: (isMobile ? AppTypography.titleLarge : AppTypography.headlineMedium).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(bool isDark) {
    return ListView.builder(
      padding: AppSpacing.paddingSM,
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        return _buildLogCard(context, _filteredLogs[index]);
      },
    );
  }

  Widget _buildLogCard(BuildContext context, AuditLog log) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with timestamp and action
          Padding(
            padding: AppSpacing.paddingSM,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildActionChip(log.action),
                SizedBox(width: AppSpacing.xs),
                _buildSeverityChip(log.severity),
              ],
            ),
          ),
          Divider(height: 1),
          // User and entity
          Padding(
            padding: AppSpacing.paddingSM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        log.userEmail,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      log.entityType,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  log.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (log.ipAddress.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.router, size: 12, color: AppColors.textTertiary),
                      SizedBox(width: 4),
                      Text(
                        log.ipAddress,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTableView(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: AppSpacing.borderRadiusMD,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          ),
          columns: const [
            DataColumn(label: Text('Fecha/Hora')),
            DataColumn(label: Text('Usuario')),
            DataColumn(label: Text('Acción')),
            DataColumn(label: Text('Entidad')),
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Severidad')),
            DataColumn(label: Text('IP')),
          ],
          rows: _filteredLogs.map((log) {
            return DataRow(
              cells: [
                DataCell(Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp),
                )),
                DataCell(Text(log.userEmail)),
                DataCell(_buildActionChip(log.action)),
                DataCell(Text(log.entityType)),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      log.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(_buildSeverityChip(log.severity)),
                DataCell(Text(log.ipAddress)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionChip(String action) {
    Color color;
    switch (action) {
      case 'CREATE':
        color = Colors.green;
        break;
      case 'UPDATE':
        color = Colors.blue;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      case 'VIEW':
        color = Colors.grey;
        break;
      case 'LOGIN':
        color = Colors.purple;
        break;
      case 'LOGOUT':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(action, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSeverityChip(String severity) {
    Color color;
    switch (severity) {
      case 'Critical':
        color = Colors.red;
        break;
      case 'Error':
        color = Colors.orange;
        break;
      case 'Warning':
        color = Colors.yellow;
        break;
      case 'Info':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(severity, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
