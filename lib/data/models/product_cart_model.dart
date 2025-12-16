import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCartModel {
  final String id;
  final String userId;
  final String menuItemId;
  final String menuItemName;
  final String menuItemPhoto;
  final int quantity;
  final double price;
  final double additionalPrice; // Preço total dos adicionais
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
    this.additionalPrice = 0.0,
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
      additionalPrice: (data['additionalPrice'] ?? data['productAditional'] ?? 0.0).toDouble(),
      observation: data['observation'] ?? data['obs'],
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
      'additionalPrice': additionalPrice,
      'productAditional': price + additionalPrice, // Compatível com FlutterFlow
      'total': (price + additionalPrice) * quantity, // Total final
      'observation': observation,
      'obs': observation, // Compatível com FlutterFlow
      'additionals': additionals,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Preço unitário com adicionais
  double get unitPriceWithAdditionals => price + additionalPrice;
  
  /// Total do item (preço unitário com adicionais * quantidade)
  double get total => unitPriceWithAdditionals * quantity;
  double get totalPrice => unitPriceWithAdditionals * quantity;

  ProductCartModel copyWith({
    String? id,
    String? userId,
    String? menuItemId,
    String? menuItemName,
    String? menuItemPhoto,
    int? quantity,
    double? price,
    double? additionalPrice,
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
      additionalPrice: additionalPrice ?? this.additionalPrice,
      observation: observation ?? this.observation,
      additionals: additionals ?? this.additionals,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
