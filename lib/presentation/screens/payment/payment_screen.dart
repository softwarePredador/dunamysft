import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/payment_service.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/end_drawer_widget.dart';

/// Tela de Pagamento - Fluxo completo
/// 
/// FLUXO CORRETO:
/// 1. Escolher entrega (Quarto ou Retirada) - PRIMEIRO
/// 2. Escolher forma de pagamento (Débito/Crédito/Pix)
/// 3. Preencher dados do pagamento
/// 4. Processar → PIX vai para tela de QR Code, Cartão vai direto para OrderDone
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final PaymentService _paymentService = PaymentService();
  
  // Etapa atual: 1 = Entrega, 2 = Pagamento
  int _currentStep = 1;
  
  // Entrega
  bool _isPickup = false; // true = retirar na recepção, false = entregar no quarto
  final TextEditingController _roomController = TextEditingController();
  
  // Tipo de pagamento: 'Débito', 'Crédito', 'Pix'
  String _selectedPaymentType = 'Débito';
  bool _isLoading = false;
  String? _detectedBrand;

  // Controllers para PIX
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  // Controllers para Cartão
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardCpfController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_onCardNumberChanged);
    _roomController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _cardCpfController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() async {
    final number = _cardNumberController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (number.length >= 6) {
      final brand = await _paymentService.detectCardBrand(number);
      if (brand != _detectedBrand && mounted) {
        setState(() => _detectedBrand = brand);
      }
    } else if (_detectedBrand != null) {
      setState(() => _detectedBrand = null);
    }
  }

  void _goToPaymentStep() {
    // Validar entrega
    if (!_isPickup && _roomController.text.isEmpty) {
      _showSnackBar('Informe o número do apartamento');
      return;
    }
    
    setState(() => _currentStep = 2);
  }

  Future<void> _processPayment() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      _showSnackBar('Faça login para continuar');
      return;
    }

    // Validações por tipo de pagamento
    if (_selectedPaymentType == 'Pix') {
      if (_nomeController.text.isEmpty) {
        _showSnackBar('Nome Obrigatório');
        return;
      }
      if (_cpfController.text.isEmpty) {
        _showSnackBar('CPF Obrigatório');
        return;
      }
    } else {
      // Débito ou Crédito
      if (_cardNumberController.text.isEmpty) {
        _showSnackBar('Informe o número do cartão');
        return;
      }
      if (_cardExpiryController.text.isEmpty) {
        _showSnackBar('Obrigatório a data de validade');
        return;
      }
      if (_cardCvvController.text.isEmpty) {
        _showSnackBar('CVV Obrigatório');
        return;
      }
      if (_cardHolderController.text.isEmpty) {
        _showSnackBar('Obrigatório o titular');
        return;
      }
      if (_cardCpfController.text.isEmpty) {
        _showSnackBar('CPF Obrigatório');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final cartProvider = context.read<CartProvider>();
      final orderProvider = context.read<OrderProvider>();

      // Determina método de pagamento para salvar
      String paymentMethod;
      
      if (_selectedPaymentType == 'Débito') {
        paymentMethod = 'Cartão de débito';
      } else if (_selectedPaymentType == 'Crédito') {
        paymentMethod = 'Cartão de crédito';
      } else {
        paymentMethod = 'Pix';
      }

      // Para cartão, processa pagamento ANTES de criar pedido
      String? cardPaymentId;
      if (_selectedPaymentType != 'Pix') {
        // Detecta bandeira se não detectada ainda
        String brand = _detectedBrand ?? 
            await _paymentService.detectCardBrand(_cardNumberController.text) ?? 
            'Visa';
        
        // Tipo Cielo: DebitCard ou CreditCard
        String tipo = _selectedPaymentType == 'Débito' ? 'DebitCard' : 'CreditCard';
        
        // Processa pagamento com Cielo
        final cardResult = await _paymentService.processCardPayment(
          nomeCompleto: _cardHolderController.text,
          valor: cartProvider.totalPrice,
          cardNumber: _cardNumberController.text,
          expiration: _cardExpiryController.text,
          securityCode: _cardCvvController.text,
          brand: brand,
          tipo: tipo,
        );
        
        if (!cardResult.success || !cardResult.isApproved) {
          setState(() => _isLoading = false);
          _showSnackBar(cardResult.errorMessage ?? cardResult.returnMessage ?? 'Pagamento não aprovado');
          return;
        }
        
        // Pagamento aprovado, salva paymentId para usar depois
        cardPaymentId = cardResult.paymentId;
        debugPrint('Cartão aprovado! PaymentId: $cardPaymentId');
      }

      // Cria ordem com todos os dados
      final totalPrice = cartProvider.totalPrice; // Salva antes de limpar
      final orderId = await orderProvider.createOrder(
        userId: user.uid,
        items: cartProvider.cartItems,
        total: totalPrice,
        paymentMethod: paymentMethod,
        deliveryType: _isPickup ? 'pickup' : 'delivery',
        room: _isPickup ? '' : _roomController.text,
        customerName: _selectedPaymentType == 'Pix' 
            ? _nomeController.text 
            : _cardHolderController.text,
        customerCpf: _selectedPaymentType == 'Pix' 
            ? _cpfController.text 
            : _cardCpfController.text,
      );

      if (orderId != null && mounted) {
        // Se foi cartão, atualiza status para pago
        if (_selectedPaymentType != 'Pix' && cardPaymentId != null) {
          await orderProvider.updatePaymentInfo(
            orderId: orderId,
            paymentId: cardPaymentId,
            paymentStatus: 'paid',
          );
        }
        
        // Limpar carrinho
        await cartProvider.clearCart(user.uid);
        
        // Atualizar estado global para mostrar badge de notificação
        final appState = context.read<AppStateProvider>();
        appState.orderId = orderId;
        appState.pedidoEmAndamento = true;
        // confirmRoom: PIX precisa confirmar quarto depois (se não selecionou), 
        // Cartão já tem quarto definido
        appState.confirmRoom = _selectedPaymentType == 'Pix' && !_isPickup && _roomController.text.isEmpty;
        appState.roomNumber = _roomController.text;
        
        setState(() => _isLoading = false);
        
        if (_selectedPaymentType == 'Pix') {
          // Para PIX, gera QR code na tela de PIX (passando dados)
          context.push('/pix-payment', extra: {
            'orderId': orderId,
            'total': totalPrice, // Usa o valor salvo
            'nome': _nomeController.text,
            'cpf': _cpfController.text,
          });
        } else {
          // Cartão → vai direto para tela de pedido concluído
          context.push('/order-done/$orderId');
        }
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('Erro ao criar pedido');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Erro ao processar pagamento: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.primaryBackground),
        ),
        backgroundColor: AppTheme.secondary,
        duration: const Duration(milliseconds: 2100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.primaryBackground,
        endDrawer: const EndDrawerWidget(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).height * 0.065),
          child: AppBar(
            backgroundColor: AppTheme.primaryBackground,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_circle_left_sharp,
                color: AppTheme.amarelo,
                size: 35.0,
              ),
              onPressed: () {
                if (_currentStep == 2) {
                  setState(() => _currentStep = 1);
                } else {
                  context.pop();
                }
              },
            ),
            actions: const [],
            elevation: 0.0,
          ),
        ),
        body: Stack(
          children: [
            // Conteúdo com scroll
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 200.0),
              child: _currentStep == 1 
                  ? _buildDeliveryStep(cartProvider)
                  : _buildPaymentStep(cartProvider),
            ),
            
            // Navbar
            Align(
              alignment: Alignment.bottomCenter,
              child: NavbarWidget(
                onMenuTap: () => scaffoldKey.currentState?.openEndDrawer(),
              ),
            ),
            
            // Loading Overlay
            if (_isLoading)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0x564B3E3C),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.amarelo,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ETAPA 1: Escolher entrega (Quarto ou Retirada)
  Widget _buildDeliveryStep(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          'Entrega',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
            height: 2.0,
          ),
        ),
        
        const SizedBox(height: 20.0),
        
        // Subtítulo
        Center(
          child: Text(
            'Informe o apartamento',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
            ),
          ),
        ),
        
        const SizedBox(height: 16.0),
        
        // Campo de número do quarto
        Center(
          child: Container(
            width: 230.0,
            height: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.0),
              border: Border.all(
                color: _isPickup ? const Color(0xFFCCCCCC).withOpacity(0.5) : const Color(0xFFCCCCCC),
                width: 1.0,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 200.0,
                child: TextField(
                  controller: _roomController,
                  enabled: !_isPickup,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 40.0,
                    color: _isPickup ? Colors.grey : AppTheme.primaryText,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: '000',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 40.0,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 50.0),
        
        // Opção de retirar na recepção
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _isPickup = !_isPickup),
            child: Container(
              width: 240.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                  color: AppTheme.amarelo,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _isPickup,
                    onChanged: (value) => setState(() => _isPickup = value ?? false),
                    activeColor: AppTheme.amarelo,
                    shape: const CircleBorder(),
                  ),
                  Flexible(
                    child: Text(
                      'prefiro retirar na recepção',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 50.0),
        
        // Botão Continuar
        Center(
          child: GestureDetector(
            onTap: _goToPaymentStep,
            child: Container(
              width: 320.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: AppTheme.amarelo,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Text(
                  'Continuar para Pagamento',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: AppTheme.secondaryBackground,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20.0),
        
        // Resumo
        _buildOrderSummary(cartProvider),
      ],
    );
  }

  /// ETAPA 2: Forma de pagamento
  Widget _buildPaymentStep(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          'Pagamento',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
            height: 2.0,
          ),
        ),
        
        // Info de entrega
        Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
          decoration: BoxDecoration(
            color: AppTheme.amarelo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppTheme.amarelo.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _isPickup ? Icons.store : Icons.room_service,
                color: AppTheme.amarelo,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  _isPickup 
                      ? 'Retirar na recepção'
                      : 'Entregar no apartamento ${_roomController.text}',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentStep = 1),
                child: Text(
                  'Alterar',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppTheme.amarelo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // "Pagamento Total"
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Forma de Pagamento',
            style: GoogleFonts.inter(
              fontSize: 14.0,
            ),
          ),
        ),
        
        // Choice Chips: Débito | Crédito | Pix
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildPaymentChip('Débito', Icons.circle),
              _buildPaymentChip('Crédito', Icons.circle),
              _buildPaymentChip('Pix', Icons.circle),
            ],
          ),
        ),
        
        // Campos para PIX
        if (_selectedPaymentType == 'Pix') ...[
          _buildTextField(
            controller: _nomeController,
            label: 'Nome Completo',
          ),
          const SizedBox(height: 20.0),
          _buildTextField(
            controller: _cpfController,
            label: 'CPF',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CpfInputFormatter(),
            ],
          ),
        ],
        
        // Campos para Débito/Crédito
        if (_selectedPaymentType == 'Débito' || 
            _selectedPaymentType == 'Crédito') ...[
          _buildTextField(
            controller: _cardNumberController,
            label: 'Número do cartão',
            keyboardType: TextInputType.number,
            maxLength: 16,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: _buildTextField(
                    controller: _cardExpiryController,
                    label: 'Validade',
                    hint: 'MM/YYYY',
                    keyboardType: TextInputType.datetime,
                    maxLength: 7,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpiryDateInputFormatter(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: _buildTextField(
                    controller: _cardCvvController,
                    label: 'CVV',
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          _buildTextField(
            controller: _cardHolderController,
            label: 'Nome do titular',
          ),
          const SizedBox(height: 20.0),
          _buildTextField(
            controller: _cardCpfController,
            label: 'CPF / CNPJ do titular',
            keyboardType: TextInputType.number,
            maxLength: 14,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CpfInputFormatter(),
            ],
          ),
        ],
        
        const SizedBox(height: 30.0),
        
        // Total + Botão Finalizar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                  ),
                ),
                Text(
                  'R\$ ${cartProvider.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                    color: AppTheme.amarelo,
                  ),
                ),
              ],
            ),
            
            // Botão Finalizar
            GestureDetector(
              onTap: _isLoading ? null : _processPayment,
              child: Container(
                width: 200.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: AppTheme.amarelo,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Center(
                  child: Text(
                    _selectedPaymentType == 'Pix' ? 'Gerar PIX' : 'Finalizar',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.secondaryBackground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
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
            'Resumo do Pedido',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 12.0),
          ...cartProvider.cartItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity}x ${item.menuItemName}',
                    style: GoogleFonts.inter(fontSize: 14.0),
                  ),
                ),
                Text(
                  'R\$ ${item.total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.inter(fontSize: 14.0),
                ),
              ],
            ),
          )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
              Text(
                'R\$ ${cartProvider.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                  color: AppTheme.amarelo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String label, IconData icon) {
    final isSelected = _selectedPaymentType == label;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppTheme.primaryBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? AppTheme.amarelo : AppTheme.bordaCinza,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12.0,
              color: isSelected ? AppTheme.amarelo : const Color(0x5B57636C),
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(
          fontSize: 14.0,
          color: AppTheme.secondaryText,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14.0,
          color: AppTheme.secondaryText,
        ),
        counterText: '',
        filled: true,
        fillColor: AppTheme.primaryBackground,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFCCCCCC),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppTheme.amarelo,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      style: GoogleFonts.inter(
        fontSize: 14.0,
        color: AppTheme.primaryText,
      ),
    );
  }
}

/// Formatter para CPF: 000.000.000-00
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 11; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Formatter para data de validade: MM/YYYY
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 6; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
