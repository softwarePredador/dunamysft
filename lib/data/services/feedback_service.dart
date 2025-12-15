import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _collection = 'Feedback';

  /// Envia um novo feedback
  Future<bool> submitFeedback(FeedbackModel feedback) async {
    try {
      await _firestore.collection(_collection).add(feedback.toFirestore());
      return true;
    } catch (e) {
      print('Erro ao enviar feedback: $e');
      return false;
    }
  }

  /// Lista todos os feedbacks (para admin)
  Stream<List<FeedbackModel>> getAllFeedbacks() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  /// Lista feedbacks de um usuário específico
  Future<List<FeedbackModel>> getUserFeedbacks(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final snapshot = await _firestore
          .collection(_collection)
          .where('user', isEqualTo: userRef)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => FeedbackModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar feedbacks do usuário: $e');
      return [];
    }
  }

  /// Marca um feedback como resolvido (admin)
  Future<bool> markAsResolved(String feedbackId) async {
    try {
      await _firestore.collection(_collection).doc(feedbackId).update({
        'resolved': true,
      });
      return true;
    } catch (e) {
      print('Erro ao marcar feedback como resolvido: $e');
      return false;
    }
  }

  /// Deleta um feedback (admin)
  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection(_collection).doc(feedbackId).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar feedback: $e');
      return false;
    }
  }
}
