import 'package:flutter/material.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _menuService = MenuService();
  
  List<MenuItemModel> _menuItems = [];
  List<MenuItemModel> _filteredMenuItems = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedCategoryId = '';

  List<MenuItemModel> get menuItems => _filteredMenuItems.isNotEmpty 
      ? _filteredMenuItems 
      : _menuItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategoryId => _selectedCategoryId;

  // Load all menu items
  void loadMenuItems() {
    _isLoading = true;
    notifyListeners();

    _menuService.getMenuItems().listen(
      (items) {
        _menuItems = items;
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

  // Filter by category
  void filterByCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    
    if (categoryId.isEmpty) {
      _filteredMenuItems = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _menuService.getMenuItemsByCategory(categoryId).listen(
      (items) {
        _filteredMenuItems = items;
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

  // Search menu items
  void searchMenuItems(String query) {
    if (query.isEmpty) {
      _filteredMenuItems = [];
      notifyListeners();
      return;
    }

    _menuService.searchMenuItems(query).listen(
      (items) {
        _filteredMenuItems = items;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Clear filters
  void clearFilters() {
    _selectedCategoryId = '';
    _filteredMenuItems = [];
    notifyListeners();
  }

  // Get menu item by id
  Future<MenuItemModel?> getMenuItem(String id) async {
    return await _menuService.getMenuItem(id);
  }
}
