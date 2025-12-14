/// Validators for form inputs
class Validators {
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  /// Validates password with minimum length
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < minLength) {
      return 'Senha deve ter pelo menos $minLength caracteres';
    }
    
    return null;
  }

  /// Validates required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Campo'} é obrigatório';
    }
    return null;
  }

  /// Validates phone number (Brazilian format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    final phoneRegex = RegExp(r'^\(\d{2}\)\s?\d{4,5}-?\d{4}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Telefone inválido. Use o formato (11) 98765-4321';
    }
    
    return null;
  }

  /// Validates CPF (Brazilian tax ID)
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    // Remove non-numeric characters
    final cpfNumbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cpfNumbers.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Basic validation (does not check verifying digits)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfNumbers)) {
      return 'CPF inválido';
    }
    
    return null;
  }
}
