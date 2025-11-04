/// Seat model for cinema seat selection
class Seat {
  final String id;
  final int row;
  final int number;
  final SeatType type;
  final SeatStatus status;

  const Seat({
    required this.id,
    required this.row,
    required this.number,
    required this.type,
    required this.status,
  });

  Seat copyWith({
    String? id,
    int? row,
    int? number,
    SeatType? type,
    SeatStatus? status,
  }) {
    return Seat(
      id: id ?? this.id,
      row: row ?? this.row,
      number: number ?? this.number,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  String get rowLetter {
    // Convert row number to letter (0 = A, 1 = B, etc.)
    return String.fromCharCode(65 + row);
  }

  String get seatLabel => '$rowLetter$number';

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] as String,
      row: json['row'] as int,
      number: json['number'] as int,
      type: SeatType.values.byName(json['type'] as String),
      status: SeatStatus.values.byName(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row': row,
      'number': number,
      'type': type.name,
      'status': status.name,
    };
  }
}

enum SeatType {
  regular,
  vip,
  wheelchair,
}

enum SeatStatus {
  available,
  selected,
  occupied,
  reserved,
}

/// Extension to get seat type properties
extension SeatTypeExtension on SeatType {
  double get price {
    switch (this) {
      case SeatType.regular:
        return 120.0; // MXN
      case SeatType.vip:
        return 180.0; // MXN
      case SeatType.wheelchair:
        return 120.0; // MXN
    }
  }

  String get displayName {
    switch (this) {
      case SeatType.regular:
        return 'Regular';
      case SeatType.vip:
        return 'VIP';
      case SeatType.wheelchair:
        return 'Accesible';
    }
  }
}
