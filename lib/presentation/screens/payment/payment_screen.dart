import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/end_drawer_widget.dart';

// Callback type para open drawer
typedef OpenDrawerCallback = void Function();

/// Tela de Pagamento - Migrada do FlutterFlow payment_user_widget.dart
/// Fluxo: 
/// - Escolher tipo: Débito | Crédito | Pix
/// - PIX: pede Nome + CPF → vai para /pix-payment
/// - Cartão: pede dados do cartão → vai para /room (escolher quarto)
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Tipo de pagamento selecionado: 'Débito', 'Crédito', 'Pix'
  String _selectedPaymentType = 'Débito';
  bool _isLoading = false;

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
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _cardCpfController.dispose();
    super.dispose();
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

      // Cria ordem
      final orderId = await orderProvider.createOrder(
        userId: user.uid,
        items: cartProvider.cartItems,
        total: cartProvider.totalPrice,
        paymentMethod: paymentMethod,
        deliveryType: 'delivery', // será definido na tela room
        room: '', // será definido na tela room
        customerName: _selectedPaymentType == 'Pix' 
            ? _nomeController.text 
            : _cardHolderController.text,
        customerCpf: _selectedPaymentType == 'Pix' 
            ? _cpfController.text 
            : _cardCpfController.text,
      );

      setState(() => _isLoading = false);

      if (orderId != null && mounted) {
        // Limpar carrinho
        await cartProvider.clearCart(user.uid);
        
        if (_selectedPaymentType == 'Pix') {
          // PIX → vai para tela de pagamento PIX
          context.push('/pix-payment', extra: orderId);
        } else {
          // Cartão → vai para tela room (escolher quarto)
          context.push('/room', extra: orderId);
        }
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
          style: TextStyle(color: AppTheme.primaryBackground),
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
              onPressed: () => context.pop(),
            ),
            actions: const [],
            elevation: 0.0,
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBackground,
                ),
                child: Column(
                  children: [
                    // Título "Pagamento"
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBackground,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Pagamento',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              height: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // "Pagamento Total"
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          'Pagamento Total',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                    
                    // Choice Chips: Débito | Crédito | Pix
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
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
                    ),
                    
                    // Formulário condicional baseado no tipo de pagamento
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                                        label: 'Data de validade',
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
                            
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom: Total + Botão Continuar
                    Container(
                      width: double.infinity,
                      height: 100.0,
                      decoration: const BoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Total
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                          
                          // Botão Continuar
                          GestureDetector(
                            onTap: _isLoading ? null : _processPayment,
                            child: Container(
                              width: 200.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                color: AppTheme.amarelo,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Continuar',
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
                    ),
                  ],
                ),
              ),
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
                decoration: BoxDecoration(
                  color: const Color(0x564B3E3C),
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
        counterText: '', // Hide counter
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
