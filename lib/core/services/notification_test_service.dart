import 'package:get/get.dart';
import 'notification_service.dart';
import 'audio_service.dart';
import 'firebase_service.dart';
import 'background_service.dart';
import 'order_notification_service.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

/// Serviço para testar o funcionamento das notificações
class NotificationTestService extends GetxService {
  final NotificationService _notificationService = Get.find<NotificationService>();
  final AudioService _audioService = Get.find<AudioService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final BackgroundService _backgroundService = Get.find<BackgroundService>();
  final OrderNotificationService _orderNotificationService = Get.find<OrderNotificationService>();

  /// Testa todos os serviços de notificação
  Future<void> runAllTests() async {
    print('🧪 Iniciando testes de notificação...');
    
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
      
      print('✅ Todos os testes concluídos com sucesso!');
    } catch (e) {
      print('❌ Erro durante os testes: $e');
    }
  }

  /// Teste 1: Verifica se todos os serviços foram inicializados
  Future<void> _testServiceInitialization() async {
    print('\n📋 Teste 1: Inicialização dos serviços');
    
    try {
      await _orderNotificationService.onInit();
      print('✅ OrderNotificationService inicializado');
      
      await _audioService.onInit();
      print('✅ AudioService inicializado');
      
      await _firebaseService.onInit();
      print('✅ FirebaseService inicializado');
      
      await _backgroundService.onInit();
      print('✅ BackgroundService inicializado');
      
    } catch (e) {
      print('❌ Erro na inicialização: $e');
      rethrow;
    }
  }

  /// Teste 2: Testa notificação local
  Future<void> _testLocalNotification() async {
    print('\n🔔 Teste 2: Notificação local');
    
    try {
      await _notificationService.showNewOrderNotification(
        orderId: 'TEST_001',
        clientName: 'Cliente Teste',
        total: 99.99,
      );
      print('✅ Notificação local enviada');
      
      // Aguardar um pouco para a notificação aparecer
      await Future.delayed(Duration(seconds: 2));
      
    } catch (e) {
      print('❌ Erro na notificação local: $e');
      rethrow;
    }
  }

  /// Teste 3: Testa serviço de áudio
  Future<void> _testAudioService() async {
    print('\n🔊 Teste 3: Serviço de áudio');
    
    try {
      await _audioService.playNewOrderSound();
      print('✅ Som de novo pedido reproduzido');
      
      // Aguardar o som terminar
      await Future.delayed(Duration(seconds: 3));
      
    } catch (e) {
      print('❌ Erro no serviço de áudio: $e');
      // Não relançar erro pois áudio pode falhar em emuladores
    }
  }

  /// Teste 4: Testa token do Firebase
  Future<void> _testFirebaseToken() async {
    print('\n🔥 Teste 4: Token do Firebase');
    
    try {
      final token = await _notificationService.getFCMToken();
      if (token != null && token.isNotEmpty) {
        print('✅ Token FCM obtido: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ Token FCM não disponível (normal em emuladores)');
      }
    } catch (e) {
      print('❌ Erro ao obter token FCM: $e');
      // Não relançar erro pois pode falhar em emuladores
    }
  }

  /// Teste 5: Simula processamento de novo pedido
  Future<void> _testNewOrderSimulation() async {
    print('\n📦 Teste 5: Simulação de novo pedido');
    
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
      print('✅ Novo pedido processado com sucesso');
      
    } catch (e) {
      print('❌ Erro na simulação de novo pedido: $e');
      rethrow;
    }
  }

  /// Teste 6: Testa serviço de background
  Future<void> _testBackgroundService() async {
    print('\n⏰ Teste 6: Serviço de background');
    
    try {
      await _backgroundService.startOrderMonitoring();
      print('✅ Monitoramento em background iniciado');
      
      // Aguardar um ciclo de verificação
      await Future.delayed(Duration(seconds: 5));
      
      await _backgroundService.stopOrderMonitoring();
      print('✅ Monitoramento em background parado');
      
    } catch (e) {
      print('❌ Erro no serviço de background: $e');
      rethrow;
    }
  }

  /// Teste rápido apenas de notificação
  Future<void> testQuickNotification() async {
    print('🚀 Teste rápido de notificação');
    
    try {
      await _notificationService.showNewOrderNotification(
        orderId: 'QUICK_TEST',
        clientName: 'Teste Rápido',
        total: 50.00,
      );
      
      await _audioService.playNewOrderSound();
      
      print('✅ Teste rápido concluído');
    } catch (e) {
      print('❌ Erro no teste rápido: $e');
    }
  }

  /// Limpa todas as notificações
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      print('🧹 Todas as notificações foram limpas');
    } catch (e) {
      print('❌ Erro ao limpar notificações: $e');
    }
  }
}