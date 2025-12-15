import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String photo;
  final String categoryId;
  final int quantity;
  final bool excluded;
  final bool onSale;
  final double salePrice;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.photo,
    required this.categoryId,
    this.quantity = 100,
    this.excluded = false,
    this.onSale = false,
    this.salePrice = 0.0,
  });

  bool get isAvailable => !excluded && quantity > 0;
  
  double get effectivePrice => onSale ? salePrice : price;

  @override
  List<Object?> get props => [id, name, description, price, photo, categoryId, quantity, excluded, onSale, salePrice];
}
