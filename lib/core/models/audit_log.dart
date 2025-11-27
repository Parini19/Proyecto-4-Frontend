class AuditLog {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String userId;
  final String userEmail;
  final String description;
  final DateTime timestamp;
  final String ipAddress;
  final String details;
  final String severity;

  AuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.userId,
    required this.userEmail,
    required this.description,
    required this.timestamp,
    required this.ipAddress,
    required this.details,
    required this.severity,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      ipAddress: json['ipAddress'] as String? ?? '',
      details: json['details'] as String? ?? '',
      severity: json['severity'] as String? ?? 'Info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'userId': userId,
      'userEmail': userEmail,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'details': details,
      'severity': severity,
    };
  }
}

class CreateAuditLogRequest {
  final String action;
  final String entityType;
  final String entityId;
  final String userId;
  final String userEmail;
  final String description;
  final String details;
  final String severity;

  CreateAuditLogRequest({
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.userId,
    required this.userEmail,
    required this.description,
    this.details = '',
    this.severity = 'Info',
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'userId': userId,
      'userEmail': userEmail,
      'description': description,
      'details': details,
      'severity': severity,
    };
  }
}
