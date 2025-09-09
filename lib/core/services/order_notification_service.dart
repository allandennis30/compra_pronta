import 'package:get/get.dart';
import '../utils/logger.dart';
import 'notification_service.dart';
import 'audio_service.dart';
import 'background_service.dart';
import 'firebase_service.dart';
import '../../modules/vendedor/repositories/vendor_order_repository.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

/// Serviço integrador que conecta notificações com o repository de pedidos
class OrderNotificationService extends GetxService {
  static OrderNotificationService get to => Get.find();
  
  late final NotificationService _notificationService;
  late final AudioService _audioService;
  late final BackgroundService _backgroundService;
  late final FirebaseService _firebaseService;
  late final VendorOrderRepository _orderRepository;
  
  // Controle de estado
  final RxBool _isMonitoring = false.obs;
  final RxList<String> _lastProcessedOrders = <String>[].obs;
  
  bool get isMonitoring => _isMonitoring.value;
  List<String> get lastProcessedOrders => _lastProcessedOrders;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeServices();
  }
  
  /// Inicializa todos os serviços necessários
  Future<void> _initializeServices() async {
    try {
      // Obter instâncias dos serviços
      _notificationService = Get.find<NotificationService>();
      _audioService = Get.find<AudioService>();
      _backgroundService = Get.find<BackgroundService>();
      _firebaseService = Get.find<FirebaseService>();
      _orderRepository = Get.find<VendorOrderRepository>();
      
      AppLogger.info('✅ [ORDER_NOTIFICATION] Serviços inicializados');
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro ao inicializar serviços', e);
    }
  }
  
  /// Inicia o monitoramento completo de pedidos
  Future<void> startOrderMonitoring() async {
    try {
      if (_isMonitoring.value) {
        AppLogger.info('⚠️ [ORDER_NOTIFICATION] Monitoramento já está ativo');
        return;
      }
      
      // Inicializar notificações locais
      await _notificationService.onInit();
      
      // Subscrever aos tópicos do Firebase
      await _subscribeToFirebaseTopics();
      
      // Iniciar monitoramento em background
      await _backgroundService.startOrderMonitoring();
      
      _isMonitoring.value = true;
      
      AppLogger.info('🔄 [ORDER_NOTIFICATION] Monitoramento de pedidos iniciado');
      
      // Exibir notificação de confirmação
      await _notificationService.showNewOrderNotification(
        orderId: 'SYSTEM',
        clientName: 'Sistema',
        total: 0.0,
      );
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro ao iniciar monitoramento', e);
    }
  }
  
  /// Para o monitoramento de pedidos
  Future<void> stopOrderMonitoring() async {
    try {
      // Parar monitoramento em background
      await _backgroundService.stopOrderMonitoring();
      
      // Desinscrever dos tópicos do Firebase
      await _unsubscribeFromFirebaseTopics();
      
      _isMonitoring.value = false;
      
      AppLogger.info('⏹️ [ORDER_NOTIFICATION] Monitoramento de pedidos parado');
      
      // Exibir notificação de confirmação
      await _notificationService.showNewOrderNotification(
        orderId: 'SYSTEM',
        clientName: 'Sistema',
        total: 0.0,
      );
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro ao parar monitoramento', e);
    }
  }
  
  /// Subscreve aos tópicos do Firebase para o vendedor
  Future<void> _subscribeToFirebaseTopics() async {
    try {
      // Obter ID do vendedor atual
      final authController = Get.find<AuthController>();
      final vendorId = authController.currentUser?.id;
      
      if (vendorId == null) {
        AppLogger.error('❌ [ORDER_NOTIFICATION] Vendedor não autenticado para subscrição');
        return;
      }
      
      // Subscrever ao tópico específico do vendedor
      await _firebaseService.subscribeToTopic('vendor_orders_$vendorId');
      
      // Subscrever ao tópico geral de vendedores
      await _firebaseService.subscribeToTopic('vendor_notifications');
      
      AppLogger.info('✅ [ORDER_NOTIFICATION] Subscrito aos tópicos Firebase para vendedor: $vendorId');
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro ao subscrever tópicos', e);
    }
  }
  
  /// Desinscreve dos tópicos do Firebase
  Future<void> _unsubscribeFromFirebaseTopics() async {
    try {
      // Obter ID do vendedor atual
      final authController = Get.find<AuthController>();
      final vendorId = authController.currentUser?.id;
      
      if (vendorId == null) {
        AppLogger.warning('⚠️ [ORDER_NOTIFICATION] Vendedor não autenticado para desinscricão');
        return;
      }
      
      // Desinscrever dos tópicos
      await _firebaseService.unsubscribeFromTopic('vendor_orders_$vendorId');
      await _firebaseService.unsubscribeFromTopic('vendor_notifications');
      
      AppLogger.info('✅ [ORDER_NOTIFICATION] Desinscrito dos tópicos Firebase para vendedor: $vendorId');
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro ao desinscrever tópicos', e);
    }
  }
  
  /// Processa um novo pedido recebido
  Future<void> processNewOrder(OrderModel order) async {
    try {
      // Verificar se já foi processado
      if (_lastProcessedOrders.contains(order.id)) {
        AppLogger.info('⚠️ [ORDER_NOTIFICATION] Pedido já processado: ${order.id}');
        return;
      }
      
      AppLogger.info('🆕 [ORDER_NOTIFICATION] Processando novo pedido: ${order.id}');
      
      // Adicionar à lista de processados
      _lastProcessedOrders.add(order.id);
      
      // Limitar lista de processados (manter apenas os últimos 50)
      if (_lastProcessedOrders.length > 50) {
        _lastProcessedOrders.removeRange(0, _lastProcessedOrders.length - 50);
      }
      
      // Exibir notificação
      await _notificationService.showNewOrderNotification(
        orderId: order.id,
        clientName: order.clientName ?? 'Cliente',
        total: order.total,
      );
      
      // Reproduzir som
      await _audioService.playNewOrderSound();
      
      AppLogger.info('✅ [ORDER_NOTIFICATION] Novo pedido processado com sucesso');
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro ao processar novo pedido', e);
    }
  }
  
  /// Verifica manualmente por novos pedidos
  Future<void> checkForNewOrders() async {
    try {
      AppLogger.info('🔍 [ORDER_NOTIFICATION] Verificando novos pedidos manualmente...');
      
      // Executar verificação única em background
      await _backgroundService.checkNewOrdersOnce();
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro na verificação manual', e);
    }
  }
  
  /// Atualiza o status de um pedido e notifica se necessário
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Atualizar no repository
      await _orderRepository.updateOrderStatus(orderId, newStatus);
      
      // Exibir notificação de confirmação
      switch (newStatus) {
        case 'preparing':
          break;
        case 'delivering':
          break;
        case 'delivered':
          await _audioService.playConfirmationSound();
          break;
        case 'cancelled':
          await _audioService.playErrorSound();
          break;
        default:
      }
      
      await _notificationService.showNewOrderNotification(
        orderId: orderId,
        clientName: 'Cliente',
        total: 0.0,
      );
      
      AppLogger.info('✅ [ORDER_NOTIFICATION] Status do pedido atualizado: $orderId -> $newStatus');
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro ao atualizar status do pedido', e);
    }
  }
  
  /// Limpa a lista de pedidos processados
  void clearProcessedOrders() {
    _lastProcessedOrders.clear();
    _backgroundService.clearProcessedOrders();
    AppLogger.info('🧹 [ORDER_NOTIFICATION] Lista de pedidos processados limpa');
  }
  
  /// Testa o sistema de notificações
  Future<void> testNotificationSystem() async {
    try {
      AppLogger.info('🧪 [ORDER_NOTIFICATION] Testando sistema de notificações...');
      
      // Criar pedido de teste
      final testOrder = OrderModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'test_user',
        clientName: 'Cliente Teste',
        items: [],
        subtotal: 50.0,
        deliveryFee: 5.0,
        total: 55.0,
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
      
      // Processar pedido de teste
      await processNewOrder(testOrder);
      
      AppLogger.info('✅ [ORDER_NOTIFICATION] Teste concluído com sucesso');
      
    } catch (e) {
      AppLogger.error('❌ [ORDER_NOTIFICATION] Erro no teste do sistema', e);
    }
  }
  
  @override
  void onClose() {
    stopOrderMonitoring();
    super.onClose();
  }
}