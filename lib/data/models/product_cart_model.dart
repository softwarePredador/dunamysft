import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCartModel {
  final String id;
  final String userId;
  final String menuItemId;
  final int quantity;
  final double price;
  final String? observation;
  final DateTime? createdAt;

  ProductCartModel({
    required this.id,
    required this.userId,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    this.observation,
    this.createdAt,
  });

  factory ProductCartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductCartModel(
      id: doc.id,
      userId: (data['user'] as DocumentReference?)?.id ?? '',
      menuItemId: (data['menuItem'] as DocumentReference?)?.id ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0.0).toDouble(),
      observation: data['observation'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'menuItem': FirebaseFirestore.instance.collection('menu').doc(menuItemId),
      'quantity': quantity,
      'price': price,
      'observation': observation,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  double get totalPrice => price * quantity;

  ProductCartModel copyWith({
    String? id,
    String? userId,
    String? menuItemId,
    int? quantity,
    double? price,
    String? observation,
    DateTime? createdAt,
  }) {
    return ProductCartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      observation: observation ?? this.observation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
