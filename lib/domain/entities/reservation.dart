/// Domain entity for Reservation (business logic layer)
class Reservation {
  final String id;
  final String userId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final String status;
  final String? specialRequests;

  Reservation({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    this.specialRequests,
  });

  /// Calculates the number of nights
  int get numberOfNights {
    return checkOut.difference(checkIn).inDays;
  }

  /// Checks if reservation is active (currently happening)
  bool isActiveAt(DateTime currentTime) {
    return checkIn.isBefore(currentTime) && checkOut.isAfter(currentTime);
  }

  /// Checks if reservation is active now
  bool get isActive => isActiveAt(DateTime.now());

  /// Checks if reservation is upcoming (hasn't started yet)
  bool isUpcomingAt(DateTime currentTime) {
    return checkIn.isAfter(currentTime);
  }

  /// Checks if reservation is upcoming now
  bool get isUpcoming => isUpcomingAt(DateTime.now());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
