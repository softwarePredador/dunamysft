import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'order';

  // Get user orders
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection(_collection)
        .where('user', isEqualTo: _firestore.collection('users').doc(userId))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  // Get all orders (admin only)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  // Get orders by status (admin only)
  Stream<List<OrderModel>> getOrdersByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  // Get single order
  Future<OrderModel?> getOrder(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order: $e');
      return null;
    }
  }

  // Create order
  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  // Update order status (admin only)
  Future<bool> updateOrderStatus(String id, String status) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': status,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  // Mark order as finished (admin only)
  Future<bool> markOrderAsFinished(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'finished': true,
      });
      return true;
    } catch (e) {
      debugPrint('Error marking order as finished: $e');
      return false;
    }
  }

  /// Atualiza informações de pagamento do pedido
  /// Usado quando pagamento PIX é confirmado
  Future<bool> updatePaymentInfo({
    required String orderId,
    required String paymentId,
    required String paymentStatus,
  }) async {
    try {
      final updates = <String, dynamic>{
        'paymentId': paymentId,
        'paymentStatus': paymentStatus,
      };
      
      // Se pago, adiciona data de pagamento
      if (paymentStatus == 'paid' || paymentStatus == 'confirmed') {
        updates['paidAt'] = FieldValue.serverTimestamp();
        updates['status'] = 'confirmed'; // Atualiza status do pedido também
      }
      
      await _firestore.collection(_collection).doc(orderId).update(updates);
      debugPrint('Payment info updated for order $orderId: $paymentStatus');
      return true;
    } catch (e) {
      debugPrint('Error updating payment info: $e');
      return false;
    }
  }

  /// Stream para escutar mudanças em um pedido específico (real-time)
  Stream<OrderModel?> streamOrder(String orderId) {
    return _firestore
        .collection(_collection)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
  }

  // Generate order code
  Future<int> generateOrderCode() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('codigo', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 1;
      }

      final lastOrder = OrderModel.fromFirestore(snapshot.docs.first);
      return lastOrder.codigo + 1;
    } catch (e) {
      debugPrint('Error generating order code: $e');
      return DateTime.now().millisecondsSinceEpoch % 10000;
    }
  }
}
