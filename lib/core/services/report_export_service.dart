import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../models/report.dart';
import '../utils/currency_formatter.dart';

class ReportExportService {
  // ==================== EXCEL EXPORTS ====================

  /// Exporta el dashboard a Excel
  Future<void> exportDashboardToExcel(DashboardSummary dashboard) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Dashboard'];

    // Header styling
    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    // Title
    sheet.cell(CellIndex.indexByString('A1'))
      ..value = TextCellValue('Dashboard - Cinema')
      ..cellStyle = headerStyle;

    // Data headers
    int row = 3;
    sheet.cell(CellIndex.indexByString('A$row'))
      ..value = TextCellValue('Métrica')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('B$row'))
      ..value = TextCellValue('Valor')
      ..cellStyle = headerStyle;

    // Data
    row++;
    _addExcelRow(sheet, row++, 'Películas Totales', dashboard.totalMovies.toString());
    _addExcelRow(sheet, row++, 'Funciones Totales', dashboard.totalScreenings.toString());
    _addExcelRow(sheet, row++, 'Funciones Hoy', dashboard.todayScreenings.toString());
    _addExcelRow(sheet, row++, 'Combos de Comida', dashboard.totalFoodCombos.toString());
    _addExcelRow(sheet, row++, 'Reservas Totales', dashboard.totalBookings.toString());
    _addExcelRow(sheet, row++, 'Reservas Hoy', dashboard.todayBookings.toString());
    _addExcelRow(sheet, row++, 'Usuarios', dashboard.totalUsers.toString());
    _addExcelRow(sheet, row++, 'Ingresos Hoy', CurrencyFormatter.formatCRC(dashboard.todayRevenue));

    // Ajustar ancho de columnas
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 25);

    // Eliminar Sheet1 por defecto
    excel.delete('Sheet1');

    _downloadExcel(excel, 'dashboard_${DateTime.now().millisecondsSinceEpoch}.xlsx');
  }

  /// Exporta el reporte de ventas a Excel
  Future<void> exportSalesReportToExcel(SalesReportData report) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Reporte de Ventas'];

    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    // Title
    sheet.cell(CellIndex.indexByString('A1'))
      ..value = TextCellValue('Reporte de Ventas - Cinema')
      ..cellStyle = headerStyle;

    // Summary
    int row = 3;
    _addExcelRow(sheet, row++, 'Total Reservas', report.totalBookings.toString());
    _addExcelRow(sheet, row++, 'Ventas Totales', CurrencyFormatter.formatCRC(report.totalSales));
    _addExcelRow(sheet, row++, 'Promedio por Reserva', CurrencyFormatter.formatCRC(report.averageBookingValue));

    // Daily breakdown
    row += 2;
    sheet.cell(CellIndex.indexByString('A$row'))
      ..value = TextCellValue('Desglose Diario')
      ..cellStyle = headerStyle;

    row++;
    sheet.cell(CellIndex.indexByString('A$row'))..value = TextCellValue('Fecha')..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('B$row'))..value = TextCellValue('Reservas')..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('C$row'))..value = TextCellValue('Ventas')..cellStyle = headerStyle;

    for (var day in report.dailyBreakdown) {
      row++;
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(DateFormat('dd/MM/yyyy').format(day.date));
      sheet.cell(CellIndex.indexByString('B$row')).value = IntCellValue(day.count);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(CurrencyFormatter.formatCRC(day.sales));
    }

    // Ajustar ancho de columnas
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 25);

    // Eliminar Sheet1 por defecto
    excel.delete('Sheet1');

    _downloadExcel(excel, 'ventas_${DateTime.now().millisecondsSinceEpoch}.xlsx');
  }

  /// Exporta el reporte de popularidad a Excel
  Future<void> exportPopularityReportToExcel(MoviePopularityReportData report) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Popularidad'];

    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    // Title
    sheet.cell(CellIndex.indexByString('A1'))
      ..value = TextCellValue('Reporte de Popularidad - Cinema')
      ..cellStyle = headerStyle;

    // Headers
    int row = 3;
    sheet.cell(CellIndex.indexByString('A$row'))..value = TextCellValue('Película')..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('B$row'))..value = TextCellValue('Reservas')..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('C$row'))..value = TextCellValue('Ingresos')..cellStyle = headerStyle;

    for (var movie in report.topMovies) {
      row++;
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(movie.title);
      sheet.cell(CellIndex.indexByString('B$row')).value = IntCellValue(movie.bookings);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(CurrencyFormatter.formatCRC(movie.revenue));
    }

    // Ajustar ancho de columnas
    sheet.setColumnWidth(0, 35);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 25);

    // Eliminar Sheet1 por defecto
    excel.delete('Sheet1');

    _downloadExcel(excel, 'popularidad_${DateTime.now().millisecondsSinceEpoch}.xlsx');
  }

  /// Exporta el reporte de ocupación a Excel
  Future<void> exportOccupancyReportToExcel(OccupancyReportData report) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Ocupación'];

    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    sheet.cell(CellIndex.indexByString('A1'))
      ..value = TextCellValue('Reporte de Ocupación - Cinema')
      ..cellStyle = headerStyle;

    int row = 3;
    _addExcelRow(sheet, row++, 'Funciones Totales', report.totalScreenings.toString());
    _addExcelRow(sheet, row++, 'Ocupación Promedio', '${report.averageOccupancyRate}%');

    // Ajustar ancho de columnas
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 25);

    // Eliminar Sheet1 por defecto
    excel.delete('Sheet1');

    _downloadExcel(excel, 'ocupacion_${DateTime.now().millisecondsSinceEpoch}.xlsx');
  }

  /// Exporta el reporte de ingresos a Excel
  Future<void> exportRevenueReportToExcel(RevenueReportData report) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Ingresos'];

    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    sheet.cell(CellIndex.indexByString('A1'))
      ..value = TextCellValue('Reporte de Ingresos - Cinema')
      ..cellStyle = headerStyle;

    int row = 3;
    _addExcelRow(sheet, row++, 'Ingresos Totales', CurrencyFormatter.formatCRC(report.totalRevenue));
    _addExcelRow(sheet, row++, 'Ingresos por Entradas', CurrencyFormatter.formatCRC(report.ticketRevenue));
    _addExcelRow(sheet, row++, 'Ingresos por Comida', CurrencyFormatter.formatCRC(report.foodRevenue));

    row += 2;
    sheet.cell(CellIndex.indexByString('A$row'))
      ..value = TextCellValue('Desglose Detallado')
      ..cellStyle = headerStyle;

    row++;
    _addExcelRow(sheet, row++, 'Entradas - Ingresos', CurrencyFormatter.formatCRC(report.breakdown.tickets.revenue));
    _addExcelRow(sheet, row++, 'Entradas - Porcentaje', '${report.breakdown.tickets.percentage.toStringAsFixed(1)}%');
    _addExcelRow(sheet, row++, 'Comida - Ingresos', CurrencyFormatter.formatCRC(report.breakdown.food.revenue));
    _addExcelRow(sheet, row++, 'Comida - Porcentaje', '${report.breakdown.food.percentage.toStringAsFixed(1)}%');

    // Ajustar ancho de columnas
    sheet.setColumnWidth(0, 35);
    sheet.setColumnWidth(1, 30);

    // Eliminar Sheet1 por defecto
    excel.delete('Sheet1');

    _downloadExcel(excel, 'ingresos_${DateTime.now().millisecondsSinceEpoch}.xlsx');
  }

  // ==================== PDF EXPORTS ====================

  /// Exporta el dashboard a PDF
  Future<void> exportDashboardToPDF(DashboardSummary dashboard) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfHeader('Dashboard - Cinema'),
              pw.SizedBox(height: 20),
              _pdfDataRow('Películas Totales', dashboard.totalMovies.toString()),
              _pdfDataRow('Funciones Totales', dashboard.totalScreenings.toString()),
              _pdfDataRow('Funciones Hoy', dashboard.todayScreenings.toString()),
              _pdfDataRow('Combos de Comida', dashboard.totalFoodCombos.toString()),
              _pdfDataRow('Reservas Totales', dashboard.totalBookings.toString()),
              _pdfDataRow('Reservas Hoy', dashboard.todayBookings.toString()),
              _pdfDataRow('Usuarios', dashboard.totalUsers.toString()),
              _pdfDataRow('Ingresos Hoy', CurrencyFormatter.formatCRCForPDF(dashboard.todayRevenue)),
              pw.SizedBox(height: 20),
              _pdfFooter(),
            ],
          );
        },
      ),
    );

    await _downloadPDF(pdf, 'dashboard_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Exporta el reporte de ventas a PDF
  Future<void> exportSalesReportToPDF(SalesReportData report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _pdfHeader('Reporte de Ventas - Cinema'),
            pw.SizedBox(height: 20),
            _pdfDataRow('Total Reservas', report.totalBookings.toString()),
            _pdfDataRow('Ventas Totales', CurrencyFormatter.formatCRCForPDF(report.totalSales)),
            _pdfDataRow('Promedio por Reserva', CurrencyFormatter.formatCRCForPDF(report.averageBookingValue)),
            pw.SizedBox(height: 30),
            pw.Text('Desglose Diario', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Fecha', 'Reservas', 'Ventas'],
              data: report.dailyBreakdown.map((day) => [
                DateFormat('dd/MM/yyyy').format(day.date),
                day.count.toString(),
                CurrencyFormatter.formatCRCForPDF(day.sales),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            _pdfFooter(),
          ];
        },
      ),
    );

    await _downloadPDF(pdf, 'ventas_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Exporta el reporte de popularidad a PDF
  Future<void> exportPopularityReportToPDF(MoviePopularityReportData report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _pdfHeader('Reporte de Popularidad - Cinema'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Película', 'Reservas', 'Ingresos'],
              data: report.topMovies.map((movie) => [
                movie.title,
                movie.bookings.toString(),
                CurrencyFormatter.formatCRCForPDF(movie.revenue),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            _pdfFooter(),
          ];
        },
      ),
    );

    await _downloadPDF(pdf, 'popularidad_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Exporta el reporte de ocupación a PDF
  Future<void> exportOccupancyReportToPDF(OccupancyReportData report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfHeader('Reporte de Ocupación - Cinema'),
              pw.SizedBox(height: 20),
              _pdfDataRow('Funciones Totales', report.totalScreenings.toString()),
              _pdfDataRow('Ocupación Promedio', '${report.averageOccupancyRate}%'),
              pw.SizedBox(height: 20),
              _pdfFooter(),
            ],
          );
        },
      ),
    );

    await _downloadPDF(pdf, 'ocupacion_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Exporta el reporte de ingresos a PDF
  Future<void> exportRevenueReportToPDF(RevenueReportData report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfHeader('Reporte de Ingresos - Cinema'),
              pw.SizedBox(height: 20),
              _pdfDataRow('Ingresos Totales', CurrencyFormatter.formatCRCForPDF(report.totalRevenue)),
              _pdfDataRow('Ingresos por Entradas', CurrencyFormatter.formatCRCForPDF(report.ticketRevenue)),
              _pdfDataRow('Ingresos por Comida', CurrencyFormatter.formatCRCForPDF(report.foodRevenue)),
              pw.SizedBox(height: 30),
              pw.Text('Desglose Detallado', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _pdfDataRow('Entradas - Ingresos', CurrencyFormatter.formatCRCForPDF(report.breakdown.tickets.revenue)),
              _pdfDataRow('Entradas - Porcentaje', '${report.breakdown.tickets.percentage.toStringAsFixed(1)}%'),
              _pdfDataRow('Comida - Ingresos', CurrencyFormatter.formatCRCForPDF(report.breakdown.food.revenue)),
              _pdfDataRow('Comida - Porcentaje', '${report.breakdown.food.percentage.toStringAsFixed(1)}%'),
              pw.SizedBox(height: 20),
              _pdfFooter(),
            ],
          );
        },
      ),
    );

    await _downloadPDF(pdf, 'ingresos_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // ==================== HELPER METHODS ====================

  void _addExcelRow(Sheet sheet, int row, String label, String value) {
    sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(label);
    sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(value);
  }

  pw.Widget _pdfHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      color: PdfColors.blue700,
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _pdfDataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _pdfFooter() {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  void _downloadExcel(Excel excel, String filename) {
    final bytes = excel.encode();
    if (bytes != null) {
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<void> _downloadPDF(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
