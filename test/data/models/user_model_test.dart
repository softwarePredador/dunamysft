import 'package:flutter_test/flutter_test.dart';
import 'package:dunamys/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel from constructor', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        phone: '11999998888',
        createdAt: DateTime(2025, 12, 16),
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.phone, '11999998888');
      expect(user.createdAt, DateTime(2025, 12, 16));
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2025, 12, 16),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
    });

    test('should create UserModel from JSON', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
        'photoUrl': null,
        'phone': '11999998888',
        'createdAt': '2025-12-16T00:00:00.000',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.phone, '11999998888');
    });

    test('should create copy with copyWith', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2025, 12, 16),
      );

      final updatedUser = user.copyWith(
        name: 'New Name',
      );

      expect(updatedUser.id, '123');
      expect(updatedUser.email, 'test@example.com');
      expect(updatedUser.name, 'New Name');
    });

    test('should check equality by id', () {
      final user1 = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2025, 12, 16),
      );

      final user2 = UserModel(
        id: '123',
        email: 'other@example.com',
        name: 'Other Name',
        createdAt: DateTime(2025, 12, 17),
      );

      final user3 = UserModel(
        id: '456',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2025, 12, 16),
      );

      expect(user1, user2); // Same id
      expect(user1, isNot(user3)); // Different id
    });

    test('should convert to string correctly', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2025, 12, 16),
      );

      expect(user.toString(), contains('123'));
      expect(user.toString(), contains('test@example.com'));
    });
  });
}
