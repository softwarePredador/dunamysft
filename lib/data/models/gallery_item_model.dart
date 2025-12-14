import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/gallery_item.dart';

class GalleryItemModel extends GalleryItem {
  const GalleryItemModel({
    required super.id,
    required super.image,
    super.video,
  });

  factory GalleryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryItemModel(
      id: doc.id,
      image: data['image'] ?? '',
      video: data['video'],
    );
  }
}
