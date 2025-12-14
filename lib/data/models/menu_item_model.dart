import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final String specifications;
  final double price;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final bool onSale;
  final double salePrice;
  final int quantity;
  final String categoryId;
  final String photo;
  final bool excluded;

  MenuItemModel({
    required this.id,
    required this.name,
    this.description = '',
    this.specifications = '',
    required this.price,
    this.createdAt,
    this.modifiedAt,
    this.onSale = false,
    this.salePrice = 0.0,
    this.quantity = 0,
    required this.categoryId,
    this.photo = '',
    this.excluded = false,
  });

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      specifications: data['specifications'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      modifiedAt: (data['modified_at'] as Timestamp?)?.toDate(),
      onSale: data['on_sale'] ?? false,
      salePrice: (data['sale_price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      categoryId: (data['categoryRefID'] as DocumentReference?)?.id ?? '',
      photo: data['photo'] ?? '',
      excluded: data['excluded'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'specifications': specifications,
      'price': price,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'modified_at': modifiedAt != null ? Timestamp.fromDate(modifiedAt!) : null,
      'on_sale': onSale,
      'sale_price': salePrice,
      'quantity': quantity,
      'categoryRefID': FirebaseFirestore.instance.collection('category').doc(categoryId),
      'photo': photo,
      'excluded': excluded,
    };
  }

  double get effectivePrice => onSale ? salePrice : price;

  bool get isAvailable => !excluded && quantity > 0;

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? specifications,
    double? price,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? onSale,
    double? salePrice,
    int? quantity,
    String? categoryId,
    String? photo,
    bool? excluded,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      onSale: onSale ?? this.onSale,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      photo: photo ?? this.photo,
      excluded: excluded ?? this.excluded,
    );
  }
}
