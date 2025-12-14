import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Provider for managing user state
class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProvider(this._userRepository);

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// Loads the current user
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _error = null;

    try {
      _currentUser = await _userRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the user profile
  Future<void> updateProfile(User user) async {
    _setLoading(true);
    _error = null;

    try {
      await _userRepository.updateUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Sets the current user
  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Clears the current user (logout)
  void clearUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
