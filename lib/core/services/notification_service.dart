import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// Serviço responsável por gerenciar notificações locais e push
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Canal de notificação para pedidos
  static const String _orderChannelId = 'order_notifications';
  static const String _orderChannelName = 'Novos Pedidos';
  static const String _orderChannelDescription = 'Notificações de novos pedidos recebidos';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
    await _requestPermissions();
    await _setupFirebaseMessaging();
  }
  
  /// Inicializa as notificações locais
  Future<void> _initializeNotifications() async {
    try {
      // Configurações para Android
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      
      // Configurações para iOS
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Criar canal de notificação para Android
      await _createNotificationChannel();
      
      AppLogger.info('✅ [NOTIFICATION] Notificações locais inicializadas');
    } catch (e) {
      AppLogger.error('❌ [NOTIFICATION] Erro ao inicializar notificações locais', e);
    }
  }
  
  /// Cria canal de notificação para Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _orderChannelId,
      _orderChannelName,
      description: _orderChannelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Solicita permissões necessárias
  Future<void> _requestPermissions() async {
    try {
      // Solicitar permissão para notificações
      final notificationStatus = await Permission.notification.request();
      
      if (notificationStatus.isGranted) {
        AppLogger.info('✅ [NOTIFICATION] Permissão de notificação concedida');
      } else {
        AppLogger.warning('⚠️ [NOTIFICATION] Permissão de notificação negada');
      }
      
      // Solicitar permissões do Firebase
      final firebaseSettings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (firebaseSettings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('✅ [NOTIFICATION] Permissões Firebase concedidas');
      } else {
        AppLogger.warning('⚠️ [NOTIFICATION] Permissões Firebase negadas');
      }
    } catch (e) {
      AppLogger.error('❌ [NOTIFICATION] Erro ao solicitar permissões', e);
    }
  }
  
  /// Configura Firebase Cloud Messaging
  Future<void> _setupFirebaseMessaging() async {
    try {
      // Obter token FCM
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        AppLogger.info('✅ [NOTIFICATION] Token FCM obtido: ${token.substring(0, 20)}...');
        // TODO: Enviar token para o backend
      }
      
      // Configurar handlers para mensagens
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // Verificar se o app foi aberto por uma notificação
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
      
      AppLogger.info('✅ [NOTIFICATION] Firebase Messaging configurado');
    } catch (e) {
      AppLogger.error('❌ [NOTIFICATION] Erro ao configurar Firebase Messaging', e);
    }
  }
  
  /// Manipula mensagens recebidas em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('📱 [NOTIFICATION] Mensagem recebida em foreground: ${message.notification?.title}');
    
    if (message.data['type'] == 'new_order') {
      _showNewOrderNotification(
        title: message.notification?.title ?? 'Novo Pedido',
        body: message.notification?.body ?? 'Você recebeu um novo pedido',
        orderId: message.data['order_id'],
      );
    }
  }
  
  /// Manipula quando o app é aberto por uma notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('🔔 [NOTIFICATION] App aberto por notificação: ${message.notification?.title}');
    
    if (message.data['type'] == 'new_order' && message.data['order_id'] != null) {
      // Navegar para a tela de detalhes do pedido
      Get.toNamed('/vendor/order-detail', arguments: {'orderId': message.data['order_id']});
    }
  }
  
  /// Manipula quando uma notificação local é tocada
  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info('👆 [NOTIFICATION] Notificação local tocada: ${response.payload}');
    
    if (response.payload != null) {
      final data = response.payload!.split('|');
      if (data.length >= 2 && data[0] == 'new_order') {
        Get.toNamed('/vendor/order-detail', arguments: {'orderId': data[1]});
      }
    }
  }
  
  /// Exibe notificação de novo pedido
  Future<void> _showNewOrderNotification({
    required String title,
    required String body,
    String? orderId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _orderChannelId,
        _orderChannelName,
        channelDescription: _orderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/launcher_icon',
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: orderId != null ? 'new_order|$orderId' : null,
      );
      
      AppLogger.info('✅ [NOTIFICATION] Notificação de novo pedido exibida');
    } catch (e) {
      AppLogger.error('❌ [NOTIFICATION] Erro ao exibir notificação', e);
    }
  }
  
  /// Exibe notificação local de novo pedido (para uso interno)
  Future<void> showNewOrderNotification({
    required String clientName,
    required double total,
    required String orderId,
  }) async {
    await _showNewOrderNotification(
      title: 'Novo Pedido Recebido! 🛒',
      body: 'Cliente: $clientName - Total: R\$ ${total.toStringAsFixed(2)}',
      orderId: orderId,
    );
  }
  
  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    AppLogger.info('🗑️ [NOTIFICATION] Todas as notificações canceladas');
  }
  
  /// Obtém o token FCM atual
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      AppLogger.error('❌ [NOTIFICATION] Erro ao obter token FCM', e);
      return null;
    }
  }
}