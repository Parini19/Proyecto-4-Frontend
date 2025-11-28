class Booking {
  final String id;
  final String userId;
  final String screeningId;
  final List<String> seatNumbers;
  final int ticketQuantity;
  final double ticketPrice;
  final double subtotalTickets;
  final String? foodOrderId;
  final double subtotalFood;
  final double tax;
  final double total;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? paymentId;

  Booking({
    required this.id,
    required this.userId,
    required this.screeningId,
    required this.seatNumbers,
    required this.ticketQuantity,
    required this.ticketPrice,
    required this.subtotalTickets,
    this.foodOrderId,
    required this.subtotalFood,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.paymentId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      screeningId: json['screeningId'] as String,
      seatNumbers: List<String>.from(json['seatNumbers'] as List),
      ticketQuantity: json['ticketQuantity'] as int,
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      subtotalTickets: (json['subtotalTickets'] as num).toDouble(),
      foodOrderId: json['foodOrderId'] as String?,
      subtotalFood: (json['subtotalFood'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      paymentId: json['paymentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'screeningId': screeningId,
      'seatNumbers': seatNumbers,
      'ticketQuantity': ticketQuantity,
      'ticketPrice': ticketPrice,
      'subtotalTickets': subtotalTickets,
      'foodOrderId': foodOrderId,
      'subtotalFood': subtotalFood,
      'tax': tax,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'paymentId': paymentId,
    };
  }
}

class CreateBookingRequest {
  final String userId;
  final String screeningId;
  final List<String> seatNumbers;
  final int ticketQuantity;
  final double ticketPrice;
  final String? foodOrderId;

  CreateBookingRequest({
    required this.userId,
    required this.screeningId,
    required this.seatNumbers,
    required this.ticketPrice,
    this.foodOrderId,
  }) : ticketQuantity = seatNumbers.length;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'screeningId': screeningId,
      'seatNumbers': seatNumbers,
      'ticketQuantity': ticketQuantity,
      'ticketPrice': ticketPrice,
      'foodOrderId': foodOrderId,
    };
  }
}
