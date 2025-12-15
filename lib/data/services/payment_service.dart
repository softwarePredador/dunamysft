import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Credenciais Cielo Sandbox
/// ATENÇÃO: Em produção, usar variáveis de ambiente ou backend seguro
class CieloCredentials {
  static const String merchantId = '8937bd5b-9796-494d-9fe5-f76b3e4da633';
  static const String merchantKey = 'XKGHUBSBKIRXKAVPSKWLVXYCLVJUGTNZLIHPUSYV';
  static const String salesUrl = 'https://apisandbox.cieloecommerce.cielo.com.br/1/sales/';
  static const String queryUrl = 'https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/';
}

/// Resposta de pagamento PIX
class PixPaymentResponse {
  final bool success;
  final String? paymentId;
  final String? qrCodeString;
  final String? errorMessage;

  PixPaymentResponse({
    required this.success,
    this.paymentId,
    this.qrCodeString,
    this.errorMessage,
  });
}

/// Resposta de pagamento com Cartão
class CardPaymentResponse {
  final bool success;
  final String? paymentId;
  final int? status;
  final String? returnMessage;
  final String? errorMessage;

  CardPaymentResponse({
    required this.success,
    this.paymentId,
    this.status,
    this.returnMessage,
    this.errorMessage,
  });
  
  /// Status 2 = PaymentConfirmed (para débito com captura)
  /// Status 1 = Authorized (para crédito)
  bool get isApproved => status == 1 || status == 2;
}

/// Resposta de consulta de pagamento
class PaymentStatusResponse {
  final bool success;
  final String? paymentId;
  final int? status;
  final int? amount;
  final String? errorMessage;

  PaymentStatusResponse({
    required this.success,
    this.paymentId,
    this.status,
    this.amount,
    this.errorMessage,
  });

  /// Status 2 = Pagamento confirmado (PIX pago)
  bool get isPaid => status == 2;
  
  /// Status 10 = Voided, 11 = Refunded, 12 = Pending, 13 = Aborted
  bool get isCancelled => status == 10 || status == 11 || status == 13;
}

/// Service para integração com Cielo
class PaymentService {
  final http.Client _client;

  PaymentService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'MerchantId': CieloCredentials.merchantId,
    'MerchantKey': CieloCredentials.merchantKey,
    'accept': 'application/json',
  };

  /// Gera pagamento PIX
  /// [valor] deve estar em reais (ex: 100.50)
  /// [nomeCompleto] nome do cliente
  /// [cpfCnpj] documento do cliente
  /// [tipo] "CPF" ou "CNPJ"
  Future<PixPaymentResponse> generatePixPayment({
    required String nomeCompleto,
    required String cpfCnpj,
    required double valor,
    String tipo = 'CPF',
  }) async {
    try {
      // Cielo espera valor em centavos
      final valorCentavos = (valor * 100).round();
      
      final body = jsonEncode({
        'MerchantOrderId': 'DunamysHotel${DateTime.now().millisecondsSinceEpoch}',
        'Customer': {
          'Name': _escapeString(nomeCompleto),
          'Identity': _escapeString(cpfCnpj.replaceAll(RegExp(r'[^\d]'), '')),
          'IdentityType': tipo,
        },
        'Payment': {
          'Type': 'Pix',
          'Amount': valorCentavos,
        },
      });

      debugPrint('PIX Request: $body');

      final response = await _client.post(
        Uri.parse(CieloCredentials.salesUrl),
        headers: _headers,
        body: body,
      );

      debugPrint('PIX Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payment = data['Payment'];
        
        if (payment != null) {
          return PixPaymentResponse(
            success: true,
            paymentId: payment['PaymentId']?.toString(),
            qrCodeString: payment['QrCodeString']?.toString(),
          );
        }
      }

      // Tenta extrair mensagem de erro
      String? errorMsg;
      try {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          errorMsg = data[0]['Message']?.toString();
        } else if (data is Map) {
          errorMsg = data['Message']?.toString();
        }
      } catch (_) {}

      return PixPaymentResponse(
        success: false,
        errorMessage: errorMsg ?? 'Erro ao gerar PIX: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Erro PIX: $e');
      return PixPaymentResponse(
        success: false,
        errorMessage: 'Erro de conexão: $e',
      );
    }
  }

  /// Processa pagamento com cartão (débito ou crédito)
  /// [valor] deve estar em reais (ex: 100.50)
  /// [tipo] "DebitCard" ou "CreditCard"
  /// [brand] "Visa", "Master", "Elo", etc
  Future<CardPaymentResponse> processCardPayment({
    required String nomeCompleto,
    required double valor,
    required String cardNumber,
    required String expiration, // MM/YYYY
    required String securityCode,
    required String brand,
    required String tipo, // "DebitCard" ou "CreditCard"
  }) async {
    try {
      // Cielo espera valor em centavos
      final valorCentavos = (valor * 100).round();
      
      // Formata expiração para MM/YYYY se vier em outro formato
      String formattedExpiration = expiration;
      if (expiration.length == 5 && expiration.contains('/')) {
        // Formato MM/YY -> MM/20YY
        final parts = expiration.split('/');
        formattedExpiration = '${parts[0]}/20${parts[1]}';
      }
      
      final body = jsonEncode({
        'MerchantOrderId': 'DunamysHotel${DateTime.now().millisecondsSinceEpoch}',
        'Customer': {
          'Name': _escapeString(nomeCompleto),
        },
        'Payment': {
          'Type': tipo,
          tipo: {
            'CardNumber': cardNumber.replaceAll(RegExp(r'[^\d]'), ''),
            'Holder': _escapeString(nomeCompleto),
            'ExpirationDate': formattedExpiration,
            'SecurityCode': securityCode,
            'SaveCard': 'false',
            'Brand': brand,
          },
          'Currency': 'BRL',
          'Country': 'BRA',
          'Installments': 1,
          'Capture': true,
          'Tip': false,
          'Amount': valorCentavos,
        },
      });

      debugPrint('Card Request: $body');

      final response = await _client.post(
        Uri.parse(CieloCredentials.salesUrl),
        headers: _headers,
        body: body,
      );

      debugPrint('Card Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payment = data['Payment'];
        
        if (payment != null) {
          return CardPaymentResponse(
            success: true,
            paymentId: payment['PaymentId']?.toString(),
            status: payment['Status'] as int?,
            returnMessage: payment['ReturnMessage']?.toString(),
          );
        }
      }

      // Tenta extrair mensagem de erro
      String? errorMsg;
      try {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          errorMsg = data[0]['Message']?.toString();
        } else if (data is Map) {
          errorMsg = data['Message']?.toString() ?? 
                     data['Payment']?['ReturnMessage']?.toString();
        }
      } catch (_) {}

      return CardPaymentResponse(
        success: false,
        errorMessage: errorMsg ?? 'Erro ao processar cartão: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Erro Card: $e');
      return CardPaymentResponse(
        success: false,
        errorMessage: 'Erro de conexão: $e',
      );
    }
  }

  /// Consulta status de um pagamento
  Future<PaymentStatusResponse> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _client.get(
        Uri.parse('${CieloCredentials.queryUrl}$paymentId'),
        headers: _headers,
      );

      debugPrint('Status Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payment = data['Payment'];
        
        if (payment != null) {
          return PaymentStatusResponse(
            success: true,
            paymentId: payment['PaymentId']?.toString(),
            status: payment['Status'] as int?,
            amount: payment['Amount'] as int?,
          );
        }
      }

      return PaymentStatusResponse(
        success: false,
        errorMessage: 'Erro ao consultar: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Erro Status: $e');
      return PaymentStatusResponse(
        success: false,
        errorMessage: 'Erro de conexão: $e',
      );
    }
  }

  /// Detecta bandeira do cartão pelo BIN (primeiros 6 dígitos)
  Future<String?> detectCardBrand(String cardNumber) async {
    try {
      final bin = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (bin.length < 6) return null;

      final response = await _client.get(
        Uri.parse('${CieloCredentials.queryUrl.replaceFirst('/sales/', '/cardBin/')}${bin.substring(0, 6)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['Provider']?.toString();
      }

      // Fallback: detecção local
      return _detectBrandLocally(bin);
    } catch (e) {
      debugPrint('Erro ao detectar bandeira: $e');
      return _detectBrandLocally(cardNumber);
    }
  }

  /// Detecção local de bandeira (fallback)
  String? _detectBrandLocally(String cardNumber) {
    final number = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (number.isEmpty) return null;

    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5') || number.startsWith('2')) return 'Master';
    if (number.startsWith('34') || number.startsWith('37')) return 'Amex';
    if (number.startsWith('636368') || 
        number.startsWith('438935') || 
        number.startsWith('504175') ||
        number.startsWith('451416') ||
        number.startsWith('636297')) return 'Elo';
    if (number.startsWith('6011') || number.startsWith('65')) return 'Discover';
    if (number.startsWith('36') || number.startsWith('38')) return 'Diners';
    if (number.startsWith('35')) return 'JCB';
    if (number.startsWith('606282') || number.startsWith('3841')) return 'Hipercard';

    return null;
  }

  /// Escapa string para JSON
  String _escapeString(String? input) {
    if (input == null) return '';
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\t', '\\t');
  }

  void dispose() {
    _client.close();
  }
}
