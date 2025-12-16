import 'package:flutter_test/flutter_test.dart';
import 'package:dunamys/data/models/order_model.dart';

void main() {
  group('OrderModel Tests', () {
    test('should create OrderModel from constructor', () {
      final order = OrderModel(
        id: '123',
        userId: 'user_456',
        room: '101',
        status: 'pending',
        total: 59.80,
        paymentMethod: 'credit_card',
        paymentId: 'pay_789',
        date: DateTime(2025, 12, 16, 14, 30),
      );

      expect(order.id, '123');
      expect(order.userId, 'user_456');
      expect(order.room, '101');
      expect(order.status, 'pending');
      expect(order.total, 59.80);
      expect(order.paymentMethod, 'credit_card');
      expect(order.paymentId, 'pay_789');
    });

    test('should have correct status values', () {
      final pendingOrder = OrderModel(
        id: '1',
        userId: 'user_456',
        status: 'Pendente',
      );

      final confirmedOrder = OrderModel(
        id: '2',
        userId: 'user_456',
        status: 'Confirmado',
      );

      final deliveredOrder = OrderModel(
        id: '3',
        userId: 'user_456',
        status: 'Entregue',
      );

      final cancelledOrder = OrderModel(
        id: '4',
        userId: 'user_456',
        status: 'Cancelado',
      );

      expect(pendingOrder.status, 'Pendente');
      expect(confirmedOrder.status, 'Confirmado');
      expect(deliveredOrder.status, 'Entregue');
      expect(cancelledOrder.status, 'Cancelado');
    });

    test('should have correct default values', () {
      final order = OrderModel(
        id: '123',
        userId: 'user_456',
      );

      expect(order.status, 'pending');
      expect(order.room, '');
      expect(order.total, 0.0);
      expect(order.retirar, false);
      expect(order.finished, false);
      expect(order.deliveryType, 'delivery');
    });

    test('copyWith should create new instance with updated values', () {
      final original = OrderModel(
        id: '123',
        userId: 'user_456',
        room: '101',
        status: 'pending',
        total: 59.80,
      );

      final updated = original.copyWith(
        status: 'Confirmado',
        paymentId: 'pay_999',
      );

      expect(updated.id, '123');
      expect(updated.status, 'Confirmado');
      expect(updated.paymentId, 'pay_999');
      expect(original.status, 'pending'); // Original unchanged
    });

    test('should handle Cielo payment fields', () {
      final order = OrderModel(
        id: '123',
        userId: 'user_456',
        paymentId: 'cielo_pay_123',
        paymentStatus: 'AUTHORIZED',
        paidAt: DateTime(2025, 6, 15, 10, 30),
      );

      expect(order.paymentId, 'cielo_pay_123');
      expect(order.paymentStatus, 'AUTHORIZED');
      expect(order.paidAt, DateTime(2025, 6, 15, 10, 30));
    });

    test('should have customer fields', () {
      final order = OrderModel(
        id: '123',
        userId: 'user_456',
        customerName: 'John Doe',
        customerCpf: '12345678901',
      );

      expect(order.customerName, 'John Doe');
      expect(order.customerCpf, '12345678901');
    });
  });
}
