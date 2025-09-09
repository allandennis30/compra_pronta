import 'package:get/get.dart';
import '../modules/auth/pages/login_page.dart';
import '../modules/auth/pages/signup_page.dart';
import '../modules/auth/pages/forgot_password_page.dart';
import '../modules/cliente/pages/cliente_main_page.dart';
import '../modules/cliente/pages/delivery_main_page.dart';
import '../modules/cliente/pages/qr_scanner_page.dart';
import '../modules/cliente/pages/qr_display_page.dart';
import '../modules/cliente/pages/delivery_confirmation_page.dart';
import '../modules/cliente/pages/delivery_stats_page.dart';
import '../modules/cliente/pages/product_detail_page.dart';
import '../modules/cliente/pages/checkout_page.dart';
import '../modules/cliente/pages/order_success_page.dart';
import '../modules/vendedor/pages/vendedor_dashboard_page.dart';
import '../modules/vendedor/pages/vendor_product_list_page.dart';
import '../modules/vendedor/pages/vendor_product_form_page.dart';
import '../modules/vendedor/pages/vendor_order_list_page.dart';
import '../modules/vendedor/pages/vendor_order_detail_page.dart';
import '../modules/vendedor/pages/vendor_scan_page.dart';
import '../modules/vendedor/pages/vendedor_settings_page.dart';
import '../modules/vendedor/pages/order_builder_page.dart';
import '../modules/vendedor/pages/delivery_management_page.dart';
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
  static const forgotPassword = '/forgot-password';
  static const clienteMain = '/cliente';
  static const deliveryMain = '/delivery';
  static const qrScanner = '/qr-scanner';
  static const deliveryConfirmation = '/delivery-confirmation';
  static const deliveryStats = '/delivery-stats';
  static const qrDisplay = '/qr-display';
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
  static const vendorDeliveryManagement = '/vendor/delivery-management';
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
      page: () => const SignupPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    // Cliente - Página principal com navegação interna
    GetPage(
      name: Routes.clienteMain,
      page: () => const ClienteMainPage(),
      binding: ClienteBinding(),
    ),
    // Delivery - Página principal do entregador
    GetPage(
      name: Routes.deliveryMain,
      page: () => const DeliveryMainPage(),
      binding: ClienteBinding(),
    ),
    // QR Scanner
    GetPage(
      name: Routes.qrScanner,
      page: () => const QRScannerPage(scanType: 'register'),
      binding: ClienteBinding(),
    ),
    GetPage(
        name: Routes.deliveryConfirmation,
        page: () => const DeliveryConfirmationPage(),
        binding: ClienteBinding(),
      ),
      GetPage(
        name: Routes.deliveryStats,
        page: () => const DeliveryStatsPage(),
        binding: ClienteBinding(),
      ),
    // QR Display
    GetPage(
      name: Routes.qrDisplay,
      page: () => QRDisplayPage(),
      binding: ClienteBinding(),
    ),
    // Rotas específicas do cliente que ainda precisam de navegação separada
    GetPage(
      name: Routes.clienteDetalhe,
      page: () => const ProductDetailPage(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: Routes.clienteCheckout,
      page: () => const CheckoutPage(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: Routes.clienteOrderSuccess,
      page: () => const OrderSuccessPage(),
      binding: ClienteBinding(),
    ),
    // Vendedor
    GetPage(
      name: Routes.vendorDashboard,
      page: () => VendedorDashboardPage(),
      binding: VendedorBinding(),
    ),
    GetPage(
      name: Routes.vendorProdutos,
      page: () => const VendorProductListPage(),
      binding: VendedorProductListBinding(),
    ),
    GetPage(
      name: Routes.vendorForm,
      page: () => const VendorProductFormPage(),
      binding: VendedorProductFormBinding(),
    ),
    GetPage(
      name: Routes.vendorPedidos,
      page: () => const VendorOrderListPage(),
      binding: VendedorBinding(),
    ),
    GetPage(
      name: Routes.vendorPedidoDetalhe,
      page: () => const VendorOrderDetailPage(),
      binding: VendedorOrderDetailBinding(),
    ),
    GetPage(
      name: '/vendor/pedido/:orderId',
      page: () => const VendorOrderDetailPage(),
      binding: VendedorOrderDetailBinding(),
    ),
    GetPage(
      name: Routes.vendorScan,
      page: () => VendorScanPage(),
      binding: VendedorBinding(),
    ),
    GetPage(
      name: Routes.vendorConfig,
      page: () => const VendedorSettingsPage(),
      binding: VendedorSettingsBinding(),
    ),
    GetPage(
      name: Routes.vendorOrderBuilder,
      page: () => const OrderBuilderPage(),
      binding: VendedorBinding(),
    ),
    GetPage(
      name: Routes.vendorDeliveryManagement,
      page: () => const DeliveryManagementPage(),
      binding: VendedorBinding(),
    ),
  ];
}
