import '../entities/reservation.dart';

/// Repository interface for reservation data operations
abstract class ReservationRepository {
  /// Gets all reservations for a user
  Future<List<Reservation>> getReservationsByUserId(String userId);

  /// Gets a reservation by ID
  Future<Reservation?> getReservationById(String id);

  /// Creates a new reservation
  Future<String> createReservation(Reservation reservation);

  /// Updates a reservation
  Future<void> updateReservation(Reservation reservation);

  /// Cancels a reservation
  Future<void> cancelReservation(String id);

  /// Gets upcoming reservations
  Future<List<Reservation>> getUpcomingReservations(String userId);

  /// Gets past reservations
  Future<List<Reservation>> getPastReservations(String userId);
}
