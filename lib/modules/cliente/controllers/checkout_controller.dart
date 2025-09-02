import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../controllers/cart_controller.dart';
import '../repositories/order_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/services/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../auth/controllers/auth_controller.dart';

class CheckoutController extends GetxController {
  final _storage = GetStorage();
  final _apiService = Get.find<ApiService>();
  final CartController cartController = Get.find<CartController>();

  // Form fields
  final RxString clientName = ''.obs;
  final RxString clientEmail = ''.obs;
  final RxString clientPhone = ''.obs;
  final RxString deliveryAddress = ''.obs;
  final RxString deliveryInstructions = ''.obs;
  final RxString paymentMethod = 'dinheiro'.obs;
  final RxString selectedPaymentMethod = 'dinheiro'.obs;

  // TextEditingControllers
  late TextEditingController clientNameController;
  late TextEditingController clientEmailController;
  late TextEditingController clientPhoneController;
  late TextEditingController deliveryAddressController;
  late TextEditingController deliveryInstructionsController;

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt currentStep = 0.obs;

  // Order data
  final RxList<OrderItemModel> orderItems = <OrderItemModel>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shipping = 0.0.obs;
  final RxDouble total = 0.0.obs;

  // Payment methods
  final List<Map<String, String>> paymentMethods = [
    {'value': 'dinheiro', 'label': 'Dinheiro'},
    {'value': 'pix', 'label': 'PIX'},
    {'value': 'cartao_credito', 'label': 'Cartão de Crédito'},
    {'value': 'cartao_debito', 'label': 'Cartão de Débito'},
  ];

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('🚀 CheckoutController.onInit() iniciado');
    _initializeControllers();
    AppLogger.info(
        '📋 Controllers inicializados, carregando dados do usuário...');
    _loadUserData();
    _prepareOrderData();
  }

  void _initializeControllers() {
    clientNameController = TextEditingController();
    clientEmailController = TextEditingController();
    clientPhoneController = TextEditingController();
    deliveryAddressController = TextEditingController();
    deliveryInstructionsController = TextEditingController();
  }

  void _loadUserData() async {
    AppLogger.info('🔄 Iniciando carregamento de dados do usuário...');

    // Aguardar um pouco para garantir que tudo esteja inicializado
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // Primeiro, tentar buscar dados da API
      try {
        AppLogger.info('📡 Tentando buscar dados da API /auth/profile...');
        final response = await _apiService.get('/auth/profile');

        if (response['success'] == true && response['user'] != null) {
          final userData = response['user'];
          AppLogger.info(
              '✅ Dados da API recebidos: ${userData['nome']} - ${userData['email']}');

          // Preencher dados do usuário
          clientName.value = userData['nome'] ?? '';
          clientEmail.value = userData['email'] ?? '';
          clientPhone.value = userData['telefone'] ?? '';

          // Montar endereço completo
          final endereco = userData['endereco'];
          if (endereco != null) {
            final addressParts = [
              endereco['street'] ?? endereco['rua'],
              endereco['number'] ?? endereco['numero'],
              endereco['neighborhood'] ?? endereco['bairro'],
              endereco['city'] ?? endereco['cidade'],
              endereco['state'] ?? endereco['estado'],
              endereco['zipCode'] ?? endereco['cep'],
              endereco['complement'] ?? endereco['complemento'],
            ].where((part) => part != null && part.isNotEmpty).toList();

            deliveryAddress.value = addressParts.join(', ');
          }

          // Atualizar controllers
          clientNameController.text = clientName.value;
          clientEmailController.text = clientEmail.value;
          clientPhoneController.text = clientPhone.value;
          deliveryAddressController.text = deliveryAddress.value;

          AppLogger.info('✅ Controllers atualizados com dados da API');
          AppLogger.info('📝 Nome: ${clientName.value}');
          AppLogger.info('📧 Email: ${clientEmail.value}');
          AppLogger.info('📞 Telefone: ${clientPhone.value}');
          AppLogger.info('📍 Endereço: ${deliveryAddress.value}');
          return;
        }
      } catch (apiError) {
        AppLogger.warning('❌ Erro ao buscar dados da API: $apiError');
        AppLogger.warning('🔄 Usando dados locais como fallback...');
      }

      // Fallback para dados locais
      AppLogger.info('📦 Tentando carregar dados do storage local...');
      final userData = _storage.read('user_data');
      if (userData != null) {
        AppLogger.info(
            '✅ Dados locais encontrados: ${userData['nome']} - ${userData['email']}');

        clientName.value = userData['nome'] ?? '';
        clientEmail.value = userData['email'] ?? '';
        clientPhone.value = userData['telefone'] ?? '';

        // Montar endereço completo
        final endereco = userData['endereco'];
        if (endereco != null) {
          final addressParts = [
            endereco['rua'],
            endereco['numero'],
            endereco['bairro'],
            endereco['cidade'],
            endereco['estado'],
            endereco['cep'],
            endereco['complemento'], // Adicionar complemento
          ].where((part) => part != null && part.isNotEmpty).toList();

          deliveryAddress.value = addressParts.join(', ');
        }

        // Atualizar controllers
        clientNameController.text = clientName.value;
        clientEmailController.text = clientEmail.value;
        clientPhoneController.text = clientPhone.value;
        deliveryAddressController.text = deliveryAddress.value;

        AppLogger.info('✅ Controllers atualizados com dados locais');
        AppLogger.info('📝 Nome: ${clientName.value}');
        AppLogger.info('📧 Email: ${clientEmail.value}');
        AppLogger.info('📞 Telefone: ${clientPhone.value}');
        AppLogger.info('📍 Endereço: ${deliveryAddress.value}');
      } else {
        AppLogger.warning('❌ Nenhum dado local encontrado');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar dados do usuário', e);
    }
  }

  void _prepareOrderData() {
    // Converter itens do carrinho para itens do pedido
    orderItems.value = cartController.items.map((cartItem) {
      return OrderItemModel(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        productImage: cartItem.product.imageUrl,
        price: cartItem.product.isSoldByWeight == true
            ? (cartItem.product.pricePerKg ?? 0.0)
            : (cartItem.product.price ?? 0.0),
        quantity: cartItem.quantity,
        total: cartItem.total,
        isSoldByWeight: cartItem.product.isSoldByWeight,
        pricePerKg: cartItem.product.pricePerKg,
      );
    }).toList();

    subtotal.value = cartController.subtotal.value;
    shipping.value = cartController.shipping.value;
    total.value = cartController.total.value;
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool canProceedToNextStep() {
    switch (currentStep.value) {
      case 0: // Dados pessoais
        return clientName.value.isNotEmpty &&
            clientEmail.value.isNotEmpty &&
            clientPhone.value.isNotEmpty &&
            deliveryAddress.value.isNotEmpty;
      case 1: // Método de pagamento
        return selectedPaymentMethod.value.isNotEmpty;
      case 2: // Revisão
        return true;
      default:
        return false;
    }
  }

  Future<void> submitOrder(BuildContext context) async {
    AppLogger.info('🚀 [CHECKOUT] Iniciando submissão do pedido...');

    if (!canProceedToNextStep()) {
      AppLogger.warning(
          '❌ [CHECKOUT] Validação falhou - campos obrigatórios não preenchidos');
      SnackBarUtils.showError(
          context, 'Por favor, preencha todos os campos obrigatórios');
      return;
    }

    AppLogger.info('✅ [CHECKOUT] Validação passou, iniciando submissão...');
    isSubmitting.value = true;

    try {
      // Log dos dados do cliente
      AppLogger.info('👤 [CHECKOUT] Dados do cliente:');
      AppLogger.info('   - Nome: ${clientName.value}');
      AppLogger.info('   - Email: ${clientEmail.value}');
      AppLogger.info('   - Telefone: ${clientPhone.value}');
      AppLogger.info('   - Endereço: ${deliveryAddress.value}');
      AppLogger.info('   - Instruções: ${deliveryInstructions.value}');
      AppLogger.info(
          '   - Método de pagamento: ${selectedPaymentMethod.value}');

      // Log dos itens do pedido
      AppLogger.info(
          '🛒 [CHECKOUT] Itens do pedido (${orderItems.length} itens):');
      for (int i = 0; i < orderItems.length; i++) {
        final item = orderItems[i];
        AppLogger.info(
            '   ${i + 1}. ${item.productName} - Qtd: ${item.quantity} - Preço: R\$ ${item.price} - Total: R\$ ${item.total}');
      }

      // Log dos valores
      AppLogger.info('💰 [CHECKOUT] Valores:');
      AppLogger.info('   - Subtotal: R\$ ${subtotal.value}');
      AppLogger.info('   - Frete: R\$ ${shipping.value}');
      AppLogger.info('   - Total: R\$ ${total.value}');

      // Verificar user_id
      final userId = _storage.read('user_id');
      AppLogger.info('🆔 [CHECKOUT] User ID do storage: $userId');

      // Se user_id não encontrado, tentar obter do usuário atual
      String? finalUserId = userId;
      if (finalUserId == null) {
        try {
          final authController = Get.find<AuthController>();
          final currentUser = authController.currentUser;
          if (currentUser != null) {
            finalUserId = currentUser.id;
            AppLogger.info(
                '🆔 [CHECKOUT] User ID obtido do AuthController: $finalUserId');
          } else {
            AppLogger.error(
                '❌ [CHECKOUT] Usuário não encontrado no AuthController');
          }
        } catch (e) {
          AppLogger.error(
              '❌ [CHECKOUT] Erro ao obter usuário do AuthController: $e');
        }
      }

      if (finalUserId == null) {
        AppLogger.error(
            '❌ [CHECKOUT] User ID não encontrado - abortando pedido');
        SnackBarUtils.showError(
            context, 'Erro: Usuário não identificado. Faça login novamente.');
        return;
      }

      final checkoutData = CheckoutData(
        clientId: finalUserId,
        clientName: clientName.value,
        clientEmail: clientEmail.value,
        clientPhone: clientPhone.value,
        deliveryAddress: deliveryAddress.value,
        deliveryInstructions: deliveryInstructions.value,
        paymentMethod: selectedPaymentMethod.value,
        items: orderItems,
        subtotal: subtotal.value,
        shipping: shipping.value,
        total: total.value,
      );

      AppLogger.info(
          '📦 [CHECKOUT] Dados do checkout preparados, enviando para API...');

      // Log do JSON que será enviado
      final jsonData = checkoutData.toJson();
      AppLogger.info('📄 [CHECKOUT] JSON do pedido: ${jsonEncode(jsonData)}');

      final response = await _apiService.post('/orders', jsonData);

      AppLogger.info('📡 [CHECKOUT] Resposta da API recebida:');
      AppLogger.info('   - Success: ${response['success']}');
      AppLogger.info('   - Message: ${response['message']}');
      AppLogger.info('   - Status Code: ${response['statusCode']}');

      if (response['success'] == true) {
        AppLogger.success('✅ [CHECKOUT] Pedido criado com sucesso!');

        // Log dos dados do pedido retornado
        if (response['order'] != null) {
          final order = response['order'];
          AppLogger.info('📋 [CHECKOUT] Dados do pedido criado:');
          AppLogger.info('   - ID: ${order['id']}');
          AppLogger.info('   - Status: ${order['status']}');
          AppLogger.info('   - Total: R\$ ${order['total']}');
        }

        // Limpar carrinho após sucesso
        AppLogger.info('🗑️ [CHECKOUT] Limpando carrinho...');
        cartController.clearCart();
        AppLogger.success('✅ [CHECKOUT] Carrinho limpo com sucesso');

        // Salvar pedido localmente como fallback
        try {
          final orderRepository = Get.find<OrderRepository>();
          AppLogger.info('✅ [CHECKOUT] Pedido criado com sucesso na API');
        } catch (e) {
          AppLogger.error('❌ [CHECKOUT] Erro ao salvar pedido localmente:', e);
        }

        // Navegar para página de sucesso
        AppLogger.info('🔄 [CHECKOUT] Navegando para página de sucesso...');
        Get.offAllNamed(Routes.clienteOrderSuccess);
      } else {
        AppLogger.error('❌ [CHECKOUT] Erro na criação do pedido:');
        AppLogger.error('   - Message: ${response['message']}');
        AppLogger.error('   - Status Code: ${response['statusCode']}');

        if (response['errors'] != null) {
          AppLogger.error('   - Errors: ${response['errors']}');
        }

        SnackBarUtils.showError(
            context, response['message'] ?? 'Erro ao processar pedido');
      }
    } catch (e) {
      AppLogger.error('💥 [CHECKOUT] Exceção durante submissão do pedido:', e);
      AppLogger.error('   - Tipo de erro: ${e.runtimeType}');
      AppLogger.error('   - Mensagem: ${e.toString()}');

      SnackBarUtils.showError(
          context, 'Erro ao processar pedido. Tente novamente.');
    } finally {
      AppLogger.info('🏁 [CHECKOUT] Finalizando submissão do pedido...');
      isSubmitting.value = false;
    }
  }

  String getPaymentMethodLabel(String value) {
    final method = paymentMethods.firstWhere(
      (method) => method['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return method['label']!;
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'delivering':
        return 'Em entrega';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'delivering':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void onClose() {
    clientNameController.dispose();
    clientEmailController.dispose();
    clientPhoneController.dispose();
    deliveryAddressController.dispose();
    deliveryInstructionsController.dispose();
    super.onClose();
  }
}
