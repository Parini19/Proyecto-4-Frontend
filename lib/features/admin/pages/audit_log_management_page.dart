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
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bitácora del Sistema', style: AppTypography.headlineSmall),
                Text(
                  'Registro de acciones y eventos',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
          const SizedBox(width: 16),
          // Toggle de auditoría
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Auditoría',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      _auditLoggingEnabled ? 'ACTIVADA' : 'DESACTIVADA',
                      style: TextStyle(
                        fontSize: 10,
                        color: _auditLoggingEnabled ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                _isTogglingAudit
                    ? SizedBox(
                        width: 20,
                        height: 20,
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
    return Container(
      padding: AppSpacing.paddingMD,
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
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
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
              ),
              const SizedBox(width: 16),
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

    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_filteredLogs.length} registros encontrados',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLogsTable(isDark),
        ],
      ),
    );
  }

  Widget _buildLogsTable(bool isDark) {
    return Container(
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
