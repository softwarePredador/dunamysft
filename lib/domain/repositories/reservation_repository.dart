import '../models/reservation_model.dart';

/// Repository interface for reservation data operations
abstract class ReservationRepository {
  /// Gets all reservations for a user
  Future<List<ReservationModel>> getReservationsByUserId(String userId);

  /// Gets a reservation by ID
  Future<ReservationModel?> getReservationById(String id);

  /// Creates a new reservation
  Future<String> createReservation(ReservationModel reservation);

  /// Updates a reservation
  Future<void> updateReservation(ReservationModel reservation);

  /// Cancels a reservation
  Future<void> cancelReservation(String id);

  /// Gets upcoming reservations
  Future<List<ReservationModel>> getUpcomingReservations(String userId);

  /// Gets past reservations
  Future<List<ReservationModel>> getPastReservations(String userId);
}
