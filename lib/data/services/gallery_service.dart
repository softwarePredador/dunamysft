import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/local_dunamys_model.dart';
import '../models/gallery_local_model.dart';

class GalleryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca todos os locais do hotel (Piscina, Restaurante, etc)
  Stream<List<LocalDunamysModel>> getLocals() {
    return _firestore
        .collection('localDunamys')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LocalDunamysModel.fromFirestore(doc))
            .toList());
  }

  /// Busca todas as imagens/vídeos da galeria
  Stream<List<GalleryLocalModel>> getAllGalleryItems() {
    return _firestore
        .collection('gallerylocal')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryLocalModel.fromFirestore(doc))
            .toList());
  }

  /// Busca imagens/vídeos de um local específico
  Stream<List<GalleryLocalModel>> getGalleryByLocal(DocumentReference localRef) {
    return _firestore
        .collection('gallerylocal')
        .where('local', isEqualTo: localRef)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryLocalModel.fromFirestore(doc))
            .toList());
  }

  /// Busca um local por ID
  Future<LocalDunamysModel?> getLocalById(String id) async {
    try {
      final doc = await _firestore.collection('localDunamys').doc(id).get();
      if (doc.exists) {
        return LocalDunamysModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local: $e');
      return null;
    }
  }
}
