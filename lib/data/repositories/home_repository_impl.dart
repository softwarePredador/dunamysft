import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/gallery_item.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/category_model.dart';
import '../models/gallery_item_model.dart';
import '../models/menu_item_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseFirestore _firestore;

  HomeRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<GalleryItem>> getGalleryItems() {
    return _firestore.collection('gallery_main').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => GalleryItemModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<Category>> getCategories() {
    return _firestore.collection('category').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .map((model) => Category(
                id: model.id,
                name: model.name,
                excluded: model.excluded,
              ))
          .toList();
    });
  }

  @override
  Stream<List<MenuItem>> getMenuItemsByCategory(String categoryId) {
    // Note: In the reference code, it filters by 'categoryRefID' which is a DocumentReference
    // We need to construct the reference or check how it's stored.
    // Assuming it's stored as a reference.
    final categoryRef = _firestore.collection('category').doc(categoryId);

    return _firestore
        .collection('menu')
        .where('categoryRefID', isEqualTo: categoryRef)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = MenuItemModel.fromFirestore(doc);
        return MenuItem(
          id: model.id,
          name: model.name,
          description: model.description,
          price: model.price,
          photo: model.photo,
          categoryId: model.categoryId,
        );
      }).toList();
    });
  }
}
