import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../../auth/controllers/auth_controller.dart';
import '../repositories/delivery_repository.dart';
import '../../../core/models/user_model.dart';

class DeliveryController extends GetxController {
  final DeliveryRepository _deliveryRepository = DeliveryRepository();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isDeliveryUser = false.obs;
  final RxList<Map<String, dynamic>> deliveryStores =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> deliveryOrders =
      <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> deliveryStats =
      Rx<Map<String, dynamic>?>(null);

  // Variáveis de paginação
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasNextPage = true.obs;
  final RxString currentStoreFilter = ''.obs;
  final RxString currentStatusFilter = ''.obs;
  static const int itemsPerPage = 20;

  @override
  void onInit() {
    super.onInit();
    _checkIfDeliveryUser();

    // Escutar mudanças no currentUser do AuthController
    debounce(_authController.currentUserRx, (UserModel? updatedUser) {
      if (updatedUser != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkIfDeliveryUser();
        });
      }
    }, time: const Duration(milliseconds: 300));
  }

  /// Verificar se o usuário é entregador
  void _checkIfDeliveryUser() {
    final user = _authController.currentUser;
    if (user != null) {
      final wasDeliveryUser = isDeliveryUser.value;
      isDeliveryUser.value = user.isEntregador ?? false;

      // Log para debug
      print('🔍 [DELIVERY_CONTROLLER] Verificando status entregador:');
      print('   - isEntregador: ${user.isEntregador}');
      print('   - isDeliveryUser: ${isDeliveryUser.value}');

      if (isDeliveryUser.value && !wasDeliveryUser) {
        // Usuário se tornou entregador, carregar dados após o build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadDeliveryStores();
          loadDeliveryOrders();
        });
      }
    }
  }

  /// Força a verificação do status de entregador (útil para debug)
  Future<void> forceCheckDeliveryStatus() async {
    await _authController.reloadCurrentUser();
    _checkIfDeliveryUser();
  }

  /// Registrar usuário como entregador via QR Code
  Future<void> registerAsDeliveryWithQR() async {
    try {
      isLoading.value = true;

      // Escanear QR Code
      final result = await BarcodeScanner.scan();

      if (result.type == ResultType.Cancelled) {
        Get.snackbar('Info', 'Escaneamento cancelado',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final qrData = result.rawContent;
      if (qrData.isEmpty) {
        Get.snackbar('Erro', 'QR Code inválido',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      // Extrair sellerId do QR Code
      // Formato esperado: "delivery_register:{sellerId}"
      if (!qrData.startsWith('delivery_register:')) {
        Get.snackbar('Erro', 'QR Code não é válido para registro de entregador',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      final sellerId = qrData.replaceFirst('delivery_register:', '');
      if (sellerId.isEmpty) {
        Get.snackbar('Erro', 'ID do vendedor não encontrado no QR Code',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      // Registrar como entregador
      await _deliveryRepository.registerAsDelivery(sellerId);

      // Aguardar um pouco para garantir que o backend processou a atualização
      await Future.delayed(const Duration(milliseconds: 500));

      // Recarregar dados do usuário
      await _authController.reloadCurrentUser();

      // Aguardar mais um pouco e forçar verificação do status
      await Future.delayed(const Duration(milliseconds: 300));

      // Forçar verificação do status de entregador
      await forceCheckDeliveryStatus();

      // Carregar dados de entrega
      await loadDeliveryStores();

      Get.snackbar('Sucesso', 'Registrado como entregador com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao registrar como entregador: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Carregar lojas onde o usuário é entregador
  Future<void> loadDeliveryStores() async {
    try {
      isLoading.value = true;
      final stores = await _deliveryRepository.getDeliveryStores();
      deliveryStores.value = stores;
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar lojas: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Carregar pedidos para entrega (primeira página)
  Future<void> loadDeliveryOrders(
      {String? storeId, String? status, bool refresh = false}) async {
    try {
      isLoading.value = true;

      // Resetar paginação se for refresh ou novos filtros
      if (refresh ||
          storeId != currentStoreFilter.value ||
          status != currentStatusFilter.value) {
        currentPage.value = 1;
        deliveryOrders.clear();
      }

      // Atualizar filtros atuais
      currentStoreFilter.value = storeId ?? '';
      currentStatusFilter.value = status ?? '';

      // Debug: verificar parâmetros
      print('🔍 [DELIVERY_CONTROLLER] Carregando pedidos de entrega:');
      print('   - storeId: $storeId');
      print('   - status: $status');
      print('   - página: ${currentPage.value}');
      print('   - isDeliveryUser: ${isDeliveryUser.value}');

      final result = await _deliveryRepository.getDeliveryOrders(
        storeId: storeId,
        status: status,
        page: currentPage.value,
        limit: itemsPerPage,
      );

      final orders = List<Map<String, dynamic>>.from(result['orders'] ?? []);

      // Atualizar informações de paginação
      currentPage.value = result['currentPage'] ?? 1;
      totalPages.value = result['totalPages'] ?? 1;
      hasNextPage.value = result['hasNextPage'] ?? false;

      // Debug: verificar resultado
      print('   - Pedidos carregados: ${orders.length}');
      print('   - Página atual: ${currentPage.value}');
      print('   - Total de páginas: ${totalPages.value}');
      print('   - Tem próxima página: ${hasNextPage.value}');
      if (orders.isNotEmpty) {
        print('   - Primeiro pedido: ${orders.first}');
      }

      if (refresh || currentPage.value == 1) {
        deliveryOrders.value = orders;
      } else {
        deliveryOrders.addAll(orders);
      }
    } catch (e) {
      print('❌ [DELIVERY_CONTROLLER] Erro ao carregar pedidos: $e');
      Get.snackbar('Erro', 'Erro ao carregar pedidos: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Carregar mais pedidos (próxima página)
  Future<void> loadMoreDeliveryOrders() async {
    if (isLoadingMore.value || !hasNextPage.value) return;

    try {
      isLoadingMore.value = true;

      final nextPage = currentPage.value + 1;

      print(
          '🔍 [DELIVERY_CONTROLLER] Carregando mais pedidos - página $nextPage');

      final result = await _deliveryRepository.getDeliveryOrders(
        storeId:
            currentStoreFilter.value.isEmpty ? null : currentStoreFilter.value,
        status: currentStatusFilter.value.isEmpty
            ? null
            : currentStatusFilter.value,
        page: nextPage,
        limit: itemsPerPage,
      );

      final orders = List<Map<String, dynamic>>.from(result['orders'] ?? []);

      // Atualizar informações de paginação
      currentPage.value = result['currentPage'] ?? nextPage;
      totalPages.value = result['totalPages'] ?? 1;
      hasNextPage.value = result['hasNextPage'] ?? false;

      print('   - Novos pedidos carregados: ${orders.length}');
      print('   - Página atual: ${currentPage.value}');
      print('   - Tem próxima página: ${hasNextPage.value}');

      // Adicionar novos pedidos à lista existente
      deliveryOrders.addAll(orders);
    } catch (e) {
      print('❌ [DELIVERY_CONTROLLER] Erro ao carregar mais pedidos: $e');
      Get.snackbar('Erro', 'Erro ao carregar mais pedidos: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Confirmar entrega via QR Code
  Future<void> confirmDeliveryWithQR(String orderId) async {
    try {
      isLoading.value = true;

      // Escanear QR Code de confirmação
      final result = await BarcodeScanner.scan();

      if (result.type == ResultType.Cancelled) {
        Get.snackbar('Info', 'Escaneamento cancelado',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final qrData = result.rawContent;
      if (qrData.isEmpty) {
        Get.snackbar('Erro', 'QR Code inválido',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      // Extrair código de confirmação do QR Code
      // Formato esperado: "delivery_confirm:{orderId}:{confirmationCode}"
      if (!qrData.startsWith('delivery_confirm:')) {
        Get.snackbar('Erro', 'QR Code não é válido para confirmação de entrega',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      final parts = qrData.split(':');
      if (parts.length != 3) {
        Get.snackbar('Erro', 'Formato do QR Code inválido',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      final qrOrderId = parts[1];
      final confirmationCode = parts[2];

      if (qrOrderId != orderId) {
        Get.snackbar('Erro', 'QR Code não corresponde ao pedido selecionado',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      // Confirmar entrega
      await _deliveryRepository.confirmDelivery(orderId, confirmationCode);

      // Recarregar pedidos
      await loadDeliveryOrders();

      Get.snackbar('Sucesso', 'Entrega confirmada com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao confirmar entrega: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualizar status do pedido
  Future<void> updateOrderStatus(String orderId, String status,
      {String? notes}) async {
    try {
      isLoading.value = true;
      await _deliveryRepository.updateOrderStatus(orderId, status,
          notes: notes);

      // Recarregar pedidos
      await loadDeliveryOrders();

      Get.snackbar('Sucesso', 'Status do pedido atualizado!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao atualizar status: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Registrar como entregador
  Future<void> registerAsDelivery(String sellerId) async {
    try {
      isLoading.value = true;
      await _deliveryRepository.registerAsDelivery(sellerId);

      // Aguardar um pouco para garantir que o backend processou a atualização
      await Future.delayed(const Duration(milliseconds: 500));

      // Recarregar dados do usuário
      await _authController.reloadCurrentUser();

      // Aguardar mais um pouco e forçar verificação do status
      await Future.delayed(const Duration(milliseconds: 300));

      // Forçar verificação do status de entregador
      await forceCheckDeliveryStatus();
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Confirmar entrega
  Future<void> confirmDelivery(String orderId, String confirmationCode) async {
    try {
      isLoading.value = true;
      await _deliveryRepository.confirmDelivery(orderId, confirmationCode);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Carregar estatísticas de entrega
  Future<void> loadDeliveryStats({String? dateFrom, String? dateTo}) async {
    try {
      isLoading.value = true;
      final stats = await _deliveryRepository.getDeliveryStats(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      deliveryStats.value = stats;
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar estatísticas: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtrar pedidos por status
  List<Map<String, dynamic>> getOrdersByStatus(String status) {
    return deliveryOrders.where((order) => order['status'] == status).toList();
  }

  /// Obter pedidos pendentes
  List<Map<String, dynamic>> get pendingOrders => getOrdersByStatus('pending');

  /// Obter pedidos em andamento
  List<Map<String, dynamic>> get inProgressOrders =>
      getOrdersByStatus('in_progress');

  /// Obter pedidos entregues
  List<Map<String, dynamic>> get deliveredOrders =>
      getOrdersByStatus('delivered');

  /// Verificar se tem permissão de câmera
  Future<bool> checkCameraPermission() async {
    try {
      // O barcode_scan2 já gerencia as permissões automaticamente
      return true;
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao verificar permissão da câmera: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
  }
}
