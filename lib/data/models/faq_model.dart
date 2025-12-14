import 'package:cloud_firestore/cloud_firestore.dart';

class FAQModel {
  final String id;
  final String question;
  final String answer;
  final bool excluded;

  FAQModel({
    required this.id,
    required this.question,
    required this.answer,
    this.excluded = false,
  });

  factory FAQModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FAQModel(
      id: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      excluded: data['excluded'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'answer': answer,
      'excluded': excluded,
    };
  }

  FAQModel copyWith({
    String? id,
    String? question,
    String? answer,
    bool? excluded,
  }) {
    return FAQModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      excluded: excluded ?? this.excluded,
    );
  }
}
