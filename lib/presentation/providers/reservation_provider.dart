import 'package:flutter/foundation.dart';
import '../../data/models/reservation_model.dart';
import '../../domain/repositories/reservation_repository.dart';

/// Provider for managing reservation state
class ReservationProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;
  
  List<ReservationModel> _reservations = [];
  ReservationModel? _selectedReservation;
  bool _isLoading = false;
  String? _error;

  ReservationProvider(this._reservationRepository);

  // Getters
  List<ReservationModel> get reservations => _reservations;
  ReservationModel? get selectedReservation => _selectedReservation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<ReservationModel> get upcomingReservations {
    final now = DateTime.now();
    return _reservations
        .where((r) => r.checkIn.isAfter(now))
        .toList()
      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));
  }

  List<ReservationModel> get pastReservations {
    final now = DateTime.now();
    return _reservations
        .where((r) => r.checkOut.isBefore(now))
        .toList()
      ..sort((a, b) => b.checkOut.compareTo(a.checkOut));
  }

  /// Loads all reservations for a user
  Future<void> loadReservations(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _reservations = await _reservationRepository.getReservationsByUserId(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading reservations: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new reservation
  Future<String> createReservation(ReservationModel reservation) async {
    _setLoading(true);
    _error = null;

    try {
      final id = await _reservationRepository.createReservation(reservation);
      await loadReservations(reservation.userId);
      return id;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating reservation: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancels a reservation
  Future<void> cancelReservation(String id, String userId) async {
    _setLoading(true);
    _error = null;

    try {
      await _reservationRepository.cancelReservation(id);
      await loadReservations(userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cancelling reservation: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Selects a reservation for details view
  void selectReservation(ReservationModel? reservation) {
    _selectedReservation = reservation;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
