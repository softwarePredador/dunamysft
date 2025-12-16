import 'package:flutter_test/flutter_test.dart';
import 'package:dunamys/data/models/product_cart_model.dart';

void main() {
  group('ProductCartModel Tests', () {
    test('should create ProductCartModel from constructor', () {
      final cartItem = ProductCartModel(
        id: '123',
        userId: 'user_456',
        menuItemId: 'prod_789',
        menuItemName: 'Test Product',
        menuItemPhoto: 'https://example.com/image.jpg',
        price: 29.90,
        quantity: 2,
        observation: 'Extra cheese',
        additionals: ['Add1', 'Add2'],
        additionalPrice: 5.0,
      );

      expect(cartItem.id, '123');
      expect(cartItem.userId, 'user_456');
      expect(cartItem.menuItemId, 'prod_789');
      expect(cartItem.menuItemName, 'Test Product');
      expect(cartItem.price, 29.90);
      expect(cartItem.quantity, 2);
      expect(cartItem.observation, 'Extra cheese');
      expect(cartItem.additionals.length, 2);
      expect(cartItem.additionalPrice, 5.0);
    });

    test('should calculate total price correctly', () {
      final cartItem = ProductCartModel(
        id: '123',
        userId: 'user_456',
        menuItemId: 'prod_789',
        price: 10.0,
        quantity: 3,
        additionalPrice: 2.0,
      );

      // (10.0 + 2.0) * 3 = 36.0
      expect(cartItem.total, 36.0);
      expect(cartItem.totalPrice, 36.0);
    });

    test('should calculate total price without additionals', () {
      final cartItem = ProductCartModel(
        id: '123',
        userId: 'user_456',
        menuItemId: 'prod_789',
        price: 10.0,
        quantity: 2,
      );

      // 10.0 * 2 = 20.0
      expect(cartItem.total, 20.0);
    });

    test('should calculate unit price with additionals', () {
      final cartItem = ProductCartModel(
        id: '123',
        userId: 'user_456',
        menuItemId: 'prod_789',
        price: 10.0,
        quantity: 2,
        additionalPrice: 3.0,
      );

      expect(cartItem.unitPriceWithAdditionals, 13.0);
    });

    test('copyWith should create new instance with updated values', () {
      final original = ProductCartModel(
        id: '123',
        userId: 'user_456',
        menuItemId: 'prod_789',
        menuItemName: 'Test Product',
        price: 10.0,
        quantity: 1,
      );

      final updated = original.copyWith(
        quantity: 5,
        observation: 'Updated obs',
      );

      expect(updated.id, '123');
      expect(updated.quantity, 5);
      expect(updated.observation, 'Updated obs');
      expect(original.quantity, 1); // Original unchanged
    });

    test('should have correct default values', () {
      final cartItem = ProductCartModel(
        id: '123',
        userId: 'user_456',
        menuItemId: 'prod_789',
        price: 10.0,
        quantity: 1,
      );

      expect(cartItem.menuItemName, '');
      expect(cartItem.menuItemPhoto, '');
      expect(cartItem.additionalPrice, 0.0);
      expect(cartItem.observation, isNull);
      expect(cartItem.additionals, isEmpty);
    });
  });
}
