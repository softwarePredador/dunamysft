import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String photo;
  final String categoryId;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.photo,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [id, name, description, price, photo, categoryId];
}
