import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_cart_model.dart';
import '../../data/services/order_service.dart';
import '../../data/services/order_product_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final OrderProductService _orderProductService = OrderProductService();
  
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

  // Create order with detailed parameters
  Future<String?> createOrder({
    required String userId,
    required List<ProductCartModel> items,
    required double total,
    required String paymentMethod,
    required String deliveryType,
    String room = '',
    String customerName = '',
    String customerCpf = '',
  }) async {
    final codigo = await _orderService.generateOrderCode();
    
    final order = OrderModel(
      id: '',
      userId: userId,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      status: 'pending',
      room: room,
      retirar: deliveryType == 'pickup',
      total: total,
      paymentMethod: paymentMethod,
      deliveryType: deliveryType,
      codigo: codigo,
      finished: false,
      customerName: customerName,
      customerCpf: customerCpf,
    );
    
    final orderId = await _orderService.createOrder(order);
    
    // Salvar itens do pedido na collection order_products
    if (orderId != null && items.isNotEmpty) {
      await _orderProductService.saveOrderProducts(
        orderId: orderId,
        cartItems: items,
      );
    }
    
    return orderId;
  }

  // Create order with model
  Future<String?> createOrderModel(OrderModel order) async {
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

  // Get order by id (alias for compatibility)
  Future<OrderModel?> getOrderById(String id) async {
    return await _orderService.getOrder(id);
  }
}
