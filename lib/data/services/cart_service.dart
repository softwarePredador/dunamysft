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
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductCartModel.fromFirestore(doc))
            .toList());
  }

  // Add item to cart
  Future<String?> addToCart(ProductCartModel cartItem) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(cartItem.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return null;
    }
  }

  // Update cart item quantity
  Future<bool> updateCartItemQuantity(String id, int quantity) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'quantity': quantity,
      });
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
      final snapshot = await _firestore
          .collection(_collection)
          .where('user', isEqualTo: _firestore.collection('users').doc(userId))
          .get();

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
      final snapshot = await _firestore
          .collection(_collection)
          .where('user', isEqualTo: _firestore.collection('users').doc(userId))
          .get();

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
