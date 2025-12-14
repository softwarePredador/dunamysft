import '../models/room_model.dart';

/// Repository interface for room data operations
abstract class RoomRepository {
  /// Gets all available rooms
  Future<List<RoomModel>> getAvailableRooms();

  /// Gets a room by ID
  Future<RoomModel?> getRoomById(String id);

  /// Gets rooms by type
  Future<List<RoomModel>> getRoomsByType(RoomType type);

  /// Searches rooms by criteria
  Future<List<RoomModel>> searchRooms({
    DateTime? checkIn,
    DateTime? checkOut,
    int? minCapacity,
    double? maxPrice,
  });

  /// Gets featured rooms
  Future<List<RoomModel>> getFeaturedRooms();
}
