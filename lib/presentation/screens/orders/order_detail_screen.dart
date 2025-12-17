import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/order_product_model.dart';
import '../../../data/services/order_product_service.dart';
import '../../providers/order_provider.dart';
import '../../widgets/navbar_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  Timer? _timer;
  String _timerDisplay = '00:00';
  OrderModel? _order;
  List<OrderProductModel> _products = [];
  final OrderProductService _orderProductService = OrderProductService();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadOrderAndStartTimer();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/video2.mp4');
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.setVolume(0);
      _videoController.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  Future<void> _loadOrderAndStartTimer() async {
    final order = await context.read<OrderProvider>().getOrderById(widget.orderId);
    if (order != null && mounted) {
      // Load order products
      final products = await _orderProductService.getOrderProducts(widget.orderId);
      setState(() {
        _order = order;
        _products = products;
      });
      _startTimer(order);
    }
  }

  void _startTimer(OrderModel order) {
    // Calculate time elapsed since order creation (counting up, not down)
    _updateTimerDisplay(order);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimerDisplay(order);
      }
    });
  }

  void _updateTimerDisplay(OrderModel order) {
    // Use order.date (when available), createdAt as fallback, or now if both are null
    final orderTime = order.date ?? order.createdAt ?? DateTime.now();

    // Calculate time elapsed since order was placed (counting up)
    final now = DateTime.now();
    final elapsed = now.difference(orderTime);

    // Format as MM:SS (minutes and seconds elapsed)
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    setState(() {
      _timerDisplay = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.065),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_circle_left_sharp, color: AppTheme.amarelo, size: 35.0),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/orders');
              }
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _order == null
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryText)))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Title
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                              child: Text(
                                'Meus pedidos',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16.0, color: AppTheme.primaryText),
                              ),
                            ),
                          ),

                          // Products List
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(width: double.infinity, height: MediaQuery.of(context).size.height * 0.29, child: _buildProductsList()),
                          ),

                          // Timer Circle with Video Background
                          _shouldShowWaitTime(_order!)
                              ? Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 9.0, 0.0, 0.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 286.0,
                                        height: 270.0,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Video Background (circular)
                                            Container(
                                              width: 286.0,
                                              height: 286.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.grayPaletteGray20,
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: _isVideoInitialized
                                                  ? FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: SizedBox(
                                                        width: _videoController.value.size.width,
                                                        height: _videoController.value.size.height,
                                                        child: VideoPlayer(_videoController),
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.amarelo),
                                                      ),
                                                    ),
                                            ),
                                            // Timer Overlay
                                            Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: double.infinity,
                                                height: 100.0,
                                                color: Colors.transparent,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(_getWaitTimeLabel(_order!), style: GoogleFonts.inter(fontSize: 16.0, color: AppTheme.primaryText)),
                                                    Text(
                                                      _timerDisplay,
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 40.0, color: AppTheme.amarelo),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : _buildStatusMessage(_order!),

                          // Total and Payment
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 100.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Total
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total', style: GoogleFonts.inter(fontSize: 14.0, color: AppTheme.primaryText)),
                                    Text(
                                      'R\$ ${_order!.total.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18.0, color: AppTheme.amarelo),
                                    ),
                                  ],
                                ),
                                // Payment
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pagamento', style: GoogleFonts.inter(fontSize: 14.0, color: AppTheme.primaryText)),
                                    Text(
                                      _getPaymentText(_order!.payment),
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 18.0, color: AppTheme.amarelo),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Bottom spacing for navbar
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
            ),
          ),

          // Navbar
          const Align(alignment: Alignment.bottomCenter, child: NavbarWidget()),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_products.isEmpty) {
      return const Center(child: Text('Nenhum produto no pedido'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Product Image
              Container(
                width: 102.0,
                height: 100.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: product.menuItemPhoto.isNotEmpty
                      ? Image.network(
                          product.menuItemPhoto,
                          width: 102.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 102.0,
                            height: 100.0,
                            color: AppTheme.grayPaletteGray20,
                            child: const Icon(Icons.fastfood, color: AppTheme.grayPaletteGray60),
                          ),
                        )
                      : Container(
                          width: 102.0,
                          height: 100.0,
                          color: AppTheme.grayPaletteGray20,
                          child: const Icon(Icons.fastfood, color: AppTheme.grayPaletteGray60),
                        ),
                ),
              ),
              // Product Name
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                child: SizedBox(
                  width: 100.0,
                  height: 100.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      product.menuItemName,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16.0, color: AppTheme.primaryText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPaymentText(String payment) {
    switch (payment.toLowerCase()) {
      case 'pix':
        return 'PIX';
      case 'credit':
      case 'credito':
        return 'Cartão de crédito';
      case 'debit':
      case 'debito':
        return 'Cartão de débito';
      case 'cash':
      case 'dinheiro':
        return 'Dinheiro';
      default:
        return payment.isNotEmpty ? payment : 'Não informado';
    }
  }

  /// Verifica se deve mostrar o tempo de espera
  /// Mostra apenas quando:
  /// - Status é "em preparo" / "preparing"
  /// - OU status é "pronto" / "ready" E retirar == false (indo entregar no quarto)
  bool _shouldShowWaitTime(OrderModel order) {
    final status = order.status.toLowerCase();
    
    // Em preparo - sempre mostra
    if (status == 'em preparo' || status == 'preparing') {
      return true;
    }
    
    // Pronto e vai entregar no quarto (não é retirar)
    if ((status == 'pronto' || status == 'ready') && !order.retirar) {
      return true;
    }
    
    return false;
  }

  /// Retorna o texto do label baseado no status
  String _getWaitTimeLabel(OrderModel order) {
    final status = order.status.toLowerCase();
    
    if (status == 'em preparo' || status == 'preparing') {
      return 'Tempo de preparo';
    }
    
    if ((status == 'pronto' || status == 'ready') && !order.retirar) {
      return 'Indo entregar';
    }
    
    return 'Tempo de espera';
  }

  /// Widget para mostrar mensagem quando não há tempo de espera
  Widget _buildStatusMessage(OrderModel order) {
    final status = order.status.toLowerCase();
    String message;
    IconData icon;
    Color color;

    if (status == 'pendente' || status == 'pending') {
      message = 'Aguardando confirmação';
      icon = Icons.hourglass_empty;
      color = AppTheme.statusPending;
    } else if (status == 'pronto' || status == 'ready') {
      // retirar == true (vai buscar no balcão)
      message = 'Pronto para retirada!';
      icon = Icons.check_circle;
      color = AppTheme.statusReady;
    } else if (status == 'entregue' || status == 'delivered') {
      message = 'Pedido entregue!';
      icon = Icons.done_all;
      color = AppTheme.statusDelivered;
    } else if (status == 'cancelado' || status == 'cancelled') {
      message = 'Pedido cancelado';
      icon = Icons.cancel;
      color = Colors.red;
    } else {
      message = 'Status: ${order.status}';
      icon = Icons.info;
      color = AppTheme.secondaryText;
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 30.0),
      child: Column(
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
