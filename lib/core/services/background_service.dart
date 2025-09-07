import 'package:workmanager/workmanager.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';
import 'notification_service.dart';
import 'audio_service.dart';
import '../../modules/vendedor/repositories/vendor_order_repository.dart';
import '../models/order_model.dart';

/// Serviço responsável por executar tarefas em segundo plano
class BackgroundService extends GetxService {
  static BackgroundService get to => Get.find();
  
  // Identificadores das tarefas
  static const String _checkNewOrdersTask = 'checkNewOrdersTask';
  static const String _periodicOrderCheckTask = 'periodicOrderCheckTask';
  
  // Configurações
  static const Duration _checkInterval = Duration(minutes: 2);
  static const Duration _initialDelay = Duration(seconds: 30);
  
  // Controle de estado
  final RxBool _isMonitoring = false.obs;
  final RxList<String> _processedOrderIds = <String>[].obs;
  
  bool get isMonitoring => _isMonitoring.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeWorkManager();
  }
  
  /// Inicializa o WorkManager
  Future<void> _initializeWorkManager() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Definir como false em produção
      );
      
      AppLogger.info('✅ [BACKGROUND] WorkManager inicializado');
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro ao inicializar WorkManager', e);
    }
  }
  
  /// Inicia o monitoramento de novos pedidos
  Future<void> startOrderMonitoring() async {
    try {
      if (_isMonitoring.value) {
        AppLogger.info('⚠️ [BACKGROUND] Monitoramento já está ativo');
        return;
      }
      
      // Registrar tarefa periódica
      await Workmanager().registerPeriodicTask(
        _periodicOrderCheckTask,
        _checkNewOrdersTask,
        frequency: _checkInterval,
        initialDelay: _initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      
      _isMonitoring.value = true;
      AppLogger.info('🔄 [BACKGROUND] Monitoramento de pedidos iniciado');
      
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro ao iniciar monitoramento', e);
    }
  }
  
  /// Para o monitoramento de novos pedidos
  Future<void> stopOrderMonitoring() async {
    try {
      await Workmanager().cancelByUniqueName(_periodicOrderCheckTask);
      _isMonitoring.value = false;
      
      AppLogger.info('⏹️ [BACKGROUND] Monitoramento de pedidos parado');
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro ao parar monitoramento', e);
    }
  }
  
  /// Executa verificação única de novos pedidos
  Future<void> checkNewOrdersOnce() async {
    try {
      await Workmanager().registerOneOffTask(
        'oneTimeCheck_${DateTime.now().millisecondsSinceEpoch}',
        _checkNewOrdersTask,
        initialDelay: const Duration(seconds: 5),
      );
      
      AppLogger.info('🔍 [BACKGROUND] Verificação única de pedidos agendada');
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro ao agendar verificação única', e);
    }
  }
  
  /// Verifica se há novos pedidos (executado em background)
  static Future<void> _checkForNewOrders() async {
    try {
      AppLogger.info('🔍 [BACKGROUND] Verificando novos pedidos...');
      
      // Obter instância do repository
      final repository = Get.find<VendorOrderRepository>();
      
      // Buscar todos os pedidos do vendedor
      final allOrders = await repository.getVendorOrders();
      
      // Filtrar pedidos recentes (últimos 10 minutos)
      final now = DateTime.now();
      final tenMinutesAgo = now.subtract(const Duration(minutes: 10));
      
      final recentOrders = allOrders.where((order) {
        return order.createdAt != null && order.createdAt!.isAfter(tenMinutesAgo);
      }).toList();
      
      if (recentOrders.isNotEmpty) {
        AppLogger.info('📦 [BACKGROUND] ${recentOrders.length} pedidos encontrados');
        
        // Processar cada pedido novo
        for (final order in recentOrders) {
          await _processNewOrder(order);
        }
      } else {
        AppLogger.info('📭 [BACKGROUND] Nenhum pedido novo encontrado');
      }
      
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro ao verificar novos pedidos', e);
    }
  }
  
  /// Processa um novo pedido encontrado
  static Future<void> _processNewOrder(OrderModel order) async {
    try {
      // Verificar se já foi processado
      final backgroundService = Get.find<BackgroundService>();
      if (backgroundService._processedOrderIds.contains(order.id)) {
        return;
      }
      
      AppLogger.info('🆕 [BACKGROUND] Processando novo pedido: ${order.id}');
      
      // Marcar como processado
      backgroundService._processedOrderIds.add(order.id!);
      
      // Enviar notificação
      final notificationService = Get.find<NotificationService>();
      await notificationService.showNewOrderNotification(
        orderId: order.id,
        clientName: order.clientName ?? 'Cliente',
        total: order.total,
      );
      
      // Reproduzir som
      final audioService = Get.find<AudioService>();
      await audioService.playNewOrderSound();
      
      AppLogger.info('✅ [BACKGROUND] Novo pedido processado com sucesso');
      
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro ao processar novo pedido', e);
    }
  }
  
  /// Limpa a lista de pedidos processados (executar periodicamente)
  void clearProcessedOrders() {
    _processedOrderIds.clear();
    AppLogger.info('🧹 [BACKGROUND] Lista de pedidos processados limpa');
  }
  
  /// Cancela todas as tarefas em background
  Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      _isMonitoring.value = false;
      
      AppLogger.info('🚫 [BACKGROUND] Todas as tarefas canceladas');
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro ao cancelar tarefas', e);
    }
  }
  
  @override
  void onClose() {
    cancelAllTasks();
    super.onClose();
  }
}

/// Dispatcher para executar tarefas em background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AppLogger.info('🔄 [BACKGROUND] Executando tarefa: $task');
      
      switch (task) {
        case BackgroundService._checkNewOrdersTask:
          await BackgroundService._checkForNewOrders();
          break;
        default:
          AppLogger.warning('⚠️ [BACKGROUND] Tarefa desconhecida: $task');
      }
      
      return Future.value(true);
    } catch (e) {
      AppLogger.error('❌ [BACKGROUND] Erro na execução da tarefa $task', e);
      return Future.value(false);
    }
  });
}