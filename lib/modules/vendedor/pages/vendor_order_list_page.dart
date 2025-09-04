import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_order_list_controller.dart';
import '../widgets/vendedor_layout.dart';
import '../../../core/themes/app_colors.dart';

class VendorOrderListPage extends GetView<VendorOrderListController> {
  const VendorOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VendedorLayout(
      currentIndex: 2,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: _buildAppBar(context),
        body: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return _buildErrorState(context);
          }

          return RefreshIndicator(
            onRefresh: controller.refreshOrders,
            child: Column(
              children: [
                _buildFilters(context),
                Expanded(
                  child: controller.orders.isEmpty
                      ? _buildEmptyState(context)
                      : _buildOrdersList(context),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Pedidos',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      actions: [
        Obx(() => IconButton(
              icon: Icon(
                controller.isSearching ? Icons.close : Icons.search,
              ),
              onPressed: controller.toggleSearch,
            )),
      ],
      bottom: controller.isSearching
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: controller.searchOrders,
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID ou status...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant(context),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: controller.availableStatuses.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(controller.getStatusDisplayName(status)),
                    selected: controller.selectedStatus == status,
                    onSelected: (_) => controller.filterByStatus(status),
                    selectedColor:
                        controller.getStatusColor(status).withOpacity(0.2),
                    checkmarkColor: controller.getStatusColor(status),
                    labelStyle: TextStyle(
                      color: controller.selectedStatus == status
                          ? controller.getStatusColor(status)
                          : AppColors.onSurface(context),
                      fontWeight: controller.selectedStatus == status
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.orders.length,
      itemBuilder: (context, index) {
        final order = controller.orders[index];
        return _buildOrderCard(order, context);
      },
    );
  }

  Widget _buildOrderCard(order, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.navigateToOrderDetail(order.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName != null &&
                                  order.clientName!.isNotEmpty
                              ? 'Pedido do ${order.clientName}'
                              : 'Pedido #${order.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.formatDateTime(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.getStatusDisplayName(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.iconSecondary(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${order.deliveryAddress.street}, ${order.deliveryAddress.number}${order.deliveryAddress.complement != null && order.deliveryAddress.complement!.isNotEmpty ? ', ${order.deliveryAddress.complement}' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurface(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: R\$ ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.iconSecondary(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.iconSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum pedido encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Os pedidos aparecerão aqui quando\nforem realizados pelos clientes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant(context),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant(context),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
