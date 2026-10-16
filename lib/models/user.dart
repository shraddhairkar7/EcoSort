/// App user. Role is chosen on the login screen (and stored on the user
/// record so the shell can show the right tabs).
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// Gamified points for correct sorting + useful issue reports.
  final int segregationScore;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.segregationScore,
  });

  AppUser copyWith({int? segregationScore, UserRole? role, String? name}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      segregationScore: segregationScore ?? this.segregationScore,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'segregationScore': segregationScore,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.byName(map['role'] as String),
      segregationScore: map['segregationScore'] as int? ?? 0,
    );
  }
}

enum UserRole { citizen, collector, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.collector:
        return 'Collector';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
