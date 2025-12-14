/// Reservation model for hotel bookings
class ReservationModel {
  final String id;
  final String userId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final ReservationStatus status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    this.specialRequests,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a ReservationModel from JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      roomId: json['roomId'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      guests: json['guests'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: ReservationStatus.fromString(json['status'] as String),
      specialRequests: json['specialRequests'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts ReservationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roomId': roomId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guests': guests,
      'totalPrice': totalPrice,
      'status': status.value,
      'specialRequests': specialRequests,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields
  ReservationModel copyWith({
    String? id,
    String? userId,
    String? roomId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? totalPrice,
    ReservationStatus? status,
    String? specialRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculates the number of nights
  int get numberOfNights {
    return checkOut.difference(checkIn).inDays;
  }

  @override
  String toString() {
    return 'ReservationModel(id: $id, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Reservation status enum
enum ReservationStatus {
  pending('pending'),
  confirmed('confirmed'),
  checkedIn('checked_in'),
  checkedOut('checked_out'),
  cancelled('cancelled');

  final String value;
  const ReservationStatus(this.value);

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReservationStatus.pending,
    );
  }
}
