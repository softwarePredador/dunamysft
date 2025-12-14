import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final DateTime? date;
  final String status;
  final int room;
  final bool retirar;
  final double total;
  final String payment;
  final int codigo;
  final bool finished;

  OrderModel({
    required this.id,
    required this.userId,
    this.date,
    this.status = '',
    this.room = 0,
    this.retirar = false,
    this.total = 0.0,
    this.payment = '',
    this.codigo = 0,
    this.finished = false,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: (data['user'] as DocumentReference?)?.id ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
      status: data['status'] ?? '',
      room: data['room'] ?? 0,
      retirar: data['retirar'] ?? false,
      total: (data['total'] ?? 0.0).toDouble(),
      payment: data['payment'] ?? '',
      codigo: data['codigo'] ?? 0,
      finished: data['finished'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
      'status': status,
      'room': room,
      'retirar': retirar,
      'total': total,
      'payment': payment,
      'codigo': codigo,
      'finished': finished,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? status,
    int? room,
    bool? retirar,
    double? total,
    String? payment,
    int? codigo,
    bool? finished,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      status: status ?? this.status,
      room: room ?? this.room,
      retirar: retirar ?? this.retirar,
      total: total ?? this.total,
      payment: payment ?? this.payment,
      codigo: codigo ?? this.codigo,
      finished: finished ?? this.finished,
    );
  }
}
