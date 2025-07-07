import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_metrics_controller.dart';

class VendorDashboardPage extends StatelessWidget {
  final VendorMetricsController controller = Get.put(VendorMetricsController());

  VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/vendor/config'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricsCards(),
            const SizedBox(height: 24),
            _buildRecentOrders(),
            const SizedBox(height: 24),
            _buildTopProducts(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMetricsCards() {
    return Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'Vendas Totais',
              'R\$ ${controller.totalSales.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildMetricCard(
              'Pedidos',
              '${controller.totalOrders}',
              Icons.shopping_bag,
              Colors.blue,
            ),
            _buildMetricCard(
              'Pendentes',
              '${controller.pendingOrders}',
              Icons.pending,
              Colors.orange,
            ),
            _buildMetricCard(
              'Produtos',
              '${controller.totalProducts}',
              Icons.inventory,
              Colors.purple,
            ),
          ],
        ));
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pedidos Recentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/vendor/pedidos'),
              child: const Text('Ver Todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.recentOrders.isEmpty) {
            return const Text('Nenhum pedido recente.');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentOrders.length,
            itemBuilder: (context, index) {
              final order = controller.recentOrders[index];
              return _buildOrderCard(order);
            },
          );
        }),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: controller.getStatusColor(order['status']),
          child: Text(
            order['id'].toString().split('_').last,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(order['customer']),
        subtitle: Text('R\$ ${order['total'].toStringAsFixed(2)}'),
        trailing: Chip(
          label: Text(
            controller.getStatusText(order['status']),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: controller.getStatusColor(order['status']),
        ),
        onTap: () => Get.toNamed('/vendor/pedido', arguments: order['id']),
      ),
    );
  }

  Widget _buildTopProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produtos Mais Vendidos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.topProducts.isEmpty) {
            return const Text('Nenhum produto vendido ainda.');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.topProducts.length,
            itemBuilder: (context, index) {
              final product = controller.topProducts[index];
              return _buildProductCard(product, index + 1);
            },
          );
        }),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            '$rank',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(product['name']),
        subtitle: Text('${product['sales']} vendas'),
        trailing: Text(
          'R\$ ${product['revenue'].toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Produtos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scanner',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 1:
            Get.toNamed('/vendor/produtos');
            break;
          case 2:
            Get.toNamed('/vendor/pedidos');
            break;
          case 3:
            Get.toNamed('/vendor/scan');
            break;
        }
      },
    );
  }
}
