import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/product_category_filter.dart';
import '../widgets/product_active_filters_indicator.dart';
import '../widgets/product_filters_panel.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_pagination_info.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/logo.png',
            height: 48,
            width: 160,
            fit: BoxFit.fill,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Column(
        children: [
          ProductSearchBar(),
          ProductCategoryFilter(),
          ProductActiveFiltersIndicator(),
          ProductFiltersPanel(),
          Expanded(
            child: ProductGrid(),
          ),
          ProductPaginationInfo(),
        ],
      ),
    );
  }
}
