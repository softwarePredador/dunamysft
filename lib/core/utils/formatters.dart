import 'package:intl/intl.dart';

/// Formatters for displaying data
class Formatters {
  /// Formats currency in Brazilian Real (BRL)
  static String currency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Formats date to Brazilian format (dd/MM/yyyy)
  static String date(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(date);
  }

  /// Formats date and time to Brazilian format (dd/MM/yyyy HH:mm)
  static String dateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return formatter.format(dateTime);
  }

  /// Formats time (HH:mm)
  static String time(DateTime time) {
    final formatter = DateFormat('HH:mm', 'pt_BR');
    return formatter.format(time);
  }

  /// Formats phone number to Brazilian format
  static String phone(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbers.length == 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    } else if (numbers.length == 10) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    }
    
    return phone;
  }

  /// Formats CPF to Brazilian format (###.###.###-##)
  static String cpf(String cpf) {
    final numbers = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbers.length == 11) {
      return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
    }
    
    return cpf;
  }

  /// Formats number with thousand separators
  static String number(num value, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    if (decimalDigits > 0) {
      formatter.minimumFractionDigits = decimalDigits;
      formatter.maximumFractionDigits = decimalDigits;
    }
    return formatter.format(value);
  }
}
