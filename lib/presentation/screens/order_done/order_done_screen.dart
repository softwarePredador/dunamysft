import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../widgets/navbar_widget.dart';

class OrderDoneScreen extends StatelessWidget {
  final String orderId;

  const OrderDoneScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 120.0),
              child: FutureBuilder(
                future: context.read<OrderProvider>().getOrderById(orderId),
                builder: (context, snapshot) {
                  final order = snapshot.data;
                  
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Title
                      Text(
                        'Pedido confirmado!',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      
                      const SizedBox(height: 8.0),

                      // Order Code
                      if (order != null)
                        Text(
                          'Código: ${order.codigo}',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: AppTheme.secondaryText,
                          ),
                        ),

                      const SizedBox(height: 30.0),

                      // Success Animation/Image
                      Container(
                        width: 270.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Image.asset(
                          'assets/images/order_success.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              size: 100.0,
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      // Total
                      Text(
                        'Total',
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (order != null)
                        Text(
                          'R\$ ${order.total.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 28.0,
                            color: AppTheme.amarelo,
                          ),
                        ),

                      const SizedBox(height: 30.0),

                      // Order Details Card
                      if (order != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detalhes do Pedido',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              _buildDetailRow('Status', _getStatusText(order.status)),
                              _buildDetailRow('Forma de Pagamento', _getPaymentMethodText(order.paymentMethod)),
                              _buildDetailRow('Entrega', order.deliveryType == 'delivery' ? 'Quarto ${order.room}' : 'Retirar no local'),
                              _buildDetailRow('Data', _formatDate(order.createdAt)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30.0),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.push('/orders'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.amarelo,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                side: const BorderSide(color: AppTheme.amarelo),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                'Ver Pedidos',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.go('/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.amarelo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                'Voltar ao Início',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  );
                },
              ),
            ),
          ),

          // Navbar
          const Align(
            alignment: Alignment.bottomCenter,
            child: NavbarWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              color: AppTheme.secondaryText,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'preparing':
        return 'Em Preparo';
      case 'ready':
        return 'Pronto';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'pix':
        return 'PIX';
      case 'credit':
        return 'Cartão de Crédito';
      case 'debit':
        return 'Cartão de Débito';
      case 'cash':
        return 'Dinheiro';
      default:
        return method;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
