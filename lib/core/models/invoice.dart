class Invoice {
  final String id;
  final String bookingId;
  final String userId;
  final String invoiceNumber;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime issuedAt;

  Invoice({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.issuedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      issuedAt: DateTime.parse(json['issuedAt'] as String),
    );
  }
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
