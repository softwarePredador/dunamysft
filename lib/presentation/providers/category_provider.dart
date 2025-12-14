import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Load all categories
  void loadCategories() {
    _isLoading = true;
    notifyListeners();

    _categoryService.getCategories().listen(
      (categories) {
        _categories = categories;
        _isLoading = false;
        _error = '';
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Get category by id
  Future<CategoryModel?> getCategory(String id) async {
    return await _categoryService.getCategory(id);
  }

  // Create category (admin only)
  Future<bool> createCategory(String name) async {
    final category = CategoryModel(
      id: '',
      name: name,
    );

    final id = await _categoryService.createCategory(category);
    return id != null;
  }

  // Update category (admin only)
  Future<bool> updateCategory(String id, String name) async {
    final category = CategoryModel(
      id: id,
      name: name,
    );

    return await _categoryService.updateCategory(id, category);
  }

  // Delete category (admin only)
  Future<bool> deleteCategory(String id) async {
    return await _categoryService.deleteCategory(id);
  }
}
