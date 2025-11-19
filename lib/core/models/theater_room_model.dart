class TheaterRoomModel {
  final String id;
  final String name;
  final int capacity;

  TheaterRoomModel({
    required this.id,
    required this.name,
    required this.capacity,
  });

  factory TheaterRoomModel.fromJson(Map<String, dynamic> json) {
    return TheaterRoomModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
    };
  }
}