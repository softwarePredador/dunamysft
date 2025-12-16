import 'dart:convert';
import 'package:flutter/services.dart';

/// Serviço para gerenciar valores de ambiente
class EnvironmentService {
  static final EnvironmentService _instance = EnvironmentService._internal();
  factory EnvironmentService() => _instance;
  EnvironmentService._internal();

  Map<String, dynamic>? _config;
  bool _isInitialized = false;

  /// Carrega as configurações do arquivo JSON
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/environment_values/environment.json',
      );
      _config = json.decode(jsonString) as Map<String, dynamic>;
      _isInitialized = true;
    } catch (e) {
      // Se falhar, usa valores padrão (sandbox)
      _config = {
        'environment': 'sandbox',
        'cielo': {
          'sandbox': {
            'merchantId': '8937bd5b-9796-494d-9fe5-f76b3e4da633',
            'merchantKey': 'XKGHUBSBKIRXKAVPSKWLVXYCLVJUGTNZLIHPUSYV',
            'salesUrl': 'https://apisandbox.cieloecommerce.cielo.com.br/1/sales/',
            'queryUrl': 'https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/',
          },
        },
      };
      _isInitialized = true;
    }
  }

  /// Retorna o ambiente atual (sandbox ou production)
  String get environment => _config?['environment'] ?? 'sandbox';

  /// Verifica se está em produção
  bool get isProduction => environment == 'production';

  /// Verifica se está em sandbox
  bool get isSandbox => environment == 'sandbox';

  /// Retorna as credenciais da Cielo para o ambiente atual
  CieloConfig get cielo {
    final cieloConfig = _config?['cielo'] as Map<String, dynamic>?;
    final envConfig = cieloConfig?[environment] as Map<String, dynamic>?;

    return CieloConfig(
      merchantId: envConfig?['merchantId'] ?? '',
      merchantKey: envConfig?['merchantKey'] ?? '',
      salesUrl: envConfig?['salesUrl'] ?? '',
      queryUrl: envConfig?['queryUrl'] ?? '',
    );
  }
}

/// Configurações da Cielo
class CieloConfig {
  final String merchantId;
  final String merchantKey;
  final String salesUrl;
  final String queryUrl;

  CieloConfig({
    required this.merchantId,
    required this.merchantKey,
    required this.salesUrl,
    required this.queryUrl,
  });
}
