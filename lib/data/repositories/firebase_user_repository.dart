import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

/// Firebase implementation of UserRepository
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final String _collection = 'users';

  @override
  Future<User?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data();
      if (data == null) return null;
      
      final model = UserModel.fromJson({...data, 'id': doc.id});
      return _modelToEntity(model);
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      // Try to get user from Firestore first
      final firestoreUser = await getUserById(firebaseUser.uid);
      if (firestoreUser != null) return firestoreUser;

      // If not in Firestore, create from Firebase Auth data
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        phone: firebaseUser.phoneNumber,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao buscar usuário atual: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      final model = _entityToModel(user);
      await _firestore.collection(_collection).doc(user.id).update(
            model.toJson()..remove('id'),
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
  Future<void> saveUser(User user) async {
    try {
      final model = _entityToModel(user);
      await _firestore.collection(_collection).doc(user.id).set(
            model.toJson()..remove('id'),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Erro ao salvar usuário: $e');
    }
  }

  // Convert model to entity
  User _modelToEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      photoUrl: model.photoUrl,
      phone: model.phone,
      createdAt: model.createdAt,
    );
  }

  // Convert entity to model
  UserModel _entityToModel(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      createdAt: entity.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
