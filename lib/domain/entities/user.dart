/// Domain entity for User (business logic layer)
/// This is a pure domain entity without dependencies on data layer
class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.phone,
    required this.createdAt,
  });

  /// Gets the display name (name or email if name is null)
  String get displayName => name ?? email;

  /// Checks if the user has a complete profile
  bool get hasCompleteProfile {
    return name != null && phone != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
