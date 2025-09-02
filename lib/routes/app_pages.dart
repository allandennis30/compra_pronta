import 'package:get/get.dart';
import '../modules/auth/pages/login_page.dart';
import '../modules/auth/pages/signup_page.dart';
import '../modules/cliente/pages/cliente_main_page.dart';
import '../modules/cliente/pages/product_detail_page.dart';
import '../modules/cliente/pages/checkout_page.dart';
import '../modules/cliente/pages/order_success_page.dart';
import '../modules/vendedor/pages/vendor_dashboard_page.dart';
import '../modules/vendedor/pages/vendor_product_list_page.dart';
import '../modules/vendedor/pages/vendor_product_form_page.dart';
import '../modules/vendedor/pages/vendor_order_list_page.dart';
import '../modules/vendedor/pages/vendor_order_detail_page.dart';
import '../modules/vendedor/pages/vendor_scan_page.dart';
import '../modules/vendedor/pages/vendedor_settings_page.dart';
import '../modules/vendedor/pages/order_builder_page.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../core/bindings/cliente_binding.dart';
import '../core/bindings/vendedor_binding.dart';
import '../modules/cliente/bindings/product_detail_binding.dart';
import '../modules/cliente/bindings/checkout_binding.dart';
import '../modules/vendedor/bindings/vendedor_settings_binding.dart';
import '../modules/vendedor/bindings/vendedor_product_list_binding.dart';
import '../modules/vendedor/bindings/vendedor_product_form_binding.dart';
import '../modules/vendedor/bindings/vendedor_order_detail_binding.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

abstract class Routes {
  static const login = '/login';
  static const signup = '/signup';
  static const clienteMain = '/cliente';
  static const clienteDetalhe = '/cliente/produto';
  static const clienteCheckout = '/cliente/checkout';
  static const clienteOrderSuccess = '/cliente/order-success';
  static const vendorDashboard = '/vendor/dashboard';
  static const vendorProdutos = '/vendor/produtos';
  static const vendorForm = '/vendor/produto_form';
  static const vendorPedidos = '/vendor/pedidos';
  static const vendorPedidoDetalhe = '/vendor/pedido';
  static const vendorScan = '/vendor/scan';
  static const vendorConfig = '/vendor/config';
  static const vendorOrderBuilder = '/vendor/order-builder';
}

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => SignupPage(),
      binding: AuthBinding(),
    ),
    // Cliente - Página principal com navegação interna
    GetPage(
      name: Routes.clienteMain,
      page: () => ClienteMainPage(),
      binding: ClienteBinding(),
    ),
    // Rotas específicas do cliente que ainda precisam de navegação separada
    GetPage(
      name: Routes.clienteDetalhe,
      page: () => ProductDetailPage(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: Routes.clienteCheckout,
      page: () => CheckoutPage(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: Routes.clienteOrderSuccess,
      page: () => OrderSuccessPage(),
      binding: ClienteBinding(),
    ),
    // Vendedor
    GetPage(
      name: Routes.vendorDashboard,
      page: () => VendorDashboardPage(),
      binding: VendedorBinding(),
    ),
    GetPage(
      name: Routes.vendorProdutos,
      page: () => VendorProductListPage(),
      binding: VendedorProductListBinding(),
    ),
    GetPage(
      name: Routes.vendorForm,
      page: () => VendorProductFormPage(),
      binding: VendedorProductFormBinding(),
    ),
    GetPage(
      name: Routes.vendorPedidos,
      page: () => VendorOrderListPage(),
      binding: VendedorBinding(),
    ),
    GetPage(
      name: Routes.vendorPedidoDetalhe,
      page: () => VendorOrderDetailPage(),
      binding: VendedorOrderDetailBinding(),
    ),
    GetPage(
      name: '/vendor/pedido/:orderId',
      page: () => VendorOrderDetailPage(),
      binding: VendedorOrderDetailBinding(),
    ),
    GetPage(
      name: Routes.vendorScan,
      page: () => VendorScanPage(),
      binding: VendedorBinding(),
    ),
    GetPage(
      name: Routes.vendorConfig,
      page: () => VendedorSettingsPage(),
      binding: VendedorSettingsBinding(),
    ),
    GetPage(
      name: Routes.vendorOrderBuilder,
      page: () => OrderBuilderPage(),
      binding: VendedorBinding(),
    ),
  ];
}
