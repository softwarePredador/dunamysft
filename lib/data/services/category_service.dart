import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'category';

  // Get all categories
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection(_collection)
        .where('excluded', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // Get single category
  Future<CategoryModel?> getCategory(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting category: $e');
      return null;
    }
  }

  // Create category (admin only)
  Future<String?> createCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating category: $e');
      return null;
    }
  }

  // Update category (admin only)
  Future<bool> updateCategory(String id, CategoryModel category) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(category.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  // Soft delete category (admin only)
  Future<bool> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'excluded': true,
      });
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }
}
