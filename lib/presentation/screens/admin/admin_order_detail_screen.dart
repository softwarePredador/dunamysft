import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  String? _selectedStatus;
  bool _isUpdating = false;

  final List<String> _statusOptions = [
    'pendente',
    'em preparo',
    'pronto',
    'entregue',
    'cancelado',
  ];

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('order')
          .doc(widget.orderId)
          .update({
        'status': newStatus,
        'finished': newStatus == 'entregue' || newStatus == 'cancelado',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para: $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_circle_left_sharp,
            color: AppTheme.primaryText,
            size: 35,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/orders');
            }
          },
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('order')
              .doc(widget.orderId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text('Erro ao carregar pedido'),
              );
            }

            final orderData = snapshot.data!.data() as Map<String, dynamic>;
            final room = orderData['room']?.toString() ?? 'N/A';
            final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;
            final status = orderData['status'] ?? 'pendente';
            final customerName = orderData['customer_name'] ?? 'Cliente';
            final paymentMethod = orderData['payment_method'] ?? 'N/A';
            final deliveryType = orderData['delivery_type'] ?? 'N/A';
            final createdAt = orderData['created_at'] as Timestamp?;
            final items = orderData['items'] as List<dynamic>? ?? [];

            _selectedStatus ??= status;

            final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
            final dateStr = createdAt != null
                ? dateFormat.format(createdAt.toDate())
                : 'Data não disponível';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes do Pedido',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Order Info Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryText),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quarto $room',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Hóspede',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    customerName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            dateStr,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                          const Divider(height: 30),

                          // Items List
                          Text(
                            'Itens do Pedido',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...items.map((item) {
                            final itemMap = item as Map<String, dynamic>;
                            final quantity = itemMap['quantity'] ?? 1;
                            final name = itemMap['name'] ?? 'Item';
                            final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
                            final additionals = itemMap['additionals'] as List<dynamic>? ?? [];
                            final observation = itemMap['observation'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$quantity x $name',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryText,
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${(price * quantity).toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppTheme.primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (additionals.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Adicionais: ${additionals.join(', ')}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.secondaryText,
                                      ),
                                    ),
                                  ],
                                  if (observation.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Obs: $observation',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 30),

                          // Payment Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Forma de Pagamento:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              Text(
                                paymentMethod.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tipo de Entrega:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              Text(
                                deliveryType,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              Text(
                                'R\$ ${total.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.amarelo,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Status Update Section
                    Text(
                      'Atualizar Status',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryText),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                status.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStatus = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isUpdating
                            ? null
                            : () {
                                if (_selectedStatus != null) {
                                  _updateStatus(_selectedStatus!);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.amarelo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isUpdating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Atualizar Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
