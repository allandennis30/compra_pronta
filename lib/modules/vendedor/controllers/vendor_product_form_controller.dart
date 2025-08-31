import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../cliente/models/product_model.dart';
import '../repositories/vendedor_product_repository.dart';
import '../../../core/services/supabase_image_service.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:uuid/uuid.dart';

class VendorProductFormController extends GetxController {
  final VendedorProductRepository _repository;
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController pricePerKgController = TextEditingController();

  final RxString selectedCategory = ''.obs;
  final RxBool isAvailable = true.obs;
  final RxBool isSoldByWeight = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<File> productImage = Rxn<File>();
  final RxString imageUrl = ''.obs;
  final RxBool isEditing = false.obs;
  final Rxn<String> editingProductId = Rxn<String>();
  final RxBool isUploadingImage = false.obs;

  final ImagePicker _picker = ImagePicker();
  final categories = [
    'Frutas e Verduras',
    'Carnes',
    'Pães e Massas',
    'Bebidas',
    'Laticínios',
    'Limpeza',
    'Higiene',
    'Outros'
  ];

  VendorProductFormController({required VendedorProductRepository repository})
      : _repository = repository;

  @override
  void onInit() {
    super.onInit();

    // Verificar se estamos editando um produto existente
    if (Get.arguments != null && Get.arguments is ProductModel) {
      _loadProductForEditing(Get.arguments);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    barcodeController.dispose();
    pricePerKgController.dispose();
    super.onClose();
  }

  void _loadProductForEditing(ProductModel product) {
    isEditing.value = true;
    editingProductId.value = product.id;

    nameController.text = product.name ?? '';
    descriptionController.text = product.description ?? '';
    priceController.text = (product.price ?? 0.0).toString();
    stockController.text = (product.stock ?? 0).toString();
    barcodeController.text = product.barcode ?? '';
    selectedCategory.value = product.category ?? '';
    isAvailable.value = product.isAvailable ?? true;
    isSoldByWeight.value = product.isSoldByWeight ?? false;
    pricePerKgController.text = (product.pricePerKg ?? 0.0).toString();
    imageUrl.value = product.imageUrl ?? '';
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        productImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível selecionar a imagem',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void resetImage() {
    productImage.value = null;
    if (!isEditing.value) {
      imageUrl.value = '';
    }
  }

  void onCategorySelected(String category) {
    selectedCategory.value = category;
  }

  void toggleAvailability() {
    isAvailable.value = !isAvailable.value;
  }

  void toggleSoldByWeight() {
    isSoldByWeight.value = !isSoldByWeight.value;
    // Limpar campos quando alternar o tipo de venda
    if (isSoldByWeight.value) {
      stockController.clear();
    } else {
      pricePerKgController.clear();
    }
  }

  bool validateForm() {
    // Campos obrigatórios básicos
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedCategory.value.isEmpty ||
        barcodeController.text.isEmpty ||
        (productImage.value == null && imageUrl.value.isEmpty)) {
      errorMessage.value = 'Preencha todos os campos obrigatórios';
      hasError.value = true;
      return false;
    }

    // Validação condicional baseada no tipo de venda
    if (isSoldByWeight.value) {
      // Para produtos vendidos por peso
      if (pricePerKgController.text.isEmpty) {
        errorMessage.value =
            'Preço por kg é obrigatório para produtos vendidos por peso';
        hasError.value = true;
        return false;
      }
      if (double.tryParse(pricePerKgController.text) == null) {
        errorMessage.value = 'Preço por kg inválido';
        hasError.value = true;
        return false;
      }
    } else {
      // Para produtos vendidos por unidade
      if (priceController.text.isEmpty) {
        errorMessage.value = 'Preço é obrigatório';
        hasError.value = true;
        return false;
      }
      if (double.tryParse(priceController.text) == null) {
        errorMessage.value = 'Preço inválido';
        hasError.value = true;
        return false;
      }
      if (stockController.text.isEmpty) {
        errorMessage.value = 'Quantidade em estoque é obrigatória';
        hasError.value = true;
        return false;
      }
      if (int.tryParse(stockController.text) == null) {
        errorMessage.value = 'Quantidade em estoque inválida';
        hasError.value = true;
        return false;
      }
    }

    hasError.value = false;
    return true;
  }

  Future<void> scanBarcode() async {
    try {
      // O escaneamento real será implementado no componente da página
      // Este método será chamado após o escaneamento bem-sucedido
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível escanear o código de barras',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void setBarcode(String barcode) {
    barcodeController.text = barcode;
  }

  Future<bool> saveProduct() async {
    if (!validateForm()) {
      return false;
    }

    try {
      isLoading.value = true;
      hasError.value = false;

      // Processar a imagem primeiro, se houver uma nova
      String finalImageUrl = imageUrl.value;
      String? oldImageUrl; // Para deletar a imagem anterior

      if (productImage.value != null) {
        try {
          // Salvar URL da imagem antiga para deletar depois
          if (isEditing.value && imageUrl.value.isNotEmpty) {
            oldImageUrl = imageUrl.value;
          }

          isUploadingImage.value = true;

          // Upload direto para o Supabase
          final imageService = SupabaseImageService();
          final currentUser = _authController.currentUser;
          if (currentUser?.id != null) {
            // Se for edição, passar a URL da imagem antiga para remoção automática
            if (isEditing.value && imageUrl.value.isNotEmpty) {
              finalImageUrl = await imageService.uploadImage(
                  productImage.value!, currentUser!.id,
                  oldImageUrl: imageUrl.value);
            } else {
              finalImageUrl = await imageService.uploadImage(
                  productImage.value!, currentUser!.id);
            }
          } else {
            throw Exception('Usuário não autenticado');
          }
        } catch (e) {
          rethrow;
        } finally {
          isUploadingImage.value = false;
        }
      }

      final product = ProductModel(
        id: isEditing.value ? editingProductId.value! : const Uuid().v4(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: isSoldByWeight.value ? 0.0 : double.parse(priceController.text),
        imageUrl: finalImageUrl,
        category: selectedCategory.value,
        barcode: barcodeController.text.trim(),
        stock: isSoldByWeight.value ? 0 : int.parse(stockController.text),
        isAvailable: isAvailable.value,
        isSoldByWeight: isSoldByWeight.value,
        pricePerKg: isSoldByWeight.value
            ? double.parse(pricePerKgController.text)
            : null,
      );

      ProductModel? savedProduct; // Variável para armazenar o produto salvo

      if (isEditing.value) {
        savedProduct = await _repository.update(product);
      } else {
        savedProduct = await _repository.create(product);
      }

      // Aguardar um pouco antes de sair
      await Future.delayed(const Duration(milliseconds: 1500));

      // Retornar o produto atualizado para que a lista possa ser atualizada
      if (isEditing.value) {
        // Para edição, retornar o produto atualizado do backend
        Get.back(result: savedProduct);
      } else {
        // Para criação, retornar true (comportamento padrão)
        Get.back(result: true);
      }

      return true;
    } catch (e) {
      // Tratamento específico para diferentes tipos de erro
      String userMessage;

      // Erros específicos de upload de imagem
      if (e.toString().contains('Imagem muito grande')) {
        userMessage = 'Imagem muito grande. Máximo permitido: 5MB';
      } else if (e.toString().contains('Tipo de arquivo não suportado')) {
        userMessage =
            'Tipo de arquivo não suportado. Use JPG, PNG, GIF ou WebP';
      } else if (e.toString().contains('Sessão expirada')) {
        userMessage = 'Sessão expirada. Faça login novamente';
      } else if (e
          .toString()
          .contains('Serviço temporariamente indisponível')) {
        userMessage =
            'Serviço temporariamente indisponível. Tente novamente em alguns minutos.';
      } else if (e.toString().contains('Servidor retornou resposta vazia')) {
        userMessage =
            'Problema de conexão com o servidor. Verifique sua internet e tente novamente.';
      } else if (e.toString().contains('timeout')) {
        userMessage =
            'Tempo limite excedido. Verifique sua conexão e tente novamente.';
      } else if (e.toString().contains('Connection refused')) {
        userMessage = 'Servidor não está acessível. Verifique sua conexão';
      } else {
        userMessage = 'Erro ao salvar produto: ${e.toString()}';
      }

      errorMessage.value = userMessage;
      hasError.value = true;

      Get.snackbar(
        'Erro de Conexão',
        userMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Exclui o produto atual
  Future<void> deleteProduct() async {
    if (editingProductId.value == null) {
      Get.snackbar(
        'Erro',
        'Produto não pode ser excluído',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Mostrar diálogo de confirmação
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o produto "${nameController.text.trim()}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;
    hasError.value = false;

    try {
      final success = await _repository.delete(editingProductId.value!);

      if (success) {
        Get.snackbar(
          'Sucesso',
          'Produto excluído com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Voltar para a lista de produtos
        Get.back(result: true);
      } else {
        hasError.value = true;
        errorMessage.value = 'Produto não encontrado para exclusão';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erro ao excluir produto: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkExistingBarcode() async {
    final barcode = barcodeController.text.trim();
    if (barcode.isEmpty) return;

    try {
      final existingProduct = await _repository.getProductByBarcode(barcode);

      if (existingProduct != null &&
          (isEditing.value
              ? existingProduct.id != editingProductId.value
              : true)) {
        Get.snackbar(
          'Código de barras duplicado',
          'Este código de barras já está em uso por outro produto: ${existingProduct.name ?? 'Produto sem nome'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      // Ignorar erro, já que estamos apenas verificando
    }
  }
}
