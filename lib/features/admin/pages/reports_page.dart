import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/report.dart';
import '../../../core/services/reports_service.dart';
import '../../../core/providers/service_providers.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  SalesReportData? _salesReport;
  MoviePopularityReportData? _popularityReport;
  OccupancyReportData? _occupancyReport;
  RevenueReportData? _revenueReport;
  DashboardSummary? _dashboardSummary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDashboardSummary();

    // Set default date range (last 30 days)
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardSummary() async {
    setState(() => _isLoading = true);

    try {
      final reportsService = ref.read(reportsServiceProvider);
      final summary = await reportsService.getDashboardSummary();

      setState(() {
        _dashboardSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  Future<void> _loadSalesReport() async {
    setState(() => _isLoading = true);

    try {
      final reportsService = ref.read(reportsServiceProvider);
      final report = await reportsService.getSalesReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _salesReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sales report: $e')),
        );
      }
    }
  }

  Future<void> _loadPopularityReport() async {
    setState(() => _isLoading = true);

    try {
      final reportsService = ref.read(reportsServiceProvider);
      final report = await reportsService.getMoviePopularityReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _popularityReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading popularity report: $e')),
        );
      }
    }
  }

  Future<void> _loadOccupancyReport() async {
    setState(() => _isLoading = true);

    try {
      final reportsService = ref.read(reportsServiceProvider);
      final report = await reportsService.getOccupancyReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _occupancyReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading occupancy report: $e')),
        );
      }
    }
  }

  Future<void> _loadRevenueReport() async {
    setState(() => _isLoading = true);

    try {
      final reportsService = ref.read(reportsServiceProvider);
      final report = await reportsService.getRevenueReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _revenueReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading revenue report: $e')),
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
          _buildTabs(isDark),
          Expanded(child: _buildTabContent(isDark)),
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
          IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Volver al panel',
          ),
          Icon(Icons.analytics, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reportes y Analíticas', style: AppTypography.headlineSmall),
                Text(
                  'Análisis de rendimiento y estadísticas',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Ventas'),
          Tab(text: 'Películas Populares'),
          Tab(text: 'Ocupación'),
          Tab(text: 'Ingresos'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _loadDashboardSummary();
              break;
            case 1:
              if (_salesReport == null) _loadSalesReport();
              break;
            case 2:
              if (_popularityReport == null) _loadPopularityReport();
              break;
            case 3:
              if (_occupancyReport == null) _loadOccupancyReport();
              break;
            case 4:
              if (_revenueReport == null) _loadRevenueReport();
              break;
          }
        },
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDashboardTab(isDark),
        _buildSalesTab(isDark),
        _buildPopularityTab(isDark),
        _buildOccupancyTab(isDark),
        _buildRevenueTab(isDark),
      ],
    );
  }

  Widget _buildDashboardTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboardSummary == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildStatCard('Películas Totales', _dashboardSummary!.totalMovies.toString(), Icons.movie, Colors.blue, isDark),
          _buildStatCard('Funciones Totales', _dashboardSummary!.totalScreenings.toString(), Icons.event, Colors.green, isDark),
          _buildStatCard('Funciones Hoy', _dashboardSummary!.todayScreenings.toString(), Icons.today, Colors.orange, isDark),
          _buildStatCard('Combos de Comida', _dashboardSummary!.totalFoodCombos.toString(), Icons.fastfood, Colors.purple, isDark),
          _buildStatCard('Reservas Totales', _dashboardSummary!.totalBookings.toString(), Icons.confirmation_number, Colors.teal, isDark),
          _buildStatCard('Reservas Hoy', _dashboardSummary!.todayBookings.toString(), Icons.today, Colors.pink, isDark),
          _buildStatCard('Usuarios', _dashboardSummary!.totalUsers.toString(), Icons.people, Colors.indigo, isDark),
          _buildStatCard('Ingresos Hoy', '\$${_dashboardSummary!.todayRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.green, isDark),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      width: 250,
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab(bool isDark) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadSalesReport),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _salesReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildSalesContent(isDark),
        ),
      ],
    );
  }

  Widget _buildSalesContent(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Ventas Totales', '\$${_salesReport!.totalSales.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.green, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Total Reservas', _salesReport!.totalBookings.toString(), Icons.confirmation_number, Colors.blue, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Promedio por Reserva', '\$${_salesReport!.averageBookingValue.toStringAsFixed(2)}', Icons.trending_up, Colors.purple, isDark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Desglose Diario', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          _buildDailyBreakdownTable(isDark),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdownTable(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Fecha')),
          DataColumn(label: Text('Ventas')),
          DataColumn(label: Text('Cantidad')),
        ],
        rows: _salesReport!.dailyBreakdown.map((day) {
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('dd/MM/yyyy').format(day.date))),
              DataCell(Text('\$${day.sales.toStringAsFixed(2)}')),
              DataCell(Text(day.count.toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularityTab(bool isDark) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadPopularityReport),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _popularityReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildPopularityContent(isDark),
        ),
      ],
    );
  }

  Widget _buildPopularityContent(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top 10 Películas Más Populares', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Película')),
                DataColumn(label: Text('Reservas')),
                DataColumn(label: Text('Ingresos')),
              ],
              rows: _popularityReport!.topMovies.map((movie) {
                return DataRow(
                  cells: [
                    DataCell(Text(movie.title)),
                    DataCell(Text(movie.bookings.toString())),
                    DataCell(Text('\$${movie.revenue.toStringAsFixed(2)}')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyTab(bool isDark) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadOccupancyReport),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _occupancyReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildOccupancyContent(isDark),
        ),
      ],
    );
  }

  Widget _buildOccupancyContent(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Funciones Totales', _occupancyReport!.totalScreenings.toString(), Icons.event, Colors.blue, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Ocupación Promedio', '${_occupancyReport!.averageOccupancyRate}%', Icons.people, Colors.green, isDark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Funciones por Día', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Cantidad de Funciones')),
              ],
              rows: _occupancyReport!.screeningsByDay.map((day) {
                return DataRow(
                  cells: [
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(day.date))),
                    DataCell(Text(day.count.toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(bool isDark) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadRevenueReport),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _revenueReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildRevenueContent(isDark),
        ),
      ],
    );
  }

  Widget _buildRevenueContent(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Ingresos Totales', '\$${_revenueReport!.totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.green, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Ingresos por Entradas', '\$${_revenueReport!.ticketRevenue.toStringAsFixed(2)}', Icons.confirmation_number, Colors.blue, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Ingresos por Comida', '\$${_revenueReport!.foodRevenue.toStringAsFixed(2)}', Icons.fastfood, Colors.orange, isDark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Desglose de Ingresos', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: AppSpacing.borderRadiusMD,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('Entradas', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text('\$${_revenueReport!.breakdown.tickets.revenue.toStringAsFixed(2)}', style: AppTypography.headlineMedium.copyWith(color: Colors.blue)),
                      Text('${_revenueReport!.breakdown.tickets.percentage.toStringAsFixed(1)}%', style: AppTypography.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: AppSpacing.borderRadiusMD,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('Comida', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text('\$${_revenueReport!.breakdown.food.revenue.toStringAsFixed(2)}', style: AppTypography.headlineMedium.copyWith(color: Colors.orange)),
                      Text('${_revenueReport!.breakdown.food.percentage.toStringAsFixed(1)}%', style: AppTypography.bodyLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(bool isDark, VoidCallback onGenerate) {
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
      child: Row(
        children: [
          Text('Rango de Fechas:', style: AppTypography.bodyMedium),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _startDate = picked);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Fecha Inicio'),
          ),
          const SizedBox(width: 8),
          Text('a', style: AppTypography.bodyMedium),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now(),
                firstDate: _startDate ?? DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _endDate = picked);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Fecha Fin'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.refresh),
            label: const Text('Generar Reporte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
