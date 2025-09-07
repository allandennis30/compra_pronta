import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';
import 'notification_service.dart';
import 'audio_service.dart';

/// Serviço responsável por configurar e gerenciar o Firebase
class FirebaseService extends GetxService {
  static FirebaseService get to => Get.find();
  
  FirebaseMessaging? _messaging;
  String? _fcmToken;
  
  String? get fcmToken => _fcmToken;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeFirebase();
  }
  
  /// Inicializa o Firebase Core e Messaging
  Future<void> _initializeFirebase() async {
    try {
      // Inicializar Firebase Core
      await Firebase.initializeApp();
      AppLogger.info('✅ [FIREBASE] Firebase Core inicializado');
      
      // Configurar Firebase Messaging
      await _setupFirebaseMessaging();
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao inicializar Firebase', e);
    }
  }
  
  /// Configura o Firebase Cloud Messaging
  Future<void> _setupFirebaseMessaging() async {
    try {
      _messaging = FirebaseMessaging.instance;
      
      // Solicitar permissões de notificação
      await _requestNotificationPermissions();
      
      // Obter token FCM
      await _getFCMToken();
      
      // Configurar handlers de mensagens
      await _setupMessageHandlers();
      
      AppLogger.info('✅ [FIREBASE] Firebase Messaging configurado');
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao configurar Firebase Messaging', e);
    }
  }
  
  /// Solicita permissões de notificação
  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('✅ [FIREBASE] Permissões de notificação concedidas');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('⚠️ [FIREBASE] Permissões provisórias concedidas');
      } else {
        AppLogger.warning('❌ [FIREBASE] Permissões de notificação negadas');
      }
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao solicitar permissões', e);
    }
  }
  
  /// Obtém o token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging!.getToken();
      
      if (_fcmToken != null) {
        AppLogger.info('📱 [FIREBASE] Token FCM obtido: ${_fcmToken!.substring(0, 20)}...');
        
        // TODO: Enviar token para o servidor
        await _sendTokenToServer(_fcmToken!);
      }
      
      // Escutar mudanças no token
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        AppLogger.info('🔄 [FIREBASE] Token FCM atualizado');
        _sendTokenToServer(newToken);
      });
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao obter token FCM', e);
    }
  }
  
  /// Envia o token FCM para o servidor
  Future<void> _sendTokenToServer(String token) async {
    try {
      // TODO: Implementar envio do token para o backend
      // Exemplo:
      // final apiService = Get.find<ApiService>();
      // await apiService.post('/user/fcm-token', {'token': token});
      
      AppLogger.info('📤 [FIREBASE] Token enviado para o servidor');
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao enviar token para servidor', e);
    }
  }
  
  /// Configura os handlers de mensagens
  Future<void> _setupMessageHandlers() async {
    try {
      // Handler para mensagens em foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handler para quando o app é aberto via notificação
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // Handler para mensagens em background
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
      // Verificar se o app foi aberto via notificação
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
      
      AppLogger.info('✅ [FIREBASE] Handlers de mensagens configurados');
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao configurar handlers', e);
    }
  }
  
  /// Manipula mensagens recebidas em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      AppLogger.info('📨 [FIREBASE] Mensagem recebida em foreground: ${message.messageId}');
      
      // Processar mensagem de novo pedido
      if (message.data['type'] == 'new_order') {
        _handleNewOrderMessage(message);
      }
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao processar mensagem foreground', e);
    }
  }
  
  /// Manipula quando o app é aberto via notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    try {
      AppLogger.info('📱 [FIREBASE] App aberto via notificação: ${message.messageId}');
      
      // Navegar para a tela apropriada baseado no tipo da mensagem
      if (message.data['type'] == 'new_order') {
        final orderId = message.data['order_id'];
        if (orderId != null) {
          // TODO: Navegar para detalhes do pedido
          // Get.toNamed('/order-details', arguments: orderId);
        }
      }
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao processar abertura via notificação', e);
    }
  }
  
  /// Manipula mensagem de novo pedido
  void _handleNewOrderMessage(RemoteMessage message) {
    try {
      final orderId = message.data['order_id'];
      final clientName = message.data['client_name'] ?? 'Cliente';
      final total = double.tryParse(message.data['total'] ?? '0') ?? 0.0;
      
      AppLogger.info('🆕 [FIREBASE] Novo pedido recebido: $orderId');
      
      // Exibir notificação local
      final notificationService = Get.find<NotificationService>();
      notificationService.showNewOrderNotification(
        orderId: orderId,
        clientName: clientName,
        total: total,
      );
      
      // Reproduzir som
      final audioService = Get.find<AudioService>();
      audioService.playNewOrderSound();
      
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao processar novo pedido', e);
    }
  }
  
  /// Subscreve a um tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging!.subscribeToTopic(topic);
      AppLogger.info('✅ [FIREBASE] Subscrito ao tópico: $topic');
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao subscrever ao tópico $topic', e);
    }
  }
  
  /// Desinscreve de um tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      AppLogger.info('✅ [FIREBASE] Desinscrito do tópico: $topic');
    } catch (e) {
      AppLogger.error('❌ [FIREBASE] Erro ao desinscrever do tópico $topic', e);
    }
  }
}

/// Handler para mensagens em background (função top-level)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  try {
    AppLogger.info('📨 [FIREBASE] Mensagem recebida em background: ${message.messageId}');
    
    // Processar mensagem de novo pedido em background
    if (message.data['type'] == 'new_order') {
      // Inicializar serviços necessários
      await Firebase.initializeApp();
      
      // TODO: Processar novo pedido em background
      // Pode incluir salvar no cache local, etc.
    }
    
  } catch (e) {
    AppLogger.error('❌ [FIREBASE] Erro ao processar mensagem background', e);
  }
}