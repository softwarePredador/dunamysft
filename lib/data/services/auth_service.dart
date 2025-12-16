import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'push_notification_service.dart';

abstract class AuthService {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  /// Cria ou atualiza o documento do usuário no Firestore após login
  Future<void> _maybeCreateUser(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Criar novo documento do usuário
        await userRef.set({
          'uid': user.uid,
          'email': user.email ?? user.providerData.firstOrNull?.email ?? '',
          'display_name': user.displayName ?? '',
          'photo_url': user.photoURL ?? '',
          'phone_number': user.phoneNumber ?? '',
          'created_time': FieldValue.serverTimestamp(),
        });
        debugPrint('Novo usuário criado no Firestore: ${user.uid}');
      } else {
        // Atualizar dados se necessário (ex: foto atualizada)
        final data = userDoc.data() as Map<String, dynamic>;
        final updates = <String, dynamic>{};
        
        if (user.displayName != null && user.displayName != data['display_name']) {
          updates['display_name'] = user.displayName;
        }
        if (user.photoURL != null && user.photoURL != data['photo_url']) {
          updates['photo_url'] = user.photoURL;
        }
        if (user.email != null && user.email != data['email']) {
          updates['email'] = user.email;
        }
        
        if (updates.isNotEmpty) {
          await userRef.update(updates);
          debugPrint('Usuário atualizado no Firestore: ${user.uid}');
        }
      }
    } catch (e) {
      debugPrint('Erro ao criar/atualizar usuário no Firestore: $e');
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Criar/atualizar usuário no Firestore
      if (userCredential.user != null) {
        await _maybeCreateUser(userCredential.user!);
        // Salvar token FCM para push notifications
        await PushNotificationService().saveTokenToUser(userCredential.user!.uid);
      }
      
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  @override
  Future<User?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Criar/atualizar usuário no Firestore
      // Para Apple, precisamos tratar o nome manualmente pois só vem na primeira vez
      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        // Se tiver nome do Apple credential, atualizar o perfil do Firebase
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          final fullName = [appleCredential.givenName, appleCredential.familyName]
              .where((n) => n != null && n.isNotEmpty)
              .join(' ');
          if (fullName.isNotEmpty) {
            await user.updateDisplayName(fullName);
            await user.reload();
          }
        }
        
        await _maybeCreateUser(_auth.currentUser ?? user);
        // Salvar token FCM para push notifications
        await PushNotificationService().saveTokenToUser(user.uid);
      }
      
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    // Remover token FCM antes de fazer logout
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await PushNotificationService().removeTokenFromUser(userId);
    }
    
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
