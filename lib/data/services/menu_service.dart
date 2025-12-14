import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menu';

  // Get all menu items
  Stream<List<MenuItemModel>> getMenuItems() {
    return _firestore
        .collection(_collection)
        .where('excluded', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromFirestore(doc))
            .toList());
  }

  // Get menu items by category
  Stream<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('categoryRefID',
            isEqualTo: _firestore.collection('category').doc(categoryId))
        .where('excluded', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromFirestore(doc))
            .toList());
  }

  // Get single menu item
  Future<MenuItemModel?> getMenuItem(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return MenuItemModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting menu item: $e');
      return null;
    }
  }

  // Create menu item (admin only)
  Future<String?> createMenuItem(MenuItemModel menuItem) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(menuItem.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating menu item: $e');
      return null;
    }
  }

  // Update menu item (admin only)
  Future<bool> updateMenuItem(String id, MenuItemModel menuItem) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(menuItem.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      return false;
    }
  }

  // Soft delete menu item (admin only)
  Future<bool> deleteMenuItem(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'excluded': true,
      });
      return true;
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      return false;
    }
  }

  // Update stock quantity
  Future<bool> updateQuantity(String id, int quantity) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'quantity': quantity,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      return false;
    }
  }

  // Search menu items by name
  Stream<List<MenuItemModel>> searchMenuItems(String query) {
    return _firestore
        .collection(_collection)
        .where('excluded', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromFirestore(doc))
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }
}
