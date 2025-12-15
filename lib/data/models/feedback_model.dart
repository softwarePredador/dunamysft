import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String emotion; // Emoji escolhido (ex: "😃 Gostei")
  final int ranking; // Rating de 0-5
  final String obs; // Observação/comentário
  final DateTime? date;
  final bool resolved;

  FeedbackModel({
    required this.id,
    required this.userId,
    this.emotion = '',
    this.ranking = 0,
    this.obs = '',
    this.date,
    this.resolved = false,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      userId: (data['user'] as DocumentReference?)?.id ?? '',
      emotion: data['emotion'] ?? '',
      ranking: data['ranking'] ?? 0,
      obs: data['obs'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
      resolved: data['resolved'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'emotion': emotion,
      'ranking': ranking,
      'obs': obs,
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
      'resolved': resolved,
    };
  }

  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? emotion,
    int? ranking,
    String? obs,
    DateTime? date,
    bool? resolved,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emotion: emotion ?? this.emotion,
      ranking: ranking ?? this.ranking,
      obs: obs ?? this.obs,
      date: date ?? this.date,
      resolved: resolved ?? this.resolved,
    );
  }
}
