import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../widgets/empty_cart_widget.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary_widget.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          Obx(() => controller.isEmpty
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.showClearCartDialog(context),
                  tooltip: 'Limpar carrinho',
                )),
        ],
      ),
      body: _body,
    );
  }

  Widget get _body => Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.isEmpty) {
          return const EmptyCartWidget();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;

            if (isDesktop) {
              return _desktopLayout;
            } else {
              return _mobileTabletLayout;
            }
          },
        );
      });

  Widget get _desktopLayout => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _cartItemsList,
          ),
          const SizedBox(width: 16),
          const SizedBox(
            width: 300,
            child: CartSummaryWidget(isDesktop: true),
          ),
        ],
      );

  Widget get _mobileTabletLayout => Column(
        children: [
          Expanded(
            child: _cartItemsList,
          ),
          const CartSummaryWidget(isDesktop: false),
        ],
      );

  Widget get _cartItemsList => LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;
          final isTablet =
              constraints.maxWidth > 600 && constraints.maxWidth <= 900;
          final isDesktop = constraints.maxWidth > 900;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return CartItemWidget(
                item: item,
                isMobile: isMobile,
                isTablet: isTablet,
                isDesktop: isDesktop,
              );
            },
          );
        },
      );
}
