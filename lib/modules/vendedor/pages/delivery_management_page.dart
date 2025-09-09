import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/delivery_management_controller.dart';

class DeliveryManagementPage extends StatelessWidget {
  const DeliveryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeliveryManagementController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Entregadores'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadDeliveryUsers(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDeliveryUsers(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção QR Code
                _buildQRCodeSection(controller),
                const SizedBox(height: 24),
                
                // Seção Lista de Entregadores
                _buildDeliveryUsersSection(controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQRCodeSection(DeliveryManagementController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'QR Code para Registro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => IconButton(
                  icon: Icon(
                    controller.showQRCode.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.toggleQRCode,
                )),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Mostre este QR Code para novos entregadores escanearem e se cadastrarem.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.showQRCode.value) {
                return Center(
                  child: controller.buildQRCodeWidget(),
                );
              } else {
                return Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toque no ícone do olho para mostrar o QR Code',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryUsersSection(DeliveryManagementController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Entregadores Cadastrados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Chip(
                  label: Text(
                    '${controller.deliveryUsers.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.deliveryUsers.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum entregador cadastrado',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mostre o QR Code acima para entregadores se cadastrarem',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.deliveryUsers.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final deliveryUser = controller.deliveryUsers[index];
                  return _buildDeliveryUserTile(controller, deliveryUser);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryUserTile(
    DeliveryManagementController controller,
    Map<String, dynamic> deliveryUser,
  ) {
    final name = deliveryUser['name'] ?? deliveryUser['nome'] ?? 'Nome não informado';
    final email = deliveryUser['email'] ?? 'Email não informado';
    final phone = deliveryUser['phone'] ?? deliveryUser['telefone'] ?? 'Telefone não informado';
    final userId = deliveryUser['id']?.toString() ?? '';
    final createdAt = deliveryUser['created_at'] ?? deliveryUser['criado_em'];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2E7D32),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.email,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.phone,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Cadastrado em: ${_formatDate(createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'remove') {
            controller.showRemoveConfirmationDialog(userId, name);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'remove',
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Remover',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Data não informada';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Data inválida';
    }
  }
}