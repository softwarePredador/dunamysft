import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/gallery_item.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository _repository;

  HomeProvider(this._repository);

  Stream<List<GalleryItem>> get galleryItemsStream => _repository.getGalleryItems();
  Stream<List<Category>> get categoriesStream => _repository.getCategories();

  Stream<List<MenuItem>> getMenuItemsStream(String categoryId) {
    return _repository.getMenuItemsByCategory(categoryId);
  }
}
