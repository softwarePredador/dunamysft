import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para itens do pedido - salvo na collection order_products
class OrderProductModel {
  final String id;
  final String orderId;
  final String menuItemId;
  final String menuItemName;
  final String menuItemPhoto;
  final int quantity;
  final double price;
  final String? observation;
  final List<String> additionals;
  final DateTime? createdAt;

  OrderProductModel({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    this.menuItemName = '',
    this.menuItemPhoto = '',
    required this.quantity,
    required this.price,
    this.observation,
    this.additionals = const [],
    this.createdAt,
  });

  factory OrderProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderProductModel(
      id: doc.id,
      orderId: (data['order'] as DocumentReference?)?.id ?? '',
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
      'order': FirebaseFirestore.instance.collection('order').doc(orderId),
      'menuItem': FirebaseFirestore.instance.collection('menu').doc(menuItemId),
      'menuItemName': menuItemName,
      'menuItemPhoto': menuItemPhoto,
      'quantity': quantity,
      'price': price,
      'observation': observation,
      'additionals': additionals,
      'created_at': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  double get total => price * quantity;
  double get totalPrice => price * quantity;

  OrderProductModel copyWith({
    String? id,
    String? orderId,
    String? menuItemId,
    String? menuItemName,
    String? menuItemPhoto,
    int? quantity,
    double? price,
    String? observation,
    List<String>? additionals,
    DateTime? createdAt,
  }) {
    return OrderProductModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
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
