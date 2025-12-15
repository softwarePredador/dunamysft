import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppStateProvider - Gerencia o estado global do aplicativo com persistência local
/// Equivalente ao FFAppState do FlutterFlow
class AppStateProvider extends ChangeNotifier {
  static AppStateProvider? _instance;
  
  factory AppStateProvider() {
    _instance ??= AppStateProvider._internal();
    return _instance!;
  }
  
  AppStateProvider._internal();
  
  static void reset() {
    _instance = AppStateProvider._internal();
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  // ==================== Estado do Carrinho ====================
  
  double _somaCarrinho = 0.0;
  double get somaCarrinho => _somaCarrinho;
  set somaCarrinho(double value) {
    _somaCarrinho = value;
    _saveDouble('somaCarrinho', value);
    notifyListeners();
  }

  // ==================== Estado do Pedido ====================
  
  bool _pedidoEmAndamento = false;
  bool get pedidoEmAndamento => _pedidoEmAndamento;
  set pedidoEmAndamento(bool value) {
    _pedidoEmAndamento = value;
    _saveBool('pedidoEmAndamento', value);
    notifyListeners();
  }

  String? _orderId;
  String? get orderId => _orderId;
  set orderId(String? value) {
    _orderId = value;
    if (value != null) {
      _saveString('orderId', value);
    } else {
      _removeKey('orderId');
    }
    notifyListeners();
  }

  String _timerOrder = '';
  String get timerOrder => _timerOrder;
  set timerOrder(String value) {
    _timerOrder = value;
    _saveString('timerOrder', value);
    notifyListeners();
  }

  // ==================== Estado do Pagamento PIX ====================
  
  String _pixString = '';
  String get pixString => _pixString;
  set pixString(String value) {
    _pixString = value;
    _secureStorage.write(key: 'pixString', value: value);
    notifyListeners();
  }

  String _pixQrCode = '';
  String get pixQrCode => _pixQrCode;
  set pixQrCode(String value) {
    _pixQrCode = value;
    _secureStorage.write(key: 'pixQrCode', value: value);
    notifyListeners();
  }

  // ==================== Estado do Quarto ====================
  
  bool _confirmRoom = false;
  bool get confirmRoom => _confirmRoom;
  set confirmRoom(bool value) {
    _confirmRoom = value;
    _saveBool('confirmRoom', value);
    notifyListeners();
  }

  String _roomNumber = '';
  String get roomNumber => _roomNumber;
  set roomNumber(String value) {
    _roomNumber = value;
    _saveString('roomNumber', value);
    notifyListeners();
  }

  // ==================== Adicionais ====================
  
  List<String> _selectedAdditionals = [];
  List<String> get selectedAdditionals => _selectedAdditionals;
  set selectedAdditionals(List<String> value) {
    _selectedAdditionals = value;
    _saveStringList('selectedAdditionals', value);
    notifyListeners();
  }

  void addAdditional(String value) {
    _selectedAdditionals.add(value);
    _saveStringList('selectedAdditionals', _selectedAdditionals);
    notifyListeners();
  }

  void removeAdditional(String value) {
    _selectedAdditionals.remove(value);
    _saveStringList('selectedAdditionals', _selectedAdditionals);
    notifyListeners();
  }

  void clearAdditionals() {
    _selectedAdditionals.clear();
    _removeKey('selectedAdditionals');
    notifyListeners();
  }

  // ==================== Inicialização ====================
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    // Carregar valores persistidos
    await _loadPersistedState();
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadPersistedState() async {
    try {
      // Carregar do SharedPreferences
      _somaCarrinho = _prefs?.getDouble('somaCarrinho') ?? 0.0;
      _pedidoEmAndamento = _prefs?.getBool('pedidoEmAndamento') ?? false;
      _orderId = _prefs?.getString('orderId');
      _timerOrder = _prefs?.getString('timerOrder') ?? '';
      _confirmRoom = _prefs?.getBool('confirmRoom') ?? false;
      _roomNumber = _prefs?.getString('roomNumber') ?? '';
      _selectedAdditionals = _prefs?.getStringList('selectedAdditionals') ?? [];

      // Carregar do SecureStorage (dados sensíveis)
      _pixString = await _secureStorage.read(key: 'pixString') ?? '';
      _pixQrCode = await _secureStorage.read(key: 'pixQrCode') ?? '';
    } catch (e) {
      debugPrint('Erro ao carregar estado persistido: $e');
    }
  }

  // ==================== Métodos de Persistência ====================
  
  Future<void> _saveDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<void> _saveStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  Future<void> _removeKey(String key) async {
    await _prefs?.remove(key);
  }

  // ==================== Métodos de Atualização ====================
  
  /// Atualiza o estado e notifica listeners (equivalente ao FFAppState.update)
  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // ==================== Métodos de Limpeza ====================
  
  /// Limpa o estado do carrinho
  void clearCart() {
    _somaCarrinho = 0.0;
    _selectedAdditionals.clear();
    _removeKey('somaCarrinho');
    _removeKey('selectedAdditionals');
    notifyListeners();
  }

  /// Limpa o estado do pedido atual
  void clearCurrentOrder() {
    _orderId = null;
    _pixString = '';
    _pixQrCode = '';
    _timerOrder = '';
    _pedidoEmAndamento = false;
    _removeKey('orderId');
    _removeKey('timerOrder');
    _saveBool('pedidoEmAndamento', false);
    _secureStorage.delete(key: 'pixString');
    _secureStorage.delete(key: 'pixQrCode');
    notifyListeners();
  }

  /// Limpa o estado do quarto
  void clearRoom() {
    _confirmRoom = false;
    _roomNumber = '';
    _saveBool('confirmRoom', false);
    _removeKey('roomNumber');
    notifyListeners();
  }

  /// Limpa todo o estado (usado no logout)
  Future<void> clearAll() async {
    _somaCarrinho = 0.0;
    _pedidoEmAndamento = false;
    _orderId = null;
    _timerOrder = '';
    _pixString = '';
    _pixQrCode = '';
    _confirmRoom = false;
    _roomNumber = '';
    _selectedAdditionals.clear();

    await _prefs?.clear();
    await _secureStorage.deleteAll();
    
    notifyListeners();
  }

  // ==================== Métodos Auxiliares ====================
  
  /// Inicia um novo pedido
  void startOrder(String newOrderId) {
    _orderId = newOrderId;
    _pedidoEmAndamento = true;
    _saveString('orderId', newOrderId);
    _saveBool('pedidoEmAndamento', true);
    notifyListeners();
  }

  /// Finaliza o pedido atual
  void finishOrder() {
    _pedidoEmAndamento = false;
    _orderId = null;
    _timerOrder = '';
    _saveBool('pedidoEmAndamento', false);
    _removeKey('orderId');
    _removeKey('timerOrder');
    notifyListeners();
  }

  /// Configura os dados do PIX
  void setPixData({required String pixCode, String? qrCode}) {
    _pixString = pixCode;
    _pixQrCode = qrCode ?? '';
    _secureStorage.write(key: 'pixString', value: pixCode);
    if (qrCode != null) {
      _secureStorage.write(key: 'pixQrCode', value: qrCode);
    }
    notifyListeners();
  }
}
