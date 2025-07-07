import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/vendor_product_form_controller.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/barcode_scanner.dart';

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
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              FocusScope.of(context).unfocus();
              controller.saveProduct();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildForm();
      }),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePicker(),
          const SizedBox(height: 24),
          _buildProductName(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPrice()),
              const SizedBox(width: 16),
              Expanded(child: _buildStock()),
            ],
          ),
          const SizedBox(height: 16),
          _buildBarcodeField(),
          const SizedBox(height: 16),
          _buildCategoryDropdown(),
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
    return TextFormField(
      controller: controller.nameController,
      decoration: const InputDecoration(
        labelText: 'Nome do Produto',
        hintText: 'Ex: Arroz Integral 1kg',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shopping_bag),
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLength: 100,
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
          },
        ));
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      value: controller.selectedCategory.value.isEmpty
          ? null
          : controller.selectedCategory.value,
      items: controller.categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.onCategorySelected(value);
        }
      },
      hint: const Text('Selecione uma categoria'),
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
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => controller.saveProduct(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save),
            const SizedBox(width: 8),
            Text(
              controller.isEditing.value
                  ? 'Atualizar Produto'
                  : 'Cadastrar Produto',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
