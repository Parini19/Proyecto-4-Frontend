import 'seat.dart';

/// Showtime model representing a movie screening
class Showtime {
  final String id;
  final String movieId;
  final String cinemaHall;
  final String? cinemaName; // Added: Name of the cinema location
  final DateTime dateTime;
  final List<Seat> seats;
  final int totalSeats;
  final int availableSeats;

  const Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaHall,
    this.cinemaName,
    required this.dateTime,
    required this.seats,
    required this.totalSeats,
    required this.availableSeats,
  });

  String get timeFormatted {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dateFormatted {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: json['id'] as String,
      movieId: json['movieId'] as String,
      cinemaHall: json['cinemaHall'] as String,
      cinemaName: json['cinemaName'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String).toUtc(),
      seats: (json['seats'] as List<dynamic>)
          .map((e) => Seat.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalSeats: json['totalSeats'] as int,
      availableSeats: json['availableSeats'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'cinemaHall': cinemaHall,
      'cinemaName': cinemaName,
      'dateTime': dateTime.toUtc().toIso8601String(),
      'seats': seats.map((e) => e.toJson()).toList(),
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
    };
  }

  Showtime copyWith({
    String? id,
    String? movieId,
    String? cinemaHall,
    String? cinemaName,
    DateTime? dateTime,
    List<Seat>? seats,
    int? totalSeats,
    int? availableSeats,
  }) {
    return Showtime(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      cinemaHall: cinemaHall ?? this.cinemaHall,
      cinemaName: cinemaName ?? this.cinemaName,
      dateTime: dateTime ?? this.dateTime,
      seats: seats ?? this.seats,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
    );
  }
}

/// Generate mock seats for a cinema hall
List<Seat> generateMockSeats({
  int rows = 8,
  int seatsPerRow = 12,
  List<String>? occupiedSeats,
}) {
  final seats = <Seat>[];
  final occupied = occupiedSeats ?? [];

  for (int row = 0; row < rows; row++) {
    for (int number = 1; number <= seatsPerRow; number++) {
      final seatId = 'R${row}S$number';
      final isOccupied = occupied.contains(seatId);

      // Middle rows (3-5) are VIP
      final isVIP = row >= 3 && row <= 5 && number >= 3 && number <= 10;

      // Wheelchair accessible seats at the back corners
      final isWheelchair =
          row == rows - 1 && (number == 1 || number == seatsPerRow);

      SeatType type;
      if (isWheelchair) {
        type = SeatType.wheelchair;
      } else if (isVIP) {
        type = SeatType.vip;
      } else {
        type = SeatType.regular;
      }

      seats.add(Seat(
        id: seatId,
        row: row,
        number: number,
        type: type,
        status: isOccupied ? SeatStatus.occupied : SeatStatus.available,
      ));
    }
  }

  return seats;
}

/// Mock showtimes data
List<Showtime> getMockShowtimes(String movieId) {
  final now = DateTime.now();

  return [
    Showtime(
      id: 'ST1',
      movieId: movieId,
      cinemaHall: 'Sala 1',
      dateTime: DateTime(now.year, now.month, now.day, 14, 30),
      seats: generateMockSeats(
        occupiedSeats: ['R1S3', 'R1S4', 'R2S5', 'R3S6', 'R4S7', 'R5S8'],
      ),
      totalSeats: 96,
      availableSeats: 90,
    ),
    Showtime(
      id: 'ST2',
      movieId: movieId,
      cinemaHall: 'Sala 2',
      dateTime: DateTime(now.year, now.month, now.day, 17, 0),
      seats: generateMockSeats(
        occupiedSeats: [
          'R1S5',
          'R1S6',
          'R2S5',
          'R2S6',
          'R3S7',
          'R4S8',
          'R5S3',
          'R5S4'
        ],
      ),
      totalSeats: 96,
      availableSeats: 88,
    ),
    Showtime(
      id: 'ST3',
      movieId: movieId,
      cinemaHall: 'Sala 1',
      dateTime: DateTime(now.year, now.month, now.day, 19, 30),
      seats: generateMockSeats(
        occupiedSeats: [
          'R1S6',
          'R2S6',
          'R3S5',
          'R3S6',
          'R3S7',
          'R4S5',
          'R4S6',
          'R4S7'
        ],
      ),
      totalSeats: 96,
      availableSeats: 88,
    ),
  ];
}
