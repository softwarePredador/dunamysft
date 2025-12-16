import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_cart_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'product_cart_user';

  // Get user cart items
  Stream<List<ProductCartModel>> getCartItems(String userId) {
    return _firestore
        .collection(_collection)
        .where('user', isEqualTo: _firestore.collection('users').doc(userId))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductCartModel.fromFirestore(doc)).toList());
  }

  // Add item to cart (with aggregation if same product + same additionals)
  Future<String?> addToCart(ProductCartModel cartItem) async {
    try {
      // Check if there's already an item with same product and same additionals
      final existingItem = await findExistingCartItem(
        userId: cartItem.userId,
        menuItemId: cartItem.menuItemId,
        additionals: cartItem.additionals,
        observation: cartItem.observation,
      );

      if (existingItem != null) {
        // Aggregate: update quantity of existing item
        final newQuantity = existingItem.quantity + cartItem.quantity;
        await updateCartItemQuantity(existingItem.id, newQuantity);
        return existingItem.id;
      } else {
        // Create new cart item
        final docRef = await _firestore.collection(_collection).add(cartItem.toFirestore());
        return docRef.id;
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return null;
    }
  }

  // Find existing cart item with same product and additionals
  Future<ProductCartModel?> findExistingCartItem({
    required String userId,
    required String menuItemId,
    required List<String> additionals,
    String? observation,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user', isEqualTo: _firestore.collection('users').doc(userId))
          .where('menuItem', isEqualTo: _firestore.collection('menu').doc(menuItemId))
          .get();

      for (var doc in snapshot.docs) {
        final item = ProductCartModel.fromFirestore(doc);

        // Check if additionals are the same (order-independent comparison)
        final itemAdditionals = List<String>.from(item.additionals)..sort();
        final newAdditionals = List<String>.from(additionals)..sort();

        // Check if observation is the same
        final sameObservation = (item.observation ?? '') == (observation ?? '');

        if (_listEquals(itemAdditionals, newAdditionals) && sameObservation) {
          return item;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error finding existing cart item: $e');
      return null;
    }
  }

  // Helper to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Update cart item quantity
  Future<bool> updateCartItemQuantity(String id, int quantity) async {
    try {
      await _firestore.collection(_collection).doc(id).update({'quantity': quantity});
      return true;
    } catch (e) {
      debugPrint('Error updating cart item quantity: $e');
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart(String userId) async {
    try {
      final snapshot = await _firestore.collection(_collection).where('user', isEqualTo: _firestore.collection('users').doc(userId)).get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      return false;
    }
  }

  // Get cart total
  Future<double> getCartTotal(String userId) async {
    try {
      final snapshot = await _firestore.collection(_collection).where('user', isEqualTo: _firestore.collection('users').doc(userId)).get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final cartItem = ProductCartModel.fromFirestore(doc);
        total += cartItem.totalPrice;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting cart total: $e');
      return 0;
    }
  }
}
