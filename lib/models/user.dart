enum UserRole {
  user,
  admin,
  moderator,
}

extension UserRoleExtension on UserRole {
  String get label => switch (this) {
        UserRole.user => 'User',
        UserRole.admin => 'Admin',
        UserRole.moderator => 'Moderator',
      };
}

enum UserStatus {
  active,
  banned,
  pending,
}

extension UserStatusExtension on UserStatus {
  String get label => switch (this) {
        UserStatus.active => 'Active',
        UserStatus.banned => 'Banned',
        UserStatus.pending => 'Pending',
      };
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.role = UserRole.user,
    this.status = UserStatus.active,
    this.isPremium = false,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final UserRole role;
  final UserStatus status;
  final bool isPremium;
  final DateTime? createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String?)?.toLowerCase() ?? 'user';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.user,
    );
    final isPremium = json['isPremium'] as bool? ??
        roleStr == 'premium';

    // Backend uses 'enabled' boolean; map to UserStatus
    UserStatus status;
    if (json.containsKey('enabled')) {
      status = (json['enabled'] as bool? ?? true)
          ? UserStatus.active
          : UserStatus.banned;
    } else {
      status = UserStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?)?.toLowerCase(),
        orElse: () => UserStatus.active,
      );
    }

    return User(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] ?? json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      role: role,
      status: status,
      isPremium: isPremium,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'role': role.name,
        'status': status.name,
        'isPremium': isPremium,
        'createdAt': createdAt?.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    UserRole? role,
    UserStatus? status,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
