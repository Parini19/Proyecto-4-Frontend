class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String cardLastFourDigits;
  final String cardBrand;
  final String status; // 'pending', 'approved', 'rejected'
  final String? transactionId;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? processedAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.cardLastFourDigits,
    required this.cardBrand,
    required this.status,
    this.transactionId,
    this.rejectionReason,
    required this.createdAt,
    this.processedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      cardLastFourDigits: json['cardLastFourDigits'] as String,
      cardBrand: json['cardBrand'] as String,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
    );
  }
}

class PaymentRequest {
  final String bookingId;
  final double amount;
  final String cardNumber;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;

  PaymentRequest({
    required this.bookingId,
    required this.amount,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
    };
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final Payment? payment;
  final Map<String, dynamic>? booking;
  final int? ticketsGenerated;
  final String? invoiceNumber;

  PaymentResult({
    required this.success,
    required this.message,
    this.payment,
    this.booking,
    this.ticketsGenerated,
    this.invoiceNumber,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      booking: json['booking'] as Map<String, dynamic>?,
      ticketsGenerated: json['ticketsGenerated'] as int?,
      invoiceNumber: json['invoiceNumber'] as String?,
    );
  }
}
