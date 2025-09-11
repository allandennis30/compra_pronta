import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_product_form_controller.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/barcode_scanner.dart';
import '../../../models/vendor_category.dart';
import '../../../utils/logger.dart';

class VendorProductFormPage extends GetView<VendorProductFormController> {
  const VendorProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing.value
            ? 'Editar Produto'
            : 'Cadastrar Produto')),
        actions: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              FocusScope.of(context).unfocus();
              controller.saveProduct();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildForm();
    });
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
            return const SizedBox.shrink();
          }
          
          final isTablet = constraints.maxWidth > 600;
          final isDesktop = constraints.maxWidth > 900;
          final padding = isTablet ? 24.0 : 16.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna da esquerda - Imagem e informações básicas
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildProductName(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildBarcodeField(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Coluna da direita - Configurações e preços
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildSoldByWeightToggle(),
              const SizedBox(height: 16),
              Obx(
                () => controller.isSoldByWeight.value
                    ? _buildPricePerKgField()
                    : Column(
                        children: [
                          _buildPrice(),
                          const SizedBox(height: 16),
                          _buildStock(),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              _buildAvailabilityToggle(),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 16),
              Obx(() => controller.hasError.value
                  ? _buildErrorMessage()
                  : const SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImagePicker(),
        const SizedBox(height: 24),
        _buildProductName(),
        const SizedBox(height: 16),
        _buildDescription(),
        const SizedBox(height: 16),
        Obx(
          () => controller.isSoldByWeight.value
              ? const SizedBox() // Não mostrar preço e estoque para produtos por peso
              : Row(
                  children: [
                    Expanded(child: _buildPrice()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStock()),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _buildBarcodeField(),
        const SizedBox(height: 16),
        _buildCategoryDropdown(),
        const SizedBox(height: 16),
        _buildSoldByWeightToggle(),
        const SizedBox(height: 16),
        Obx(() => controller.isSoldByWeight.value
            ? _buildPricePerKgField()
            : const SizedBox()),
        const SizedBox(height: 16),
        _buildAvailabilityToggle(),
        const SizedBox(height: 24),
        _buildSaveButton(),
        const SizedBox(height: 16),
        Obx(() => controller.hasError.value
            ? _buildErrorMessage()
            : const SizedBox()),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(() => ImagePickerWidget(
          selectedImage: controller.productImage.value,
          imageUrl: controller.imageUrl.value,
          onPickImage: controller.pickImage,
          onReset: controller.resetImage,
        ));
  }

  Widget _buildProductName() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return TextFormField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'Nome do Produto',
            hintText: 'Ex: Arroz Integral 1kg',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.shopping_bag),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 16 : 12,
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLength: 100,
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        );
      },
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      controller: controller.descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrição',
        hintText: 'Descreva detalhes do produto...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      maxLength: 500,
    );
  }

  Widget _buildPrice() {
    return TextFormField(
      controller: controller.priceController,
      decoration: const InputDecoration(
        labelText: 'Preço (R\$)',
        hintText: 'Ex: 9.99',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildStock() {
    return TextFormField(
      controller: controller.stockController,
      decoration: const InputDecoration(
        labelText: 'Estoque',
        hintText: 'Ex: 50',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.inventory),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildBarcodeField() {
    return TextFormField(
      controller: controller.barcodeController,
      decoration: InputDecoration(
        labelText: 'Código de Barras',
        hintText: 'Ex: 7891234567890',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.qr_code),
        suffixIcon: IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: _openBarcodeScanner,
          tooltip: 'Escanear código de barras',
        ),
      ),
      keyboardType: TextInputType.number,
      onEditingComplete: controller.checkExistingBarcode,
    );
  }

  void _openBarcodeScanner() {
    Get.to(() => BarcodeScanner(
          onBarcodeDetected: (barcode) {
            controller.setBarcode(barcode);
            controller.checkExistingBarcode();
            // Retorna automaticamente para a tela de cadastro após reconhecimento
            Get.back();
          },
        ));
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      final isLoading = controller.isLoadingCategories.value;
      final categories = controller.categories;
      final selectedCategory = controller.selectedCategory.value;
      
      // Debug: Log para verificar estado das categorias
      print('🔍 [DROPDOWN_DEBUG] Categories: $categories');
      print('🔍 [DROPDOWN_DEBUG] Selected: "$selectedCategory"');
      print('🔍 [DROPDOWN_DEBUG] Contains selected: ${categories.contains(selectedCategory)}');
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Categoria',
              border: const OutlineInputBorder(),
              prefixIcon: isLoading 
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.category),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedCategory.isNotEmpty && controller.isCustomCategory(selectedCategory))
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditCategoryDialog(selectedCategory),
                      tooltip: 'Editar categoria',
                    ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _showCreateCategoryDialog,
                    tooltip: 'Criar nova categoria',
                  ),
                ],
              ),
            ),
            value: selectedCategory.isEmpty || !categories.contains(selectedCategory) ? null : selectedCategory,
            items: isLoading 
                ? []
                : categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (controller.isCustomCategory(category)) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
            onChanged: isLoading 
                ? null
                : (value) {
                    if (value != null) {
                      controller.onCategorySelected(value);
                    }
                  },
            hint: Text(isLoading ? 'Carregando categorias...' : 'Selecione uma categoria'),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Carregando suas categorias personalizadas...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSoldByWeightToggle() {
    return Obx(() => SwitchListTile(
          title: const Text('Vendido por peso'),
          subtitle: Text(
            controller.isSoldByWeight.value
                ? 'Cliente escolhe o peso desejado'
                : 'Produto vendido por unidade',
            style: TextStyle(
              color: controller.isSoldByWeight.value
                  ? Colors.blue.shade700
                  : Colors.grey,
            ),
          ),
          value: controller.isSoldByWeight.value,
          onChanged: (value) => controller.toggleSoldByWeight(),
          secondary: Icon(
            controller.isSoldByWeight.value ? Icons.scale : Icons.inventory_2,
            color: controller.isSoldByWeight.value ? Colors.blue : Colors.grey,
          ),
        ));
  }

  Widget _buildPricePerKgField() {
    return TextFormField(
      controller: controller.pricePerKgController,
      decoration: const InputDecoration(
        labelText: 'Preço por Kg (R\$)',
        hintText: 'Ex: 12.50',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.scale),
        suffixText: '/kg',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Obx(() => SwitchListTile(
          title: const Text('Disponível para venda'),
          subtitle: Text(
            controller.isAvailable.value
                ? 'Produto ativo no catálogo'
                : 'Produto inativo no catálogo',
            style: TextStyle(
              color: controller.isAvailable.value
                  ? Colors.green.shade700
                  : Colors.grey,
            ),
          ),
          value: controller.isAvailable.value,
          onChanged: (value) => controller.toggleAvailability(),
          secondary: Icon(
            controller.isAvailable.value
                ? Icons.visibility
                : Icons.visibility_off,
            color: controller.isAvailable.value ? Colors.green : Colors.grey,
          ),
        ));
  }

  Widget _buildSaveButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;

        return SizedBox(
          width: isDesktop ? 300 : double.infinity,
          height: isTablet ? 56 : 48,
          child: ElevatedButton(
            onPressed: () => controller.saveProduct(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: isTablet ? 24 : 20),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  controller.isEditing.value
                      ? 'Atualizar Produto'
                      : 'Cadastrar Produto',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showCreateCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Nova Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite o nome da nova categoria:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              onFieldSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _createCategory(categoryController.text.trim());
                }
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'A primeira letra será automaticamente maiúscula e erros de digitação serão corrigidos.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isCreatingCategory.value
                ? null
                : () {
                    final categoryName = categoryController.text.trim();
                    if (categoryName.isNotEmpty) {
                      _createCategory(categoryName);
                    }
                  },
            child: controller.isCreatingCategory.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Criar'),
          )),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(String currentCategoryName) {
    final TextEditingController categoryController = TextEditingController(text: currentCategoryName);
    final category = controller.getVendorCategoryByName(currentCategoryName);
    
    if (category == null) return;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Editar Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite o novo nome da categoria:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              onFieldSubmitted: (value) {
                if (value.trim().isNotEmpty && value.trim() != currentCategoryName) {
                  _editCategory(category, categoryController.text.trim());
                }
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'A primeira letra será automaticamente maiúscula e erros de digitação serão corrigidos.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _showDeleteCategoryConfirmation(category),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isCreatingCategory.value
                ? null
                : () {
                    final newCategoryName = categoryController.text.trim();
                    if (newCategoryName.isNotEmpty && newCategoryName != currentCategoryName) {
                      _editCategory(category, newCategoryName);
                    }
                  },
            child: controller.isCreatingCategory.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          )),
        ],
      ),
    );
  }

  void _showDeleteCategoryConfirmation(VendorCategory category) {
    Get.back(); // Fechar o diálogo de edição
    
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a categoria "${category.name}"?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _deleteCategory(category);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCategory(String categoryName) async {
    AppLogger.info('🔄 [UI_CREATE_CATEGORY] Iniciando criação de categoria na UI: "$categoryName"');
    
    // Fechar o teclado
    FocusScope.of(Get.context!).unfocus();
    AppLogger.info('⌨️ [UI_CREATE_CATEGORY] Teclado fechado');
    
    AppLogger.info('🔄 [UI_CREATE_CATEGORY] Chamando controller.createVendorCategory');
    final success = await controller.createVendorCategory(categoryName);
    AppLogger.info('📊 [UI_CREATE_CATEGORY] Resultado do controller: $success');
    
    // Fechar o diálogo apenas se a criação foi bem-sucedida
    if (success) {
      AppLogger.info('✅ [UI_CREATE_CATEGORY] Sucesso! Aguardando 1 segundo para exibir popup de sucesso');
      // Aguardar 1 segundo para o popup de sucesso ser exibido antes de fechar
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
      AppLogger.info('🔙 [UI_CREATE_CATEGORY] Get.back() executado após 1 segundo');
    } else {
      AppLogger.error('❌ [UI_CREATE_CATEGORY] Falha na criação - popup permanece aberto');
    }
  }

  Future<void> _editCategory(VendorCategory category, String newName) async {
    // Fechar o teclado
    FocusScope.of(Get.context!).unfocus();
    
    final success = await controller.updateVendorCategory(category, newName);
    
    // Fechar o diálogo apenas se a edição foi bem-sucedida
    if (success) {
      Get.back();
    }
  }

  Future<void> _deleteCategory(VendorCategory category) async {
    await controller.deleteVendorCategory(category);
  }
}
