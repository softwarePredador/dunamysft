import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Serviço para gerenciar Push Notifications via Firebase Cloud Messaging
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    try {
      // Solicitar permissão
      await _requestPermission();

      // Configurar notificações locais
      await _setupLocalNotifications();

      // Obter token FCM
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Configurar handlers
      _setupMessageHandlers();

      // Escutar refresh do token
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        // Atualizar no Firestore se usuário estiver logado
      });
    } catch (e) {
      debugPrint('Erro ao inicializar Push Notifications: $e');
    }
  }

  /// Solicita permissão para receber notificações
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Permissão de notificação: ${settings.authorizationStatus}');
  }

  /// Configura notificações locais para foreground
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Criar canal de notificação para Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notificações Importantes',
        description: 'Canal para notificações do Dunamys Hotel',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Configura handlers para mensagens
  void _setupMessageHandlers() {
    // Mensagens recebidas com app em foreground
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensagens quando o app é aberto via notificação (background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar se o app foi aberto via notificação (terminated)
    _checkInitialMessage();
  }

  /// Verifica se o app foi aberto via notificação
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App aberto via notificação: ${initialMessage.data}');
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Processa mensagem recebida em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Mensagem recebida em foreground: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Dunamys Hotel',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Processa quando o app é aberto via notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App aberto via notificação: ${message.data}');
    // Aqui você pode navegar para uma tela específica baseado em message.data
    // Por exemplo: se message.data['orderId'] != null, navegar para detalhes do pedido
  }

  /// Handler para quando uma notificação local é clicada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificação local clicada: ${response.payload}');
    // Processar navegação baseado no payload
  }

  /// Exibe uma notificação local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notificações Importantes',
      channelDescription: 'Canal para notificações do Dunamys Hotel',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Salva o token FCM no documento do usuário
  Future<void> saveTokenToUser(String userId) async {
    if (_fcmToken == null) {
      _fcmToken = await _messaging.getToken();
    }

    if (_fcmToken != null) {
      try {
        await _firestore.collection('users').doc(userId).update({
          'fcm_tokens': FieldValue.arrayUnion([_fcmToken]),
        });
        debugPrint('Token FCM salvo para usuário: $userId');
      } catch (e) {
        // Se o campo não existe, criar
        try {
          await _firestore.collection('users').doc(userId).set({
            'fcm_tokens': [_fcmToken],
          }, SetOptions(merge: true));
        } catch (e2) {
          debugPrint('Erro ao salvar token FCM: $e2');
        }
      }
    }
  }

  /// Remove o token FCM do documento do usuário (ao fazer logout)
  Future<void> removeTokenFromUser(String userId) async {
    if (_fcmToken != null) {
      try {
        await _firestore.collection('users').doc(userId).update({
          'fcm_tokens': FieldValue.arrayRemove([_fcmToken]),
        });
        debugPrint('Token FCM removido do usuário: $userId');
      } catch (e) {
        debugPrint('Erro ao remover token FCM: $e');
      }
    }
  }

  /// Limpa subscriptions
  void dispose() {
    _foregroundSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
  }

  /// Envia notificação para um usuário específico via Cloud Function
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('sendPushNotification');
      
      final result = await callable.call({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
      });
      
      debugPrint('Notificação enviada: ${result.data}');
      return result.data['success'] ?? false;
    } catch (e) {
      debugPrint('Erro ao enviar notificação: $e');
      return false;
    }
  }

  /// Envia notificação para múltiplos usuários
  Future<void> sendNotificationToMultipleUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    for (final userId in userIds) {
      await sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    }
  }

  /// Envia notificação de atualização de pedido para o cliente
  Future<void> notifyOrderUpdate({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    String title;
    String body;
    
    switch (status) {
      case 'confirmed':
        title = 'Pedido Confirmado! 🎉';
        body = 'Seu pedido foi confirmado e está sendo preparado.';
        break;
      case 'preparing':
        title = 'Preparando seu Pedido 👨‍🍳';
        body = 'Seu pedido está sendo preparado com carinho.';
        break;
      case 'ready':
        title = 'Pedido Pronto! 🍽️';
        body = 'Seu pedido está pronto e será entregue em breve.';
        break;
      case 'delivered':
        title = 'Pedido Entregue! ✅';
        body = 'Seu pedido foi entregue. Bom apetite!';
        break;
      case 'cancelled':
        title = 'Pedido Cancelado 😔';
        body = 'Seu pedido foi cancelado. Entre em contato para mais informações.';
        break;
      default:
        title = 'Atualização do Pedido';
        body = 'O status do seu pedido foi atualizado.';
    }
    
    await sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      data: {'orderId': orderId, 'type': 'order_update'},
    );
  }
}

/// Handler para mensagens em background (deve estar no top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Mensagem recebida em background: ${message.notification?.title}');
}
