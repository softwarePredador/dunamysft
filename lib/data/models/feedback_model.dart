import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String message;
  final int rating;
  final DateTime? createdAt;
  final bool resolved;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.message,
    this.rating = 0,
    this.createdAt,
    this.resolved = false,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      userId: (data['user'] as DocumentReference?)?.id ?? '',
      message: data['message'] ?? '',
      rating: data['rating'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      resolved: data['resolved'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'message': message,
      'rating': rating,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'resolved': resolved,
    };
  }

  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? message,
    int? rating,
    DateTime? createdAt,
    bool? resolved,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      resolved: resolved ?? this.resolved,
    );
  }
}
