/// Domain entity for Room (business logic layer)
class Room {
  final String id;
  final String name;
  final String description;
  final String type;
  final int capacity;
  final double pricePerNight;
  final List<String> amenities;
  final List<String> imageUrls;
  final bool isAvailable;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.capacity,
    required this.pricePerNight,
    required this.amenities,
    required this.imageUrls,
    required this.isAvailable,
  });

  /// Calculates total price for a stay
  double calculateTotalPrice(int numberOfNights) {
    return pricePerNight * numberOfNights;
  }

  /// Checks if room can accommodate the number of guests
  bool canAccommodate(int guests) {
    return guests <= capacity;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
