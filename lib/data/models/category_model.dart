import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final bool excluded;

  CategoryModel({
    required this.id,
    required this.name,
    this.excluded = false,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      excluded: data['excluded'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'excluded': excluded,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    bool? excluded,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      excluded: excluded ?? this.excluded,
    );
  }
}
