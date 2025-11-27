class TheaterRoomModel {
  final String id;
  final String? cinemaId;
  final String name;
  final int capacity;
  final dynamic seatConfiguration;

  TheaterRoomModel({
    required this.id,
    this.cinemaId,
    required this.name,
    required this.capacity,
    this.seatConfiguration,
  });

  factory TheaterRoomModel.fromJson(Map<String, dynamic> json) {
    return TheaterRoomModel(
      id: json['id']?.toString() ?? '',
      cinemaId: json['cinemaId']?.toString(),
      name: json['name']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      seatConfiguration: json['seatConfiguration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (cinemaId != null) 'cinemaId': cinemaId,
      'name': name,
      'capacity': capacity,
      if (seatConfiguration != null) 'seatConfiguration': seatConfiguration,
    };
  }
}