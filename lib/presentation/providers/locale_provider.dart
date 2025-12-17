import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar o idioma do aplicativo
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _locale = const Locale('pt', 'BR');
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  /// Inicializa o provider carregando o idioma salvo
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
      } else {
        _locale = Locale(parts[0]);
      }
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Define o idioma e salva nas preferências
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    
    _locale = newLocale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, '${newLocale.languageCode}_${newLocale.countryCode}');
  }

  /// Define o idioma por código (pt, en, es)
  Future<void> setLocaleByCode(String languageCode) async {
    Locale newLocale;
    switch (languageCode) {
      case 'en':
        newLocale = const Locale('en', 'US');
        break;
      case 'es':
        newLocale = const Locale('es', 'ES');
        break;
      case 'pt':
      default:
        newLocale = const Locale('pt', 'BR');
        break;
    }
    await setLocale(newLocale);
  }

  /// Retorna o nome do idioma atual
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'pt':
      default:
        return 'Português';
    }
  }

  /// Lista de idiomas disponíveis
  static List<LanguageOption> get availableLanguages => [
    LanguageOption(
      code: 'pt',
      name: 'Português',
      nativeName: 'Português',
      flag: '🇧🇷',
      locale: const Locale('pt', 'BR'),
    ),
    LanguageOption(
      code: 'en',
      name: 'Inglês',
      nativeName: 'English',
      flag: '🇺🇸',
      locale: const Locale('en', 'US'),
    ),
    LanguageOption(
      code: 'es',
      name: 'Espanhol',
      nativeName: 'Español',
      flag: '🇪🇸',
      locale: const Locale('es', 'ES'),
    ),
  ];
}

/// Representa uma opção de idioma
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}
