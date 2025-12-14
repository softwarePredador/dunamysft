import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _error = '';

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Load user orders
  void loadUserOrders(String userId) {
    _isLoading = true;
    notifyListeners();

    _orderService.getUserOrders(userId).listen(
      (orders) {
        _orders = orders;
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

  // Load all orders (admin only)
  void loadAllOrders() {
    _isLoading = true;
    notifyListeners();

    _orderService.getAllOrders().listen(
      (orders) {
        _orders = orders;
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

  // Create order
  Future<String?> createOrder(OrderModel order) async {
    return await _orderService.createOrder(order);
  }

  // Update order status (admin only)
  Future<bool> updateOrderStatus(String id, String status) async {
    return await _orderService.updateOrderStatus(id, status);
  }

  // Mark order as finished (admin only)
  Future<bool> markOrderAsFinished(String id) async {
    return await _orderService.markOrderAsFinished(id);
  }

  // Generate order code
  Future<int> generateOrderCode() async {
    return await _orderService.generateOrderCode();
  }

  // Get order by id
  Future<OrderModel?> getOrder(String id) async {
    return await _orderService.getOrder(id);
  }
}
