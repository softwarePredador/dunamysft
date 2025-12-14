import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faq_model.dart';

class FAQService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'faq';

  // Get all FAQs
  Stream<List<FAQModel>> getFAQs() {
    return _firestore
        .collection(_collection)
        .where('excluded', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FAQModel.fromFirestore(doc))
            .toList());
  }

  // Get single FAQ
  Future<FAQModel?> getFAQ(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return FAQModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting FAQ: $e');
      return null;
    }
  }

  // Create FAQ (admin only)
  Future<String?> createFAQ(FAQModel faq) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(faq.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating FAQ: $e');
      return null;
    }
  }

  // Update FAQ (admin only)
  Future<bool> updateFAQ(String id, FAQModel faq) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(faq.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error updating FAQ: $e');
      return false;
    }
  }

  // Soft delete FAQ (admin only)
  Future<bool> deleteFAQ(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'excluded': true,
      });
      return true;
    } catch (e) {
      debugPrint('Error deleting FAQ: $e');
      return false;
    }
  }
}
