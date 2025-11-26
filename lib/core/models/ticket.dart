class Ticket {
  final String id;
  final String bookingId;
  final String userId;
  final String screeningId;
  final String movieTitle;
  final String theaterRoomName;
  final String seatNumber;
  final DateTime showTime;
  final String qrCode; // Base64 image
  final String qrCodeData; // Encoded ticket data
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime expiresAt;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.screeningId,
    required this.movieTitle,
    required this.theaterRoomName,
    required this.seatNumber,
    required this.showTime,
    required this.qrCode,
    required this.qrCodeData,
    required this.isUsed,
    this.usedAt,
    required this.expiresAt,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      screeningId: json['screeningId'] as String,
      movieTitle: json['movieTitle'] as String,
      theaterRoomName: json['theaterRoomName'] as String,
      seatNumber: json['seatNumber'] as String,
      showTime: DateTime.parse(json['showTime'] as String),
      qrCode: json['qrCode'] as String,
      qrCodeData: json['qrCodeData'] as String,
      isUsed: json['isUsed'] as bool,
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isUsed && !isExpired;
}

class ValidateTicketRequest {
  final String qrCodeData;

  ValidateTicketRequest({required this.qrCodeData});

  Map<String, dynamic> toJson() {
    return {
      'qrCodeData': qrCodeData,
    };
  }
}

class TicketValidationResult {
  final bool success;
  final String message;
  final Ticket? ticket;
  final DateTime? usedAt;
  final DateTime? expiresAt;

  TicketValidationResult({
    required this.success,
    required this.message,
    this.ticket,
    this.usedAt,
    this.expiresAt,
  });

  factory TicketValidationResult.fromJson(Map<String, dynamic> json) {
    return TicketValidationResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      ticket: json['ticket'] != null
          ? Ticket.fromJson(json['ticket'] as Map<String, dynamic>)
          : null,
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}
