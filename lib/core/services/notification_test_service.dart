import 'package:get/get.dart';
import 'notification_service.dart';
import 'audio_service.dart';
import 'firebase_service.dart';
import 'background_service.dart';
import 'order_notification_service.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../../utils/logger.dart';

/// Serviço para testar o funcionamento das notificações
class NotificationTestService extends GetxService {
  final NotificationService _notificationService = Get.find<NotificationService>();
  final AudioService _audioService = Get.find<AudioService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final BackgroundService _backgroundService = Get.find<BackgroundService>();
  final OrderNotificationService _orderNotificationService = Get.find<OrderNotificationService>();

  /// Testa todos os serviços de notificação
  Future<void> runAllTests() async {
    AppLogger.info('🧪 Iniciando testes de notificação...');
    
    try {
      // Teste 1: Inicialização dos serviços
      await _testServiceInitialization();
      
      // Teste 2: Notificação local
      await _testLocalNotification();
      
      // Teste 3: Áudio
      await _testAudioService();
      
      // Teste 4: Firebase Token
      await _testFirebaseToken();
      
      // Teste 5: Simulação de novo pedido
      await _testNewOrderSimulation();
      
      // Teste 6: Background service
      await _testBackgroundService();
      
      AppLogger.info('✅ Todos os testes concluídos com sucesso!');
    } catch (e) {
      AppLogger.error('❌ Erro durante os testes: $e');
    }
  }

  /// Teste 1: Verifica se todos os serviços foram inicializados
  Future<void> _testServiceInitialization() async {
    AppLogger.info('\n📋 Teste 1: Inicialização dos serviços');
    
    try {
      await _orderNotificationService.onInit();
      AppLogger.info('✅ OrderNotificationService inicializado');
      
      await _audioService.onInit();
      AppLogger.info('✅ AudioService inicializado');
      
      await _firebaseService.onInit();
      AppLogger.info('✅ FirebaseService inicializado');
      
      await _backgroundService.onInit();
      AppLogger.info('✅ BackgroundService inicializado');
      
    } catch (e) {
      AppLogger.error('❌ Erro na inicialização: $e');
      rethrow;
    }
  }

  /// Teste 2: Testa notificação local
  Future<void> _testLocalNotification() async {
    AppLogger.info('\n🔔 Teste 2: Notificação local');
    
    try {
      await _notificationService.showNewOrderNotification(
        orderId: 'TEST_001',
        clientName: 'Cliente Teste',
        total: 99.99,
      );
      AppLogger.info('✅ Notificação local enviada');
      
      // Aguardar um pouco para a notificação aparecer
      await Future.delayed(Duration(seconds: 2));
      
    } catch (e) {
      AppLogger.error('❌ Erro na notificação local: $e');
      rethrow;
    }
  }

  /// Teste 3: Testa serviço de áudio
  Future<void> _testAudioService() async {
    AppLogger.info('\n🔊 Teste 3: Serviço de áudio');
    
    try {
      await _audioService.playNewOrderSound();
      AppLogger.info('✅ Som de novo pedido reproduzido');
      
      // Aguardar o som terminar
      await Future.delayed(Duration(seconds: 3));
      
    } catch (e) {
      AppLogger.error('❌ Erro no serviço de áudio: $e');
      // Não relançar erro pois áudio pode falhar em emuladores
    }
  }

  /// Teste 4: Testa token do Firebase
  Future<void> _testFirebaseToken() async {
    AppLogger.info('\n🔥 Teste 4: Token do Firebase');
    
    try {
      final token = await _notificationService.getFCMToken();
      if (token != null && token.isNotEmpty) {
        AppLogger.info('✅ Token FCM obtido: ${token.substring(0, 20)}...');
      } else {
        AppLogger.warning('⚠️ Token FCM não disponível (normal em emuladores)');
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao obter token FCM: $e');
      // Não relançar erro pois pode falhar em emuladores
    }
  }

  /// Teste 5: Simula processamento de novo pedido
  Future<void> _testNewOrderSimulation() async {
    AppLogger.info('\n📦 Teste 5: Simulação de novo pedido');
    
    try {
      // Criar um pedido de teste
      final testOrder = OrderModel(
        id: 'TEST_ORDER_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'test_user_123',
        items: [],
        subtotal: 85.50,
        deliveryFee: 8.50,
        total: 94.00,
        status: 'pending',
        createdAt: DateTime.now(),
        deliveryAddress: AddressModel(
          street: 'Rua de Teste',
          number: 123,
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01234-567',
        ),
      );
      
      await _orderNotificationService.processNewOrder(testOrder);
      AppLogger.info('✅ Novo pedido processado com sucesso');
      
    } catch (e) {
      AppLogger.error('❌ Erro na simulação de novo pedido: $e');
      rethrow;
    }
  }

  /// Teste 6: Testa serviço de background
  Future<void> _testBackgroundService() async {
    AppLogger.info('\n⏰ Teste 6: Serviço de background');
    
    try {
      await _backgroundService.startOrderMonitoring();
      AppLogger.info('✅ Monitoramento em background iniciado');
      
      // Aguardar um ciclo de verificação
      await Future.delayed(Duration(seconds: 5));
      
      await _backgroundService.stopOrderMonitoring();
      AppLogger.info('✅ Monitoramento em background parado');
      
    } catch (e) {
      AppLogger.error('❌ Erro no serviço de background: $e');
      rethrow;
    }
  }

  /// Teste rápido apenas de notificação
  Future<void> testQuickNotification() async {
    AppLogger.info('🚀 Teste rápido de notificação');
    
    try {
      await _notificationService.showNewOrderNotification(
        orderId: 'QUICK_TEST',
        clientName: 'Teste Rápido',
        total: 50.00,
      );
      
      await _audioService.playNewOrderSound();
      
      AppLogger.info('✅ Teste rápido concluído');
    } catch (e) {
      AppLogger.error('❌ Erro no teste rápido: $e');
    }
  }

  /// Limpa todas as notificações
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      AppLogger.info('🧹 Todas as notificações foram limpas');
    } catch (e) {
      AppLogger.error('❌ Erro ao limpar notificações: $e');
    }
  }
}