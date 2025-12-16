import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Serviço de logging centralizado para o aplicativo
class AppLogger {
  static const String _name = 'Dunamys';
  
  /// Log de debug (apenas em modo debug)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _name,
        level: 500, // FINE
      );
    }
  }
  
  /// Log de informação
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _name,
      level: 800, // INFO
    );
  }
  
  /// Log de warning
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _name,
      level: 900, // WARNING
    );
  }
  
  /// Log de erro
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    developer.log(
      message,
      name: tag ?? _name,
      level: 1000, // SEVERE
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log para requisições de API
  static void api(String method, String url, {int? statusCode, String? response}) {
    if (kDebugMode) {
      final status = statusCode != null ? ' [$statusCode]' : '';
      developer.log(
        '$method $url$status${response != null ? '\n$response' : ''}',
        name: '$_name/API',
        level: 500,
      );
    }
  }
  
  /// Log para Firebase
  static void firebase(String operation, {Object? data, Object? error}) {
    if (kDebugMode) {
      final msg = error != null 
          ? '$operation - Error: $error'
          : '$operation${data != null ? ': $data' : ''}';
      developer.log(
        msg,
        name: '$_name/Firebase',
        level: error != null ? 1000 : 500,
      );
    }
  }
}
