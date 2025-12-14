import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

/// Firebase implementation of UserRepository
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data();
      if (data == null) return null;
      
      return UserModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // This should be implemented based on your auth service
    // For now, returning null
    return null;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).update(
            user.toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(
            user.toJson()..remove('id'),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Erro ao salvar usuário: $e');
    }
  }
}
