import 'package:flutter_test/flutter_test.dart';
import 'package:dunamys/data/models/menu_item_model.dart';

void main() {
  group('MenuItemModel Tests', () {
    test('should create MenuItemModel from constructor', () {
      final product = MenuItemModel(
        id: '123',
        name: 'Test Product',
        description: 'A test product description',
        price: 29.90,
        photo: 'https://example.com/image.jpg',
        categoryId: 'cat_456',
        onSale: true,
        salePrice: 19.90,
        quantity: 10,
      );

      expect(product.id, '123');
      expect(product.name, 'Test Product');
      expect(product.description, 'A test product description');
      expect(product.price, 29.90);
      expect(product.photo, 'https://example.com/image.jpg');
      expect(product.categoryId, 'cat_456');
      expect(product.onSale, true);
      expect(product.salePrice, 19.90);
      expect(product.quantity, 10);
    });

    test('should have default values', () {
      final product = MenuItemModel(
        id: '123',
        name: 'Test Product',
        price: 29.90,
        categoryId: 'cat_456',
      );

      expect(product.description, '');
      expect(product.specifications, '');
      expect(product.photo, '');
      expect(product.onSale, false);
      expect(product.salePrice, 0.0);
      expect(product.quantity, 0);
      expect(product.excluded, false);
    });

    test('should have quantity property', () {
      final productWithStock = MenuItemModel(
        id: '123',
        name: 'Test Product',
        price: 29.90,
        categoryId: 'cat_456',
        quantity: 5,
      );

      final productNoStock = MenuItemModel(
        id: '124',
        name: 'Test Product 2',
        price: 29.90,
        categoryId: 'cat_456',
        quantity: 0,
      );

      expect(productWithStock.quantity, 5);
      expect(productNoStock.quantity, 0);
    });

    test('should have onSale and salePrice properties', () {
      final productOnSale = MenuItemModel(
        id: '123',
        name: 'Test Product',
        price: 29.90,
        salePrice: 19.90,
        categoryId: 'cat_456',
        onSale: true,
      );

      final productNotOnSale = MenuItemModel(
        id: '124',
        name: 'Test Product',
        price: 29.90,
        salePrice: 19.90,
        categoryId: 'cat_456',
        onSale: false,
      );

      expect(productOnSale.onSale, true);
      expect(productOnSale.salePrice, 19.90);
      expect(productNotOnSale.onSale, false);
    });

    test('should have excluded property', () {
      final excludedProduct = MenuItemModel(
        id: '123',
        name: 'Test Product',
        price: 29.90,
        categoryId: 'cat_456',
        excluded: true,
      );

      final availableProduct = MenuItemModel(
        id: '124',
        name: 'Test Product',
        price: 29.90,
        categoryId: 'cat_456',
        excluded: false,
      );

      expect(excludedProduct.excluded, true);
      expect(availableProduct.excluded, false);
    });
  });
}
