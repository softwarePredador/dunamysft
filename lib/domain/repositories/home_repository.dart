import '../entities/category.dart';
import '../entities/gallery_item.dart';
import '../entities/menu_item.dart';

abstract class HomeRepository {
  Stream<List<GalleryItem>> getGalleryItems();
  Stream<List<Category>> getCategories();
  Stream<List<MenuItem>> getMenuItemsByCategory(String categoryId);
}
