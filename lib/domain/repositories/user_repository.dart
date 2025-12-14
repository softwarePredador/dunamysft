import '../entities/user.dart';

/// Repository interface for user data operations
abstract class UserRepository {
  /// Gets user by ID
  Future<User?> getUserById(String id);

  /// Gets current user
  Future<User?> getCurrentUser();

  /// Updates user profile
  Future<void> updateUser(User user);

  /// Deletes user account
  Future<void> deleteUser(String id);

  /// Creates or updates user
  Future<void> saveUser(User user);
}
