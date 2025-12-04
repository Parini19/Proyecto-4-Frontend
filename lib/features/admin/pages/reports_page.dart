import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/report.dart';
import '../../../core/services/reports_service.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/services/report_export_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  final ReportExportService _exportService = ReportExportService();

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: isMobile ? AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Reportes', style: AppTypography.titleMedium),
        ) : null,
        body: Column(
          children: [
            if (!isMobile) _buildHeader(isDark, isMobile),
            _buildTabs(isDark, isMobile),
            Expanded(child: _buildTabContent(isDark, isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isMobile) {
    return Container(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingLG,
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
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              size: isMobile ? 20 : 24,
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Volver al panel',
          ),
          Icon(Icons.analytics, color: AppColors.primary, size: isMobile ? 24 : 32),
          SizedBox(width: isMobile ? 8 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reportes y Analíticas',
                  style: isMobile
                    ? AppTypography.titleMedium
                    : AppTypography.headlineSmall,
                ),
                if (!isMobile)
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

  Widget _buildTabs(bool isDark, bool isMobile) {
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
        isScrollable: isMobile,
        labelStyle: isMobile
          ? AppTypography.bodySmall
          : AppTypography.bodyMedium,
        tabs: [
          Tab(text: isMobile ? 'Dashboard' : 'Dashboard'),
          Tab(text: isMobile ? 'Ventas' : 'Ventas'),
          Tab(text: isMobile ? 'Películas' : 'Películas Populares'),
          Tab(text: isMobile ? 'Ocupación' : 'Ocupación'),
          Tab(text: isMobile ? 'Ingresos' : 'Ingresos'),
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

  Widget _buildTabContent(bool isDark, bool isMobile) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDashboardTab(isDark, isMobile),
        _buildSalesTab(isDark, isMobile),
        _buildPopularityTab(isDark, isMobile),
        _buildOccupancyTab(isDark, isMobile),
        _buildRevenueTab(isDark, isMobile),
      ],
    );
  }

  Widget _buildDashboardTab(bool isDark, bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboardSummary == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingLG,
      child: Column(
        children: [
          _buildExportButtons(
            onExportExcel: () => _exportService.exportDashboardToExcel(_dashboardSummary!),
            onExportPDF: () => _exportService.exportDashboardToPDF(_dashboardSummary!),
          ),
          if (isMobile)
            ...[
              _buildStatCard('Películas Totales', _dashboardSummary!.totalMovies.toString(), Icons.movie, Colors.blue, isDark, isMobile),
              SizedBox(height: AppSpacing.xs),
              _buildStatCard('Funciones Totales', _dashboardSummary!.totalScreenings.toString(), Icons.event, Colors.green, isDark, isMobile),
              SizedBox(height: AppSpacing.xs),
              _buildStatCard('Funciones Hoy', _dashboardSummary!.todayScreenings.toString(), Icons.today, Colors.orange, isDark, isMobile),
              SizedBox(height: AppSpacing.xs),
              _buildStatCard('Combos de Comida', _dashboardSummary!.totalFoodCombos.toString(), Icons.fastfood, Colors.purple, isDark, isMobile),
              SizedBox(height: AppSpacing.xs),
              _buildStatCard('Reservas Totales', _dashboardSummary!.totalBookings.toString(), Icons.confirmation_number, Colors.teal, isDark, isMobile),
              SizedBox(height: AppSpacing.xs),
              _buildStatCard('Reservas Hoy', _dashboardSummary!.todayBookings.toString(), Icons.today, Colors.pink, isDark, isMobile),
              SizedBox(height: AppSpacing.xs),
              _buildStatCard('Usuarios', _dashboardSummary!.totalUsers.toString(), Icons.people, Colors.indigo, isDark, isMobile),
              SizedBox(height: AppSpacing.xs),
              _buildStatCard('Ingresos Hoy', CurrencyFormatter.formatCRC(_dashboardSummary!.todayRevenue), Icons.account_balance_wallet, Colors.green, isDark, isMobile),
            ]
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard('Películas Totales', _dashboardSummary!.totalMovies.toString(), Icons.movie, Colors.blue, isDark, isMobile),
                _buildStatCard('Funciones Totales', _dashboardSummary!.totalScreenings.toString(), Icons.event, Colors.green, isDark, isMobile),
                _buildStatCard('Funciones Hoy', _dashboardSummary!.todayScreenings.toString(), Icons.today, Colors.orange, isDark, isMobile),
                _buildStatCard('Combos de Comida', _dashboardSummary!.totalFoodCombos.toString(), Icons.fastfood, Colors.purple, isDark, isMobile),
                _buildStatCard('Reservas Totales', _dashboardSummary!.totalBookings.toString(), Icons.confirmation_number, Colors.teal, isDark, isMobile),
                _buildStatCard('Reservas Hoy', _dashboardSummary!.todayBookings.toString(), Icons.today, Colors.pink, isDark, isMobile),
                _buildStatCard('Usuarios', _dashboardSummary!.totalUsers.toString(), Icons.people, Colors.indigo, isDark, isMobile),
                _buildStatCard('Ingresos Hoy', CurrencyFormatter.formatCRC(_dashboardSummary!.todayRevenue), Icons.account_balance_wallet, Colors.green, isDark, isMobile),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 250,
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isMobile ? 24 : 32),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isMobile
                    ? AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)
                    : AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  value,
                  style: isMobile
                    ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)
                    : AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab(bool isDark, bool isMobile) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadSalesReport, isMobile),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _salesReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildSalesContent(isDark, isMobile),
        ),
      ],
    );
  }

  Widget _buildSalesContent(bool isDark, bool isMobile) {
    return SingleChildScrollView(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExportButtons(
            onExportExcel: () => _exportService.exportSalesReportToExcel(_salesReport!),
            onExportPDF: () => _exportService.exportSalesReportToPDF(_salesReport!),
          ),
          isMobile
            ? Column(
                children: [
                  _buildStatCard('Ventas Totales', CurrencyFormatter.formatCRC(_salesReport!.totalSales), Icons.account_balance_wallet, Colors.green, isDark, isMobile),
                  SizedBox(height: AppSpacing.xs),
                  _buildStatCard('Total Reservas', _salesReport!.totalBookings.toString(), Icons.confirmation_number, Colors.blue, isDark, isMobile),
                  SizedBox(height: AppSpacing.xs),
                  _buildStatCard('Promedio por Reserva', CurrencyFormatter.formatCRC(_salesReport!.averageBookingValue), Icons.trending_up, Colors.purple, isDark, isMobile),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Ventas Totales', CurrencyFormatter.formatCRC(_salesReport!.totalSales), Icons.account_balance_wallet, Colors.green, isDark, isMobile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Total Reservas', _salesReport!.totalBookings.toString(), Icons.confirmation_number, Colors.blue, isDark, isMobile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Promedio por Reserva', CurrencyFormatter.formatCRC(_salesReport!.averageBookingValue), Icons.trending_up, Colors.purple, isDark, isMobile),
                  ),
                ],
              ),
          SizedBox(height: isMobile ? 16 : 24),
          Text('Desglose Diario', style: isMobile ? AppTypography.titleMedium : AppTypography.titleLarge),
          SizedBox(height: isMobile ? 12 : 16),
          _buildDailyBreakdownTable(isDark, isMobile),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdownTable(bool isDark, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: isMobile ? 20 : 56,
          dataRowHeight: isMobile ? 40 : 48,
          headingRowHeight: isMobile ? 40 : 56,
          columns: [
            DataColumn(label: Text('Fecha', style: isMobile ? AppTypography.bodySmall : null)),
            DataColumn(label: Text('Ventas', style: isMobile ? AppTypography.bodySmall : null)),
            DataColumn(label: Text('Cantidad', style: isMobile ? AppTypography.bodySmall : null)),
          ],
          rows: _salesReport!.dailyBreakdown.map((day) {
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('dd/MM/yyyy').format(day.date), style: isMobile ? AppTypography.bodySmall : null)),
                DataCell(Text(CurrencyFormatter.formatCRC(day.sales), style: isMobile ? AppTypography.bodySmall : null)),
                DataCell(Text(day.count.toString(), style: isMobile ? AppTypography.bodySmall : null)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPopularityTab(bool isDark, bool isMobile) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadPopularityReport, isMobile),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _popularityReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildPopularityContent(isDark, isMobile),
        ),
      ],
    );
  }

  Widget _buildPopularityContent(bool isDark, bool isMobile) {
    return SingleChildScrollView(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExportButtons(
            onExportExcel: () => _exportService.exportPopularityReportToExcel(_popularityReport!),
            onExportPDF: () => _exportService.exportPopularityReportToPDF(_popularityReport!),
          ),
          Text(
            'Top 10 Películas Más Populares',
            style: isMobile ? AppTypography.titleMedium : AppTypography.titleLarge,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: isMobile ? 20 : 56,
                dataRowHeight: isMobile ? 40 : 48,
                headingRowHeight: isMobile ? 40 : 56,
                columns: [
                  DataColumn(label: Text('Película', style: isMobile ? AppTypography.bodySmall : null)),
                  DataColumn(label: Text('Reservas', style: isMobile ? AppTypography.bodySmall : null)),
                  DataColumn(label: Text('Ingresos', style: isMobile ? AppTypography.bodySmall : null)),
                ],
                rows: _popularityReport!.topMovies.map((movie) {
                  return DataRow(
                    cells: [
                      DataCell(Text(movie.title, style: isMobile ? AppTypography.bodySmall : null)),
                      DataCell(Text(movie.bookings.toString(), style: isMobile ? AppTypography.bodySmall : null)),
                      DataCell(Text(CurrencyFormatter.formatCRC(movie.revenue), style: isMobile ? AppTypography.bodySmall : null)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyTab(bool isDark, bool isMobile) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadOccupancyReport, isMobile),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _occupancyReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildOccupancyContent(isDark, isMobile),
        ),
      ],
    );
  }

  Widget _buildOccupancyContent(bool isDark, bool isMobile) {
    return SingleChildScrollView(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExportButtons(
            onExportExcel: () => _exportService.exportOccupancyReportToExcel(_occupancyReport!),
            onExportPDF: () => _exportService.exportOccupancyReportToPDF(_occupancyReport!),
          ),
          isMobile
            ? Column(
                children: [
                  _buildStatCard('Funciones Totales', _occupancyReport!.totalScreenings.toString(), Icons.event, Colors.blue, isDark, isMobile),
                  SizedBox(height: AppSpacing.xs),
                  _buildStatCard('Ocupación Promedio', '${_occupancyReport!.averageOccupancyRate}%', Icons.people, Colors.green, isDark, isMobile),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Funciones Totales', _occupancyReport!.totalScreenings.toString(), Icons.event, Colors.blue, isDark, isMobile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Ocupación Promedio', '${_occupancyReport!.averageOccupancyRate}%', Icons.people, Colors.green, isDark, isMobile),
                  ),
                ],
              ),
          SizedBox(height: isMobile ? 16 : 24),
          Text('Funciones por Día', style: isMobile ? AppTypography.titleMedium : AppTypography.titleLarge),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: isMobile ? 20 : 56,
                dataRowHeight: isMobile ? 40 : 48,
                headingRowHeight: isMobile ? 40 : 56,
                columns: [
                  DataColumn(label: Text('Fecha', style: isMobile ? AppTypography.bodySmall : null)),
                  DataColumn(label: Text('Cantidad de Funciones', style: isMobile ? AppTypography.bodySmall : null)),
                ],
                rows: _occupancyReport!.screeningsByDay.map((day) {
                  return DataRow(
                    cells: [
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(day.date), style: isMobile ? AppTypography.bodySmall : null)),
                      DataCell(Text(day.count.toString(), style: isMobile ? AppTypography.bodySmall : null)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(bool isDark, bool isMobile) {
    return Column(
      children: [
        _buildDateRangeSelector(isDark, _loadRevenueReport, isMobile),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _revenueReport == null
                  ? const Center(child: Text('No data available'))
                  : _buildRevenueContent(isDark, isMobile),
        ),
      ],
    );
  }

  Widget _buildRevenueContent(bool isDark, bool isMobile) {
    return SingleChildScrollView(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExportButtons(
            onExportExcel: () => _exportService.exportRevenueReportToExcel(_revenueReport!),
            onExportPDF: () => _exportService.exportRevenueReportToPDF(_revenueReport!),
          ),
          isMobile
            ? Column(
                children: [
                  _buildStatCard('Ingresos Totales', CurrencyFormatter.formatCRC(_revenueReport!.totalRevenue), Icons.account_balance_wallet, Colors.green, isDark, isMobile),
                  SizedBox(height: AppSpacing.xs),
                  _buildStatCard('Ingresos por Entradas', CurrencyFormatter.formatCRC(_revenueReport!.ticketRevenue), Icons.confirmation_number, Colors.blue, isDark, isMobile),
                  SizedBox(height: AppSpacing.xs),
                  _buildStatCard('Ingresos por Comida', CurrencyFormatter.formatCRC(_revenueReport!.foodRevenue), Icons.fastfood, Colors.orange, isDark, isMobile),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Ingresos Totales', CurrencyFormatter.formatCRC(_revenueReport!.totalRevenue), Icons.account_balance_wallet, Colors.green, isDark, isMobile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Ingresos por Entradas', CurrencyFormatter.formatCRC(_revenueReport!.ticketRevenue), Icons.confirmation_number, Colors.blue, isDark, isMobile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Ingresos por Comida', CurrencyFormatter.formatCRC(_revenueReport!.foodRevenue), Icons.fastfood, Colors.orange, isDark, isMobile),
                  ),
                ],
              ),
          SizedBox(height: isMobile ? 16 : 24),
          Text('Desglose de Ingresos', style: isMobile ? AppTypography.titleMedium : AppTypography.titleLarge),
          SizedBox(height: isMobile ? 12 : 16),
          isMobile
            ? Column(
                children: [
                  Container(
                    padding: AppSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: AppSpacing.borderRadiusMD,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('Entradas', style: AppTypography.titleSmall),
                        const SizedBox(height: 8),
                        Text(CurrencyFormatter.formatCRC(_revenueReport!.breakdown.tickets.revenue), style: AppTypography.titleLarge.copyWith(color: Colors.blue)),
                        Text('${_revenueReport!.breakdown.tickets.percentage.toStringAsFixed(1)}%', style: AppTypography.bodyMedium),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: AppSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: AppSpacing.borderRadiusMD,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('Comida', style: AppTypography.titleSmall),
                        const SizedBox(height: 8),
                        Text(CurrencyFormatter.formatCRC(_revenueReport!.breakdown.food.revenue), style: AppTypography.titleLarge.copyWith(color: Colors.orange)),
                        Text('${_revenueReport!.breakdown.food.percentage.toStringAsFixed(1)}%', style: AppTypography.bodyMedium),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
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
                          Text(CurrencyFormatter.formatCRC(_revenueReport!.breakdown.tickets.revenue), style: AppTypography.headlineMedium.copyWith(color: Colors.blue)),
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
                          Text(CurrencyFormatter.formatCRC(_revenueReport!.breakdown.food.revenue), style: AppTypography.headlineMedium.copyWith(color: Colors.orange)),
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

  Widget _buildDateRangeSelector(bool isDark, VoidCallback onGenerate, bool isMobile) {
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
      child: isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Rango de Fechas:', style: AppTypography.bodySmall),
              SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
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
                  icon: Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Fecha Inicio',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
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
                  icon: Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Fecha Fin',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onGenerate,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Generar Reporte', style: AppTypography.bodySmall),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          )
        : Row(
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

  // Helper widget para botones de descarga (solo web)
  Widget _buildExportButtons({
    required VoidCallback onExportExcel,
    required VoidCallback onExportPDF,
  }) {
    if (!kIsWeb) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: onExportExcel,
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: BorderSide(color: AppColors.success),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: onExportPDF,
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
