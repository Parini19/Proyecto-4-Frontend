import 'package:flutter/material.dart';

/// Theater room model that matches the backend TheaterRoom entity
class TheaterRoom {
  final String id;
  final String cinemaId; // ID del cine al que pertenece
  final String name;
  final int capacity;
  final String? description;
  final String? seatConfigurationJson; // JSON con layout de asientos
  final String type;
  final bool isActive;
  final List<String> features;
  final Map<String, int> seatConfiguration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TheaterRoom({
    required this.id,
    required this.cinemaId,
    required this.name,
    required this.capacity,
    this.description,
    this.seatConfigurationJson,
    this.type = 'standard',
    this.isActive = true,
    this.features = const [],
    this.seatConfiguration = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory TheaterRoom.fromJson(Map<String, dynamic> json) {
    return TheaterRoom(
      id: json['id']?.toString() ?? '',
      cinemaId: json['cinemaId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      capacity: json['capacity'] as int? ?? 0,
      description: json['description']?.toString(),
      seatConfigurationJson: json['seatConfigurationJson']?.toString(),
      type: json['type']?.toString() ?? 'standard',
      isActive: json['isActive'] as bool? ?? true,
      features: json['features'] != null ? List<String>.from(json['features']) : [],
      seatConfiguration: json['seatConfiguration'] != null
          ? Map<String, int>.from(json['seatConfiguration'])
          : {},
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'])?.toUtc() : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'])?.toUtc() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cinemaId': cinemaId,
      'name': name,
      'capacity': capacity,
      'description': description,
      'seatConfigurationJson': seatConfigurationJson,
      'type': type,
      'isActive': isActive,
      'features': features,
      'seatConfiguration': seatConfiguration,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  TheaterRoom copyWith({
    String? id,
    String? cinemaId,
    String? name,
    int? capacity,
    String? description,
    String? seatConfigurationJson,
    String? type,
    bool? isActive,
    List<String>? features,
    Map<String, int>? seatConfiguration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TheaterRoom(
      id: id ?? this.id,
      cinemaId: cinemaId ?? this.cinemaId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      seatConfigurationJson: seatConfigurationJson ?? this.seatConfigurationJson,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      features: features ?? this.features,
      seatConfiguration: seatConfiguration ?? this.seatConfiguration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'premium':
        return 'Premium';
      case 'vip':
        return 'VIP';
      case 'imax':
        return 'IMAX';
      case '4dx':
        return '4DX';
      case 'standard':
      default:
        return 'Estándar';
    }
  }

  String get statusText => isActive ? 'Activa' : 'Inactiva';
  Color get statusColor => isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  
  String get featuresText => features.isEmpty ? 'Sin características' : features.join(', ');
  
  String get capacityText {
    if (capacity <= 50) return 'Pequeña ($capacity asientos)';
    if (capacity <= 150) return 'Mediana ($capacity asientos)';
    return 'Grande ($capacity asientos)';
  }

  @override
  String toString() => 'TheaterRoom(id: $id, name: $name, capacity: $capacity, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheaterRoom &&
        other.id == id &&
        other.name == name &&
        other.capacity == capacity &&
        other.type == type &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, name, capacity, type, isActive);
}

/// Mock theater rooms for development
final List<TheaterRoom> mockTheaterRooms = [
  TheaterRoom(
    id: 'TR1',
    cinemaId: 'CINEMA1', // Cine Premium San José
    name: 'Sala 1 - Premium',
    capacity: 120,
    description: 'Sala premium con asientos reclinables y sonido Dolby Atmos',
    type: 'premium',
    features: ['Asientos reclinables', 'Dolby Atmos', 'Proyección 4K'],
    seatConfiguration: {'rows': 10, 'seatsPerRow': 12},
    createdAt: DateTime.now().toUtc().subtract(Duration(days: 30)),
  ),
  TheaterRoom(
    id: 'TR2',
    cinemaId: 'CINEMA1', // Cine Premium San José
    name: 'Sala 2 - Estándar',
    capacity: 180,
    description: 'Sala estándar con excelente calidad de audio y video',
    type: 'standard',
    features: ['Sonido digital', 'Proyección HD'],
    seatConfiguration: {'rows': 15, 'seatsPerRow': 12},
    createdAt: DateTime.now().toUtc().subtract(Duration(days: 25)),
  ),
  TheaterRoom(
    id: 'TR3',
    cinemaId: 'CINEMA2', // Cine Mall Escazú
    name: 'Sala 3 - VIP',
    capacity: 80,
    description: 'Experiencia VIP con servicio de mesero y asientos de lujo',
    type: 'vip',
    features: ['Servicio de mesero', 'Asientos de cuero', 'Mesas individuales'],
    seatConfiguration: {'rows': 8, 'seatsPerRow': 10},
    createdAt: DateTime.now().toUtc().subtract(Duration(days: 20)),
  ),
  TheaterRoom(
    id: 'TR4',
    cinemaId: 'CINEMA2', // Cine Mall Escazú
    name: 'Sala 4 - IMAX',
    capacity: 200,
    description: 'Pantalla IMAX gigante para una experiencia inmersiva',
    type: 'imax',
    features: ['Pantalla IMAX', 'Sonido envolvente', 'Proyección laser'],
    seatConfiguration: {'rows': 16, 'seatsPerRow': 12, 'special': 8},
    createdAt: DateTime.now().toUtc().subtract(Duration(days: 15)),
  ),
  TheaterRoom(
    id: 'TR5',
    cinemaId: 'CINEMA1', // Cine Premium San José
    name: 'Sala 5 - 4DX',
    capacity: 100,
    description: 'Asientos móviles y efectos ambientales sincronizados',
    type: '4dx',
    features: ['Asientos móviles', 'Efectos de viento', 'Efectos de agua', 'Aromas'],
    seatConfiguration: {'rows': 10, 'seatsPerRow': 10},
    createdAt: DateTime.now().toUtc().subtract(Duration(days: 10)),
  ),
];