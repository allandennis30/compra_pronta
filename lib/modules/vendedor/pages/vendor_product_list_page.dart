import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_product_list_controller.dart';
import 'vendor_product_form_page.dart';
import '../bindings/vendor_product_form_binding.dart';

class VendorProductListPage extends GetView<VendorProductListController> {
  const VendorProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtro de produtos
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar busca de produtos
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return _buildEmptyState();
        }

        return _buildProductList();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToProductForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão + para adicionar um produto',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToProductForm(),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Produto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                product.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            title: Text(product.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'R\$ ${product.price.toStringAsFixed(2)} | Estoque: ${product.stock}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  product.isAvailable ? Icons.circle : Icons.circle_outlined,
                  color: product.isAvailable ? Colors.green : Colors.grey,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  product.isAvailable ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: product.isAvailable ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _navigateToProductForm(product: product),
                ),
              ],
            ),
            onTap: () => _navigateToProductForm(product: product),
          ),
        );
      },
    );
  }

  void _navigateToProductForm({dynamic product}) async {
    final result = await Get.to(
      () => const VendorProductFormPage(),
      binding: VendorProductFormBinding(),
      arguments: product,
    );

    if (result == true) {
      controller.loadProducts();
    }
  }
}
