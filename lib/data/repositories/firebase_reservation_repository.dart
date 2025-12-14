import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../models/reservation_model.dart';

/// Firebase implementation of ReservationRepository
class FirebaseReservationRepository implements ReservationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reservations';

  @override
  Future<List<ReservationModel>> getReservationsByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReservationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas: $e');
    }
  }

  @override
  Future<ReservationModel?> getReservationById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data();
      if (data == null) return null;
      
      return ReservationModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Erro ao buscar reserva: $e');
    }
  }

  @override
  Future<String> createReservation(ReservationModel reservation) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            reservation.toJson()..remove('id'),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  @override
  Future<void> updateReservation(ReservationModel reservation) async {
    try {
      await _firestore.collection(_collection).doc(reservation.id).update(
            reservation.toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Erro ao atualizar reserva: $e');
    }
  }

  @override
  Future<void> cancelReservation(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': ReservationStatus.cancelled.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao cancelar reserva: $e');
    }
  }

  @override
  Future<List<ReservationModel>> getUpcomingReservations(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('checkIn', isGreaterThanOrEqualTo: now.toIso8601String())
          .orderBy('checkIn', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ReservationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas futuras: $e');
    }
  }

  @override
  Future<List<ReservationModel>> getPastReservations(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('checkOut', isLessThan: now.toIso8601String())
          .orderBy('checkOut', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReservationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas passadas: $e');
    }
  }
}
