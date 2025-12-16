import 'package:cloud_firestore/cloud_firestore.dart';

class LocalDunamysModel {
  final String id;
  final String name;

  LocalDunamysModel({
    required this.id,
    required this.name,
  });

  factory LocalDunamysModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LocalDunamysModel(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }

  DocumentReference get reference => 
      FirebaseFirestore.instance.collection('localDunamys').doc(id);
}
