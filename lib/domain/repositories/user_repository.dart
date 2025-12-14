import '../models/user_model.dart';

/// Repository interface for user data operations
abstract class UserRepository {
  /// Gets user by ID
  Future<UserModel?> getUserById(String id);

  /// Gets current user
  Future<UserModel?> getCurrentUser();

  /// Updates user profile
  Future<void> updateUser(UserModel user);

  /// Deletes user account
  Future<void> deleteUser(String id);

  /// Creates or updates user
  Future<void> saveUser(UserModel user);
}
