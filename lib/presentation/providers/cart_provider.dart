import 'package:flutter/material.dart';
import '../../data/models/product_cart_model.dart';
import '../../data/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  
  List<ProductCartModel> _cartItems = [];
  bool _isLoading = false;
  String _error = '';
  double _total = 0;

  List<ProductCartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  double get total => _total;
  int get itemCount => _cartItems.length;

  // Load cart items
  void loadCartItems(String userId) {
    _isLoading = true;
    notifyListeners();

    _cartService.getCartItems(userId).listen(
      (items) {
        _cartItems = items;
        _calculateTotal();
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

  // Calculate total
  void _calculateTotal() {
    _total = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Add to cart
  Future<bool> addToCart(ProductCartModel cartItem) async {
    final id = await _cartService.addToCart(cartItem);
    return id != null;
  }

  // Update quantity
  Future<bool> updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      return await removeFromCart(id);
    }
    return await _cartService.updateCartItemQuantity(id, quantity);
  }

  // Remove from cart
  Future<bool> removeFromCart(String id) async {
    return await _cartService.removeFromCart(id);
  }

  // Clear cart
  Future<bool> clearCart(String userId) async {
    return await _cartService.clearCart(userId);
  }
}
