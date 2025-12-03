class ClaimTicket {
  final String id;
  final String userId;
  final String userEmail;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? closedAt;

  const ClaimTicket({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.closedAt,
  });

  factory ClaimTicket.fromJson(Map<String, dynamic> json) {
    return ClaimTicket(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Open',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
    };
  }

  ClaimTicket copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return ClaimTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  // Helper getters for status display
  bool get isOpen => status == 'Open';
  bool get isInProgress => status == 'InProgress';
  bool get isClosed => status == 'Closed';

  String get statusDisplayName {
    switch (status) {
      case 'Open':
        return 'Abierto';
      case 'InProgress':
        return 'En Progreso';
      case 'Closed':
        return 'Cerrado';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'ClaimTicket(id: $id, userId: $userId, userEmail: $userEmail, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClaimTicket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}