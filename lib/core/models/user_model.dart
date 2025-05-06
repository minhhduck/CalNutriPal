/// User model representing an authenticated user
class User {
  /// Unique user ID
  final String id;

  /// User's email address
  final String email;

  /// User's display name
  final String displayName;

  /// Whether user's email is verified
  final bool isEmailVerified;

  /// URL to user's profile photo (optional)
  final String? photoUrl;

  /// When the user account was created
  final DateTime createdAt;

  /// Creates a new [User] with the given properties
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isEmailVerified,
    this.photoUrl,
    required this.createdAt,
  });

  /// Creates a [User] from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts this [User] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [User] with the given properties replaced
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isEmailVerified,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
