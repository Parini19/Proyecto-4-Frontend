import 'package:intl/intl.dart';

/// Utility class for formatting currency in Costa Rican Colones (CRC)
class CurrencyFormatter {
  /// Formats a number as Costa Rican Colones
  /// Example: 3500 -> ₡3,500
  /// Example: 12500.5 -> ₡12,501 (rounds to nearest colon)
  static String formatCRC(double amount) {
    // Round to nearest whole number (colones don't use decimals)
    final roundedAmount = amount.round();

    // Format with thousand separators
    final formatter = NumberFormat('#,###', 'es_CR');
    return '₡${formatter.format(roundedAmount)}';
  }

  /// Formats a number as Costa Rican Colones without the symbol
  /// Example: 3500 -> 3,500
  static String formatCRCWithoutSymbol(double amount) {
    final roundedAmount = amount.round();
    final formatter = NumberFormat('#,###', 'es_CR');
    return formatter.format(roundedAmount);
  }

  /// Parses a CRC string back to a number
  /// Example: "₡3,500" -> 3500.0
  /// Example: "3,500" -> 3500.0
  static double parseCRC(String amount) {
    // Remove currency symbol and commas
    final cleaned = amount.replaceAll('₡', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
