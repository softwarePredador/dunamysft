import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/auth_service.dart';
import '../../providers/order_provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Load user orders
    Future.microtask(() {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;
      if (user != null) {
        context.read<OrderProvider>().loadUserOrders(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meus Pedidos'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, size: 64, color: AppTheme.grayPaletteGray60),
              const SizedBox(height: 16),
              const Text('Faça login para ver seus pedidos'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Fazer Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryBackground,
        elevation: 0,
        title: const Text('Meus Pedidos'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar pedidos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderProvider.error,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final orders = orderProvider.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.grayPaletteGray60),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum pedido encontrado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Faça seu primeiro pedido',
                    style: TextStyle(color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/menu'),
                    child: const Text('Ver Cardápio'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to order details
          // context.push('/orders/${order.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt, color: AppTheme.primaryColors),
                      const SizedBox(width: 8),
                      Text(
                        'Pedido #${order.codigo}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const Divider(height: 24),
              // Details
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Data',
                value: order.date != null ? dateFormat.format(order.date!) : 'N/A',
              ),
              const SizedBox(height: 8),
              if (order.room.isNotEmpty)
                _buildInfoRow(
                  context,
                  icon: Icons.hotel,
                  label: 'Quarto',
                  value: order.room,
                ),
              if (order.room.isNotEmpty) const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: order.retirar ? Icons.store : Icons.delivery_dining,
                label: 'Entrega',
                value: order.retirar ? 'Retirar no local' : 'Entregar no quarto',
              ),
              const SizedBox(height: 8),
              if (order.payment.isNotEmpty)
                _buildInfoRow(
                  context,
                  icon: Icons.payment,
                  label: 'Pagamento',
                  value: order.payment,
                ),
              if (order.payment.isNotEmpty) const SizedBox(height: 8),
              // Total
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'R\$ ${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColors,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.secondaryText),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryText,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pendente':
        backgroundColor = AppTheme.warning.withOpacity(0.2);
        textColor = AppTheme.warning;
        displayText = 'Pendente';
        break;
      case 'em preparo':
      case 'preparing':
        backgroundColor = AppTheme.primary.withOpacity(0.2);
        textColor = AppTheme.primary;
        displayText = 'Em Preparo';
        break;
      case 'pronto':
      case 'ready':
        backgroundColor = AppTheme.success.withOpacity(0.2);
        textColor = AppTheme.success;
        displayText = 'Pronto';
        break;
      case 'entregue':
      case 'delivered':
        backgroundColor = AppTheme.success.withOpacity(0.2);
        textColor = AppTheme.success;
        displayText = 'Entregue';
        break;
      case 'cancelado':
      case 'cancelled':
        backgroundColor = AppTheme.error.withOpacity(0.2);
        textColor = AppTheme.error;
        displayText = 'Cancelado';
        break;
      default:
        backgroundColor = AppTheme.grayPaletteGray20;
        textColor = AppTheme.secondaryText;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
