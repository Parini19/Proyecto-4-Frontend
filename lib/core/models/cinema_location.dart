/// Modelo que representa un cine/sede física
/// Ejemplo: "Cine Premium San José", "Cine Mall Escazú"
class CinemaLocation {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CinemaLocation({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    this.imageUrl,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crea una instancia desde JSON (respuesta del backend)
  factory CinemaLocation.fromJson(Map<String, dynamic> json) {
    return CinemaLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia con valores modificados
  CinemaLocation copyWith({
    String? id,
    String? name,
    String? city,
    String? address,
    String? phone,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CinemaLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Estadísticas de un cine
class CinemaStats {
  final String cinemaId;
  final int totalRooms;
  final int screeningsToday;

  CinemaStats({
    required this.cinemaId,
    required this.totalRooms,
    required this.screeningsToday,
  });

  factory CinemaStats.fromJson(Map<String, dynamic> json) {
    return CinemaStats(
      cinemaId: json['cinemaId'] ?? '',
      totalRooms: json['totalRooms'] ?? 0,
      screeningsToday: json['screeningsToday'] ?? 0,
    );
  }
}
