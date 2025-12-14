import '../entities/room.dart';

/// Repository interface for room data operations
abstract class RoomRepository {
  /// Gets all available rooms
  Future<List<Room>> getAvailableRooms();

  /// Gets a room by ID
  Future<Room?> getRoomById(String id);

  /// Gets rooms by type
  Future<List<Room>> getRoomsByType(String type);

  /// Searches rooms by criteria
  Future<List<Room>> searchRooms({
    DateTime? checkIn,
    DateTime? checkOut,
    int? minCapacity,
    double? maxPrice,
  });

  /// Gets featured rooms
  Future<List<Room>> getFeaturedRooms();
}
