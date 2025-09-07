import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../services/background_service.dart';
import '../services/order_notification_service.dart';
import '../services/notification_test_service.dart';
import '../../modules/vendedor/repositories/vendor_order_repository.dart';
import '../services/api_service.dart';

/// Binding para configurar todos os serviços de notificação
class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Serviços base
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    
    // Repository
    Get.lazyPut<VendorOrderRepository>(
      () => VendorOrderRepositoryImpl(),
      fenix: true,
    );
    
    // Serviços de notificação
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.lazyPut<AudioService>(() => AudioService(), fenix: true);
    Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    Get.lazyPut<BackgroundService>(() => BackgroundService(), fenix: true);
    
    // Serviço integrador
    Get.lazyPut<OrderNotificationService>(
      () => OrderNotificationService(),
      fenix: true,
    );
    
    // Serviço de teste
    Get.lazyPut<NotificationTestService>(
      () => NotificationTestService(),
      fenix: true,
    );
  }
  
  /// Inicializa todos os serviços de notificação
  static Future<void> initializeServices() async {
    try {
      // Garantir que todos os serviços estão registrados
      final notificationService = Get.find<NotificationService>();
      final audioService = Get.find<AudioService>();
      final firebaseService = Get.find<FirebaseService>();
      final backgroundService = Get.find<BackgroundService>();
      final orderNotificationService = Get.find<OrderNotificationService>();
      
      // Inicializar serviços na ordem correta
      await notificationService.onInit();
      await audioService.onInit();
      await firebaseService.onInit();
      await backgroundService.onInit();
      await orderNotificationService.onInit();
      
      print('✅ Todos os serviços de notificação foram inicializados');
      
    } catch (e) {
      print('❌ Erro ao inicializar serviços de notificação: $e');
      rethrow;
    }
  }
  
  /// Inicia o monitoramento de pedidos
  static Future<void> startOrderMonitoring() async {
    try {
      final orderNotificationService = Get.find<OrderNotificationService>();
      await orderNotificationService.startOrderMonitoring();
      
      print('🔄 Monitoramento de pedidos iniciado');
      
    } catch (e) {
      print('❌ Erro ao iniciar monitoramento: $e');
      rethrow;
    }
  }
  
  /// Para o monitoramento de pedidos
  static Future<void> stopOrderMonitoring() async {
    try {
      final orderNotificationService = Get.find<OrderNotificationService>();
      await orderNotificationService.stopOrderMonitoring();
      
      print('⏹️ Monitoramento de pedidos parado');
      
    } catch (e) {
      print('❌ Erro ao parar monitoramento: $e');
      rethrow;
    }
  }
  
  /// Executa testes de notificação
  static Future<void> runNotificationTests() async {
    try {
      final testService = Get.find<NotificationTestService>();
      await testService.runAllTests();
      
    } catch (e) {
      print('❌ Erro ao executar testes: $e');
      rethrow;
    }
  }
  
  /// Teste rápido de notificação
  static Future<void> quickNotificationTest() async {
    try {
      final testService = Get.find<NotificationTestService>();
      await testService.testQuickNotification();
      
    } catch (e) {
      print('❌ Erro no teste rápido: $e');
      rethrow;
    }
  }
}