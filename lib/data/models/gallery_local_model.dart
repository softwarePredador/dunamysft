import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryLocalModel {
  final String id;
  final String image;
  final String video;
  final DocumentReference? localRef;

  GalleryLocalModel({
    required this.id,
    required this.image,
    this.video = '',
    this.localRef,
  });

  factory GalleryLocalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GalleryLocalModel(
      id: doc.id,
      image: data['image'] ?? '',
      video: data['video'] ?? '',
      localRef: data['local'] as DocumentReference?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image': image,
      'video': video,
      'local': localRef,
    };
  }

  bool get hasVideo => video.isNotEmpty;
  bool get hasImage => image.isNotEmpty;
}
