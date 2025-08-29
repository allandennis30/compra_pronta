import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../cliente/models/product_model.dart';
import '../repositories/vendedor_product_repository.dart';
import '../../../core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class VendorProductFormController extends GetxController {
  final VendedorProductRepository _repository;
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

    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = product.price.toString();
    stockController.text = product.stock.toString();
    barcodeController.text = product.barcode;
    selectedCategory.value = product.category;
    isAvailable.value = product.isAvailable;
    isSoldByWeight.value = product.isSoldByWeight;
    pricePerKgController.text = product.pricePerKg?.toString() ?? '';
    imageUrl.value = product.imageUrl;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        productImage.value = File(pickedFile.path);
        imageUrl.value = '';
      }
    } catch (e) {
      AppLogger.error('Erro ao selecionar imagem', e);
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
      AppLogger.error('Erro ao escanear código de barras', e);
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
      if (productImage.value != null) {
        finalImageUrl = await _repository.saveProductImage(productImage.value!);
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

      if (isEditing.value) {
        await _repository.update(product);
        Get.snackbar(
          'Sucesso',
          'Produto atualizado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        await _repository.create(product);
        Get.snackbar(
          'Sucesso',
          'Produto cadastrado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      Get.back(result: true);
      return true;
    } catch (e) {
      AppLogger.error('Erro ao salvar produto', e);
      errorMessage.value = 'Erro ao salvar produto: ${e.toString()}';
      hasError.value = true;

      Get.snackbar(
        'Erro',
        'Erro ao salvar produto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      return false;
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
          'Este código de barras já está em uso por outro produto: ${existingProduct.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      // Ignorar erro, já que estamos apenas verificando
    }
  }
}
