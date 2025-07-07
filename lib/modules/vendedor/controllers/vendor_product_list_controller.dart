import 'package:get/get.dart';
import '../../cliente/models/product_model.dart';
import '../repositories/vendedor_product_repository.dart';

class VendorProductListController extends GetxController {
  final VendedorProductRepository _repository;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  VendorProductListController({required VendedorProductRepository repository})
      : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final productList = await _repository.getAll();
      products.assignAll(productList);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erro ao carregar produtos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;

      final success = await _repository.delete(productId);
      if (success) {
        products.removeWhere((product) => product.id == productId);
        Get.snackbar(
          'Produto removido',
          'Produto removido com sucesso',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Erro',
          'Não foi possível remover o produto',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao remover produto: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleProductAvailability(ProductModel product) async {
    try {
      final updatedProduct = product.copyWith(
        isAvailable: !product.isAvailable,
      );

      await _repository.update(updatedProduct);

      final index = products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        products[index] = updatedProduct;
      }

      Get.snackbar(
        'Produto atualizado',
        'Disponibilidade atualizada com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar disponibilidade: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
