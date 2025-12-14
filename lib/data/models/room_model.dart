/// Room model for hotel rooms
class RoomModel {
  final String id;
  final String name;
  final String description;
  final RoomType type;
  final int capacity;
  final double pricePerNight;
  final List<String> amenities;
  final List<String> imageUrls;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.capacity,
    required this.pricePerNight,
    required this.amenities,
    required this.imageUrls,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a RoomModel from JSON
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: RoomType.fromString(json['type'] as String),
      capacity: json['capacity'] as int,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List),
      imageUrls: List<String>.from(json['imageUrls'] as List),
      isAvailable: json['isAvailable'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts RoomModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.value,
      'capacity': capacity,
      'pricePerNight': pricePerNight,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields
  RoomModel copyWith({
    String? id,
    String? name,
    String? description,
    RoomType? type,
    int? capacity,
    double? pricePerNight,
    List<String>? amenities,
    List<String>? imageUrls,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoomModel(id: $id, name: $name, type: ${type.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Room type enum
enum RoomType {
  single('single'),
  double('double'),
  suite('suite'),
  deluxe('deluxe'),
  presidential('presidential');

  final String value;
  const RoomType(this.value);

  static RoomType fromString(String value) {
    return RoomType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RoomType.single,
    );
  }

  String get displayName {
    switch (this) {
      case RoomType.single:
        return 'Quarto Single';
      case RoomType.double:
        return 'Quarto Duplo';
      case RoomType.suite:
        return 'Suíte';
      case RoomType.deluxe:
        return 'Suíte Deluxe';
      case RoomType.presidential:
        return 'Suíte Presidencial';
    }
  }
}
