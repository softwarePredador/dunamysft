# Dunamys - Hotel Management App

A Flutter application built with Clean Architecture principles, migrated from FlutterFlow to a professional, maintainable codebase.

## 🏗️ Architecture

This project follows **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability.

### Project Structure

```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants/          # Application constants
│   │   ├── api_constants.dart    # API and Firebase config
│   │   ├── assets.dart           # Asset paths
│   │   └── strings.dart          # UI strings
│   ├── theme/              # App theming
│   │   └── app_theme.dart        # Theme configuration
│   └── utils/              # Utility functions
│       ├── formatters.dart       # Data formatters
│       ├── helpers.dart          # Helper functions
│       └── validators.dart       # Form validators
├── data/                   # Data layer
│   ├── models/             # Data models with JSON serialization
│   │   ├── reservation_model.dart
│   │   ├── room_model.dart
│   │   └── user_model.dart
│   ├── repositories/       # Repository implementations
│   │   ├── firebase_reservation_repository.dart
│   │   └── firebase_user_repository.dart
│   └── services/           # External service integrations
│       └── auth_service.dart
├── domain/                 # Domain layer (business logic)
│   ├── entities/           # Domain entities
│   │   └── user.dart
│   └── repositories/       # Repository interfaces
│       ├── reservation_repository.dart
│       ├── room_repository.dart
│       └── user_repository.dart
├── presentation/           # Presentation layer
│   ├── providers/          # State management (Provider)
│   │   ├── reservation_provider.dart
│   │   ├── theme_provider.dart
│   │   └── user_provider.dart
│   ├── screens/            # App screens
│   │   ├── login/
│   │   │   └── login_screen.dart
│   │   └── splash/
│   │       └── splash_screen.dart
│   └── widgets/            # Reusable UI components
│       ├── common_widgets.dart
│       ├── custom_button.dart
│       └── custom_text_field.dart
└── main.dart               # App entry point
```

## 📦 Features

- ✅ Clean Architecture implementation
- ✅ Firebase Authentication (Google & Apple Sign-In)
- ✅ State management with Provider
- ✅ Navigation with GoRouter
- ✅ Custom theme with Google Fonts
- ✅ Null Safety
- ✅ Form validation
- ✅ Reusable widgets
- ✅ Repository pattern
- ✅ Model serialization (fromJson/toJson)

## 🛠️ Tech Stack

- **Framework:** Flutter 3.10+
- **State Management:** Provider
- **Navigation:** GoRouter
- **Backend:** Firebase (Auth, Firestore)
- **UI:** Material 3, Google Fonts
- **Architecture:** Clean Architecture

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK (3.10.1 or higher)
- Firebase project configured

### Installation

1. Clone the repository
```bash
git clone https://github.com/rafaelhalder/dunamysft.git
cd dunamysft
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Update Firebase configuration in `lib/main.dart` if needed

4. Run the app
```bash
flutter run
```

## 🏛️ Architecture Principles

### Core Layer
Contains application-wide utilities, constants, and configurations that are used across all layers.

### Data Layer
Implements data sources and repositories. Handles data persistence, API calls, and data transformations.

### Domain Layer
Contains business logic, entities, and repository interfaces. Independent of frameworks and external dependencies.

### Presentation Layer
Handles UI logic, state management, and user interactions. Depends on the domain layer but not on the data layer directly.

## 📝 Code Guidelines

1. **Null Safety:** All code must be null-safe
2. **Naming Conventions:** 
   - Classes: PascalCase
   - Files: snake_case
   - Variables: camelCase
3. **State Management:** Use Provider for state management
4. **Repository Pattern:** All data access through repositories
5. **Separation of Concerns:** Each layer has a single responsibility

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is private and proprietary.

## 👥 Team

Developed by Rafael Halder and team.

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Provider Documentation](https://pub.dev/packages/provider)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
