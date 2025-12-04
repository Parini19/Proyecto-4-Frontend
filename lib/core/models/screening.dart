/// Screening model that matches the backend Screening entity
class Screening {
  final String id;
  final String movieId;
  final String cinemaId;
  final String theaterRoomId;
  final DateTime startTime;
  final DateTime endTime;
  final double price;

  const Screening({
    required this.id,
    required this.movieId,
    required this.cinemaId,
    required this.theaterRoomId,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  factory Screening.fromJson(Map<String, dynamic> json) {
    return Screening(
      id: json['id'] as String,
      movieId: json['movieId'] as String,
      cinemaId: json['cinemaId'] as String? ?? '',
      theaterRoomId: json['theaterRoomId'] as String,
      startTime: DateTime.parse(json['startTime'] as String).toUtc(),
      endTime: DateTime.parse(json['endTime'] as String).toUtc(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'cinemaId': cinemaId,
      'theaterRoomId': theaterRoomId,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'price': price,
    };
  }

  Screening copyWith({
    String? id,
    String? movieId,
    String? cinemaId,
    String? theaterRoomId,
    DateTime? startTime,
    DateTime? endTime,
    double? price,
  }) {
    return Screening(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      cinemaId: cinemaId ?? this.cinemaId,
      theaterRoomId: theaterRoomId ?? this.theaterRoomId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
    );
  }

  /// Get duration of the screening in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Get formatted start time (HH:mm)
  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted end time (HH:mm)
  String get formattedEndTime {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted date (dd/MM/yyyy)
  String get formattedDate {
    return '${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}';
  }

  /// Check if screening is in the future
  bool get isFuture => startTime.isAfter(DateTime.now());

  /// Check if screening is currently active
  bool get isActive {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  @override
  String toString() => 'Screening(id: $id, movieId: $movieId, cinemaId: $cinemaId, theaterRoomId: $theaterRoomId, startTime: $startTime, endTime: $endTime, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Screening &&
        other.id == id &&
        other.movieId == movieId &&
        other.cinemaId == cinemaId &&
        other.theaterRoomId == theaterRoomId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        movieId.hashCode ^
        cinemaId.hashCode ^
        theaterRoomId.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        price.hashCode;
  }
}

/// Mock screenings for development
final List<Screening> mockScreenings = [
  Screening(
    id: 'SC1',
    movieId: '1', // Dune: Part Two
    cinemaId: 'CINEMA1',
    theaterRoomId: 'TR1',
    startTime: DateTime.now().add(Duration(hours: 2)),
    endTime: DateTime.now().add(Duration(hours: 4, minutes: 46)), // 166 min
    price: 4500.0,
  ),
  Screening(
    id: 'SC2',
    movieId: '2', // Kung Fu Panda 4
    cinemaId: 'CINEMA1',
    theaterRoomId: 'TR2',
    startTime: DateTime.now().add(Duration(hours: 3)),
    endTime: DateTime.now().add(Duration(hours: 4, minutes: 34)), // 94 min
    price: 4000.0,
  ),
  Screening(
    id: 'SC3',
    movieId: '1', // Dune: Part Two
    cinemaId: 'CINEMA2',
    theaterRoomId: 'TR3',
    startTime: DateTime.now().add(Duration(hours: 5)),
    endTime: DateTime.now().add(Duration(hours: 7, minutes: 46)), // 166 min
    price: 5000.0,
  ),
  Screening(
    id: 'SC4',
    movieId: '3', // Godzilla x Kong
    cinemaId: 'CINEMA2',
    theaterRoomId: 'TR4',
    startTime: DateTime.now().add(Duration(days: 1, hours: 2)),
    endTime: DateTime.now().add(Duration(days: 1, hours: 4, minutes: 27)), // 147 min
    price: 5500.0,
  ),
  Screening(
    id: 'SC5',
    movieId: '2', // Kung Fu Panda 4
    cinemaId: 'CINEMA1',
    theaterRoomId: 'TR1',
    startTime: DateTime.now().add(Duration(days: 1, hours: 4)),
    endTime: DateTime.now().add(Duration(days: 1, hours: 5, minutes: 34)), // 94 min
    price: 3500.0,
  ),
];