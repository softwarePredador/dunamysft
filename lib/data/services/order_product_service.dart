import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_product_model.dart';
import '../models/product_cart_model.dart';

/// Service para gerenciar itens do pedido (order_products)
class OrderProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'order_products';

  /// Salva os itens do carrinho como order_products
  Future<bool> saveOrderProducts({
    required String orderId,
    required List<ProductCartModel> cartItems,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final item in cartItems) {
        final docRef = _firestore.collection(_collection).doc();
        
        final orderProduct = OrderProductModel(
          id: docRef.id,
          orderId: orderId,
          menuItemId: item.menuItemId,
          menuItemName: item.menuItemName,
          menuItemPhoto: item.menuItemPhoto,
          quantity: item.quantity,
          price: item.price,
          observation: item.observation,
          additionals: item.additionals,
          createdAt: DateTime.now(),
        );
        
        batch.set(docRef, orderProduct.toFirestore());
      }

      await batch.commit();
      debugPrint('OrderProducts: ${cartItems.length} itens salvos para pedido $orderId');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar order_products: $e');
      return false;
    }
  }

  /// Busca os itens de um pedido
  Future<List<OrderProductModel>> getOrderProducts(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('order', isEqualTo: _firestore.collection('order').doc(orderId))
          .get();

      return snapshot.docs
          .map((doc) => OrderProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar order_products: $e');
      return [];
    }
  }

  /// Stream de itens de um pedido
  Stream<List<OrderProductModel>> streamOrderProducts(String orderId) {
    return _firestore
        .collection(_collection)
        .where('order', isEqualTo: _firestore.collection('order').doc(orderId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderProductModel.fromFirestore(doc))
            .toList());
  }

  /// Deleta todos os itens de um pedido (se cancelado)
  Future<bool> deleteOrderProducts(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('order', isEqualTo: _firestore.collection('order').doc(orderId))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      debugPrint('OrderProducts: ${snapshot.docs.length} itens deletados do pedido $orderId');
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar order_products: $e');
      return false;
    }
  }
}
