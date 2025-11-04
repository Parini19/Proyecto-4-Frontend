class User {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;
  final bool disabled;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.disabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      emailVerified: json['emailVerified'],
      disabled: json['disabled'],
    );
  }
}
