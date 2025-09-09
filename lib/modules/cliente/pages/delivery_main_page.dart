import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/delivery_controller.dart';
import 'qr_scanner_page.dart';
import 'cliente_main_page.dart';
import '../../auth/controllers/auth_controller.dart';

class DeliveryMainPage extends StatefulWidget {
  const DeliveryMainPage({Key? key}) : super(key: key);

  @override
  State<DeliveryMainPage> createState() => _DeliveryMainPageState();
}

class _DeliveryMainPageState extends State<DeliveryMainPage> with WidgetsBindingObserver {
  final DeliveryController _deliveryController = Get.find<DeliveryController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Atualizar dados quando o app volta ao primeiro plano
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Entregador'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Get.toNamed('/delivery-stats'),
            tooltip: 'Estatísticas',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Obx(() {
        if (_deliveryController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra do Mercax
                _buildMercaxBar(),
                const SizedBox(height: 12),
                
                // Banner de modo de uso
                _buildModeBanner(),
                const SizedBox(height: 16),

                // Estatísticas
                _buildStatsSection(),
                const SizedBox(height: 24),

                // Lojas disponíveis
                _buildStoresSection(),
                const SizedBox(height: 24),

                // Pedidos para entrega
                _buildOrdersSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Atualizar todos os dados da página
  Future<void> _refreshData() async {
    try {
      await Future.wait([
        _deliveryController.loadDeliveryStores(),
        _deliveryController.loadDeliveryOrders(),
        _deliveryController.loadDeliveryStats(),
      ]);
    } catch (e) {
      print('Erro ao atualizar dados: $e');
    }
  }

  Widget _buildMercaxBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 28,
            width: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Text(
            'Mercax',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delivery_dining,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modo Entregador Ativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gerencie entregas e visualize pedidos disponíveis',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _switchToClientMode,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Cliente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(() {
      final stats = _deliveryController.deliveryStats.value;
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estatísticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Entregas Hoje',
                      stats?['deliveries_today']?.toString() ?? '0',
                      Icons.local_shipping,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Entregas',
                      stats?['total_deliveries']?.toString() ?? '0',
                      Icons.assignment_turned_in,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Ganhos Hoje',
                      'R\$ ${stats?['earnings_today']?.toStringAsFixed(2) ?? '0.00'}',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Ganhos Total',
                      'R\$ ${stats?['total_earnings']?.toStringAsFixed(2) ?? '0.00'}',
                      Icons.account_balance_wallet,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoresSection() {
    return Obx(() {
      final stores = _deliveryController.deliveryStores;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lojas Disponíveis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (stores.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma loja disponível',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...stores.map((store) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(store['name'] ?? 'Loja'),
                    subtitle: Text(store['address'] ?? 'Endereço não informado'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ativo',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )),
        ],
      );
    });
  }

  Widget _buildOrdersSection() {
    return Obx(() {
      final orders = _deliveryController.deliveryOrders;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pedidos para Entrega',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  Get.to(() => const QRScannerPage(
                        scanType: 'confirm',
                      ));
                },
                tooltip: 'Escanear QR Code',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.delivery_dining_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhum pedido para entrega',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...orders.map((order) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order['status']),
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('Pedido #${order['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cliente: ${order['client_name'] ?? 'N/A'}'),
                        Text('Valor: R\$ ${order['total']?.toStringAsFixed(2) ?? '0.00'}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(order['status']),
                        style: TextStyle(
                          color: _getStatusColor(order['status']),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Endereço de Entrega:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(order['delivery_address'] ?? 'Endereço não informado'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      // Navegar para scanner QR e aguardar resultado
                                      final result = await Get.to(() => const QRScannerPage(
                                        scanType: 'confirm',
                                      ));
                                      
                                      // Se houve sucesso na confirmação, atualizar dados
                                      if (result == true) {
                                        _refreshData();
                                      }
                                    },
                                    icon: const Icon(Icons.qr_code_scanner),
                                    label: const Text('Confirmar Entrega'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showUpdateStatusDialog(order['id'].toString());
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Atualizar Status'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      );
    });
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'in_transit':
        return 'Em Trânsito';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }

  void _showUpdateStatusDialog(String orderId) {
    final statuses = [
      {'value': 'pending', 'label': 'Pendente'},
      {'value': 'in_transit', 'label': 'Em Trânsito'},
      {'value': 'delivered', 'label': 'Entregue'},
    ];

    Get.dialog(
      AlertDialog(
        title: const Text('Atualizar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return ListTile(
              title: Text(status['label']!),
              onTap: () async {
                Get.back();
                await _deliveryController.updateOrderStatus(
                  orderId,
                  status['value']!,
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _switchToClientMode() async {
    final authController = Get.find<AuthController>();
    await authController.saveUserMode('cliente');
    
    Get.offAll(
      () => const ClienteMainPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }
}