import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCartModel {
  final String id;
  final String userId;
  final String menuItemId;
  final String menuItemName;
  final String menuItemPhoto;
  final int quantity;
  final double price;
  final String? observation;
  final List<String> additionals;
  final DateTime? createdAt;

  ProductCartModel({
    required this.id,
    required this.userId,
    required this.menuItemId,
    this.menuItemName = '',
    this.menuItemPhoto = '',
    required this.quantity,
    required this.price,
    this.observation,
    this.additionals = const [],
    this.createdAt,
  });

  factory ProductCartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductCartModel(
      id: doc.id,
      userId: (data['user'] as DocumentReference?)?.id ?? '',
      menuItemId: (data['menuItem'] as DocumentReference?)?.id ?? '',
      menuItemName: data['menuItemName'] ?? '',
      menuItemPhoto: data['menuItemPhoto'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0.0).toDouble(),
      observation: data['observation'],
      additionals: List<String>.from(data['additionals'] ?? []),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'menuItem': FirebaseFirestore.instance.collection('menu').doc(menuItemId),
      'menuItemName': menuItemName,
      'menuItemPhoto': menuItemPhoto,
      'quantity': quantity,
      'price': price,
      'observation': observation,
      'additionals': additionals,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  double get total => price * quantity;
  double get totalPrice => price * quantity;

  ProductCartModel copyWith({
    String? id,
    String? userId,
    String? menuItemId,
    String? menuItemName,
    String? menuItemPhoto,
    int? quantity,
    double? price,
    String? observation,
    List<String>? additionals,
    DateTime? createdAt,
  }) {
    return ProductCartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      menuItemPhoto: menuItemPhoto ?? this.menuItemPhoto,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      observation: observation ?? this.observation,
      additionals: additionals ?? this.additionals,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
