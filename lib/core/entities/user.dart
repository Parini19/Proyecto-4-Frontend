class User {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;
  final bool disabled;
  final String? role;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.disabled,
    this.role,
    this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      disabled: json['disabled'] ?? false,
      role: json['role']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.tryParse(json['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'disabled': disabled,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
    bool? disabled,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
      disabled: disabled ?? this.disabled,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  String get roleDisplayName {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'user':
        return 'Usuario';
      case 'employee':
        return 'Empleado';
      default:
        return 'Usuario';
    }
  }

  bool get isAdmin => role?.toLowerCase() == 'admin';
  bool get isEmployee => role?.toLowerCase() == 'employee';
  bool get isActiveUser => !disabled;
}
