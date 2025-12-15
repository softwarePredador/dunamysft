import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final DateTime? date;
  final DateTime? createdAt;
  final String status;
  final String room;
  final bool retirar;
  final double total;
  final String payment;
  final String paymentMethod;
  final String deliveryType;
  final int codigo;
  final bool finished;
  final String customerName;
  final String customerCpf;

  OrderModel({
    required this.id,
    required this.userId,
    this.date,
    this.createdAt,
    this.status = 'pending',
    this.room = '',
    this.retirar = false,
    this.total = 0.0,
    this.payment = '',
    this.paymentMethod = '',
    this.deliveryType = 'delivery',
    this.codigo = 0,
    this.finished = false,
    this.customerName = '',
    this.customerCpf = '',
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: (data['user'] as DocumentReference?)?.id ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
      room: (data['room'] ?? '').toString(),
      retirar: data['retirar'] ?? false,
      total: (data['total'] ?? 0.0).toDouble(),
      payment: data['payment'] ?? '',
      paymentMethod: data['paymentMethod'] ?? data['payment'] ?? '',
      deliveryType: data['deliveryType'] ?? (data['retirar'] == true ? 'pickup' : 'delivery'),
      codigo: data['codigo'] ?? 0,
      finished: data['finished'] ?? false,
      customerName: data['customerName'] ?? '',
      customerCpf: data['customerCpf'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': FirebaseFirestore.instance.collection('users').doc(userId),
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'status': status,
      'room': room,
      'retirar': deliveryType == 'pickup',
      'total': total,
      'payment': payment.isNotEmpty ? payment : paymentMethod,
      'paymentMethod': paymentMethod,
      'deliveryType': deliveryType,
      'codigo': codigo,
      'finished': finished,
      'customerName': customerName,
      'customerCpf': customerCpf,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? createdAt,
    String? status,
    String? room,
    bool? retirar,
    double? total,
    String? payment,
    String? paymentMethod,
    String? deliveryType,
    int? codigo,
    bool? finished,
    String? customerName,
    String? customerCpf,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      room: room ?? this.room,
      retirar: retirar ?? this.retirar,
      total: total ?? this.total,
      payment: payment ?? this.payment,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryType: deliveryType ?? this.deliveryType,
      codigo: codigo ?? this.codigo,
      finished: finished ?? this.finished,
      customerName: customerName ?? this.customerName,
      customerCpf: customerCpf ?? this.customerCpf,
    );
  }
}
