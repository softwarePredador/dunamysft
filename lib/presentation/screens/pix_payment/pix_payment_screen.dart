import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/payment_service.dart';
import '../../../data/services/order_service.dart';

class PIXPaymentScreen extends StatefulWidget {
  final String orderId;
  final double total;
  final String nome;
  final String cpf;

  const PIXPaymentScreen({
    super.key,
    required this.orderId,
    required this.total,
    required this.nome,
    required this.cpf,
  });

  @override
  State<PIXPaymentScreen> createState() => _PIXPaymentScreenState();
}

class _PIXPaymentScreenState extends State<PIXPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final OrderService _orderService = OrderService();
  
  bool _isLoading = true;
  String? _pixCode;
  String? _paymentId;
  String? _errorMessage;
  Timer? _statusTimer;
  StreamSubscription? _orderSubscription;
  final int _expirationMinutes = 30;

  @override
  void initState() {
    super.initState();
    _generatePixPayment();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _orderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _generatePixPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _paymentService.generatePixPayment(
      nomeCompleto: widget.nome,
      cpfCnpj: widget.cpf,
      valor: widget.total,
    );

    if (mounted) {
      if (result.success && result.qrCodeString != null) {
        setState(() {
          _pixCode = result.qrCodeString;
          _paymentId = result.paymentId;
          _isLoading = false;
        });
        
        // Salva o paymentId no pedido
        if (result.paymentId != null) {
          await _orderService.updatePaymentInfo(
            orderId: widget.orderId,
            paymentId: result.paymentId!,
            paymentStatus: 'pending',
          );
        }
        
        // Inicia polling do status a cada 5 segundos
        _startStatusPolling();
        
        // Inicia listener real-time do pedido (para webhook futuro)
        _startOrderListener();
      } else {
        setState(() {
          _errorMessage = result.errorMessage ?? 'Erro ao gerar PIX';
          _isLoading = false;
        });
      }
    }
  }

  /// Listener real-time do pedido - útil quando webhook atualizar o status
  void _startOrderListener() {
    _orderSubscription?.cancel();
    _orderSubscription = _orderService.streamOrder(widget.orderId).listen((order) {
      if (order != null && order.isPaid && mounted) {
        _statusTimer?.cancel();
        _orderSubscription?.cancel();
        _showSnackBar('Pagamento confirmado!', isSuccess: true);
        context.push('/order-done/${widget.orderId}');
      }
    });
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_paymentId != null) {
        final status = await _paymentService.checkPaymentStatus(_paymentId!);
        
        if (status.isPaid && mounted) {
          timer.cancel();
          
          // Atualiza status no Firebase
          await _orderService.updatePaymentInfo(
            orderId: widget.orderId,
            paymentId: _paymentId!,
            paymentStatus: 'paid',
          );
          
          // Pagamento confirmado! Vai para tela de sucesso
          _showSnackBar('Pagamento confirmado!', isSuccess: true);
          context.push('/order-done/${widget.orderId}');
        } else if (status.isCancelled && mounted) {
          timer.cancel();
          
          // Atualiza status no Firebase
          await _orderService.updatePaymentInfo(
            orderId: widget.orderId,
            paymentId: _paymentId!,
            paymentStatus: 'cancelled',
          );
          
          setState(() {
            _errorMessage = 'Pagamento cancelado ou expirado';
          });
        }
      }
    });
  }

  void _copyPixCode() {
    if (_pixCode != null) {
      Clipboard.setData(ClipboardData(text: _pixCode!));
      _showSnackBar('Código PIX copiado!', isSuccess: true);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppTheme.success : AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_sharp,
            color: AppTheme.amarelo,
            size: 35.0,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Pagamento PIX',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
            color: AppTheme.primaryText,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 140.0),
            child: _isLoading
                ? _buildLoading()
                : _errorMessage != null
                    ? _buildError()
                    : _buildPixContent(),
          ),

          // Bottom Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _pixCode != null 
                        ? () => context.push('/order-done/${widget.orderId}')
                        : _errorMessage != null 
                            ? _generatePixPayment 
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.amarelo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      _pixCode != null ? 'Já Paguei' : 'Tentar Novamente',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          const CircularProgressIndicator(color: AppTheme.amarelo),
          const SizedBox(height: 24),
          Text(
            'Gerando QR Code PIX...',
            style: GoogleFonts.inter(
              fontSize: 16.0,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline,
            color: AppTheme.error,
            size: 64,
          ),
          const SizedBox(height: 24),
          Text(
            'Erro ao gerar PIX',
            style: GoogleFonts.poppins(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixContent() {
    return Column(
      children: [
        // PIX QR Code Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Escaneie o QR Code',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 20.0),
              
              // QR Code real
              if (_pixCode != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: QrImageView(
                    data: _pixCode!,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),

              const SizedBox(height: 20.0),

              // Valor
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.amarelo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'R\$ ${widget.total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.amarelo,
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              Text(
                'ou copie o código PIX',
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: AppTheme.secondaryText,
                ),
              ),

              const SizedBox(height: 12.0),

              // PIX Code
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppTheme.grayPaletteGray10,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _pixCode ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 10.0,
                          color: AppTheme.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20.0),
                      onPressed: _copyPixCode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24.0),

        // Status do pagamento
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppTheme.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Aguardando confirmação do pagamento...',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: AppTheme.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24.0),

        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppTheme.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.info,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Como pagar com PIX',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                      color: AppTheme.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              _buildInstruction('1', 'Abra o app do seu banco'),
              _buildInstruction('2', 'Escolha pagar com PIX'),
              _buildInstruction('3', 'Escaneie o QR Code ou cole o código'),
              _buildInstruction('4', 'Confirme o pagamento'),
            ],
          ),
        ),

        const SizedBox(height: 24.0),

        // Timer Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: AppTheme.warning,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Este código expira em $_expirationMinutes minutos',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.0,
            height: 20.0,
            decoration: const BoxDecoration(
              color: AppTheme.info,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
