import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/entregador_dashboard_controller.dart';
import '../models/delivery_stats_model.dart';
import '../widgets/availability_toggle_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/delivery_stats_widget.dart';

class EntregadorDashboardPage extends GetView<EntregadorDashboardController> {
  const EntregadorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com saudação e disponibilidade
                _buildHeader(),
                const SizedBox(height: 24),

                // Toggle de disponibilidade
                AvailabilityToggleWidget(
                  isAvailable: controller.isAvailable.value,
                  isLoading: controller.isLoading.value,
                  onToggle: controller.toggleAvailability,
                  statusMessage: controller.statusMessage,
                ),
                const SizedBox(height: 24),

                // Estatísticas
                Obx(() => DeliveryStatsWidget(
                   stats: controller.stats.value ?? DeliveryStatsModel(
                     deliveriesToday: 0,
                     totalDeliveries: 0,
                     completedDeliveries: 0,
                     pendingDeliveries: 0,
                     cancelledDeliveries: 0,
                     totalEarnings: 0.0,
                     averageRating: 0.0,
                     totalRatings: 0,
                     deliveriesThisWeek: 0,
                     deliveriesThisMonth: 0,
                   ),
                   isLoading: controller.isLoading.value,
                 )),
                const SizedBox(height: 24),

                // Entregas ativas
                _buildActiveDeliveries(),
                const SizedBox(height: 24),

                // Ações rápidas
                const QuickActionsWidget(),
                const SizedBox(height: 24),

                // Resumo do dia
                _buildDailySummary(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[600]!,
              Colors.blue[400]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: profile.profileImageUrl != null
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child: profile.profileImageUrl == null
                  ? Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${profile.name}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.vehicleDescription,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow[300],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.rating.toStringAsFixed(1)} (${profile.totalRatings} avaliações)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: profile.isAvailable ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.isAvailable ? 'Disponível' : 'Indisponível',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActiveDeliveries() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Entregas Ativas',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: controller.goToAvailableDeliveries,
                  child: Text('Ver Todas'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.activeDeliveries.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma entrega ativa',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.activeDeliveries.length.clamp(0, 3),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final delivery = controller.activeDeliveries[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.local_shipping,
                        color: Get.theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text('Pedido #${delivery.id}'),
                    subtitle: Text('Cliente: Cliente ${delivery.id}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => controller.goToDeliveryDetail(delivery),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do Dia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final stats = controller.stats.value;
            if (stats == null) return const SizedBox.shrink();

            return Column(
              children: [
                _buildSummaryRow(
                  'Entregas Realizadas',
                  stats.deliveriesToday.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Taxa de Sucesso',
                  '${stats.successRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Ganho Médio',
                  'R\$ ${stats.averageEarningsPerDelivery.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Status',
                  stats.isActive ? 'Ativo' : 'Inativo',
                  stats.isActive ? Icons.check : Icons.pause,
                  stats.isActive ? Colors.green : Colors.grey,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}