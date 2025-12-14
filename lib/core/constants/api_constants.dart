/// API configuration constants
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.dunamys.com';
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String usersEndpoint = '/users';
  static const String reservationsEndpoint = '/reservations';
  static const String roomsEndpoint = '/rooms';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String reservationsCollection = 'reservations';
  static const String roomsCollection = 'rooms';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

/// Firebase configuration constants
/// NOTE: In production, these should be loaded from environment variables
/// or a secure configuration file that is NOT committed to version control.
/// Add firebase_config.dart to .gitignore and use a template file instead.
class FirebaseConstants {
  // Web configuration
  // TODO: Move to environment variables or secure config file
  static const String webApiKey = 'AIzaSyD1pui2pXaHAwKZx4g8EgcrajUk5J69AI8';
  static const String webAuthDomain = 'hotel-dunamys-ay9x21.firebaseapp.com';
  static const String webProjectId = 'hotel-dunamys-ay9x21';
  static const String webStorageBucket = 'hotel-dunamys-ay9x21.firebasestorage.app';
  static const String webMessagingSenderId = '1005245374810';
  static const String webAppId = '1:1005245374810:web:e42a38a63589445da99363';
}
