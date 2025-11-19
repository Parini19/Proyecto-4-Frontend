import 'package:flutter/material.dart';

/// Food order model that matches the backend FoodOrder entity
class FoodOrder {
  final String id;
  final String userId;
  final List<String> foodComboIds;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodOrder({
    required this.id,
    required this.userId,
    required this.foodComboIds,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      foodComboIds: List<String>.from(json['foodComboIds'] ?? []),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String).toUtc()
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'foodComboIds': foodComboIds,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  FoodOrder copyWith({
    String? id,
    String? userId,
    List<String>? foodComboIds,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodComboIds: foodComboIds ?? this.foodComboIds,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Status constants
  static const String statusPending = 'pending';
  static const String statusPreparing = 'preparing';
  static const String statusReady = 'ready';
  static const String statusDelivered = 'delivered';
  static const String statusDone = 'done';
  static const String statusCancelled = 'cancelled';

  /// Get status display name
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'preparing':
        return 'Preparando';
      case 'ready':
        return 'Listo';
      case 'delivered':
        return 'Entregado';
      case 'done':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status.isNotEmpty ? status : 'Sin estado';
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Orange
      case 'preparing':
        return const Color(0xFF3B82F6); // Blue
      case 'ready':
        return const Color(0xFF10B981); // Green
      case 'delivered':
        return const Color(0xFF6B7280); // Gray
      case 'done':
        return const Color(0xFF059669); // Dark Green
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}