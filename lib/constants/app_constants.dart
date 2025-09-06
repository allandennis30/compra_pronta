import 'environment_config.dart';

class AppConstants {
  // Cores
  static const int primaryColor = 0xFF2E7D32;
  static const int secondaryColor = 0xFF4CAF50;
  static const int accentColor = 0xFF8BC34A;
  static const int backgroundColor = 0xFFF5F5F5;
  static const int errorColor = 0xFFD32F2F;
  static const int warningColor = 0xFFFF9800;
  static const int successColor = 0xFF4CAF50;

  // Textos
  static const String appName = 'Compra Pronta';
  static const String appVersion = '1.0.0';

  // Status de pedidos
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusPreparing = 'preparing';
  static const String statusDelivering = 'delivering';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  // Categorias de produtos
  static const List<String> productCategories = [
    'Frutas e Verduras',
    'Carnes',
    'Laticínios',
    'Pães e Massas',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Outros'
  ];

  // Taxa de entrega base
  static const double baseDeliveryFee = 5.0;
  static const double deliveryFeePerKm = 1.0;

  // Limites
  static const int maxProductQuantity = 99;
  static const double minOrderValue = 10.0;
  static const int maxDeliveryDistance = 10; // km

  // Storage keys
  static const String userKey = 'user';
  static const String cartKey = 'cart';
  static const String ordersKey = 'orders';
  static const String productsKey = 'products';
  static const String favoritesKey = 'favorites';
  static const String tokenKey = 'auth_token';

  // API Configuration - Usando EnvironmentConfig para detecção automática
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static const String apiVersion = '/api';
  static const String authEndpoint = '/auth';

  // Informações do ambiente atual
  static String get environmentName => EnvironmentConfig.environmentName;
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;
  static bool get isProduction => EnvironmentConfig.isProduction;

  // API Endpoints - Usando getters para detecção automática de ambiente
  static String get loginEndpoint => '$baseUrl$apiVersion$authEndpoint/login';
  static String get registerEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/register/client';
  static String get registerSellerEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/register/seller';
  static String get verifyTokenEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/verify';
  static String get refreshTokenEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/refresh';
  static String get profileEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/profile';
  static String get updateProfileEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/profile';
  static String get logoutEndpoint => '$baseUrl$apiVersion$authEndpoint/logout';
  static String get usersEndpoint => '$baseUrl$apiVersion$authEndpoint/users';
  static String get forgotPasswordEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/forgot-password';
  static String get resetPasswordEndpoint =>
      '$baseUrl$apiVersion$authEndpoint/reset-password';

  // Products endpoints
  static String get productsEndpoint => '$baseUrl$apiVersion/products';
  static String get createProductEndpoint => '$baseUrl$apiVersion/products';
  static String get listProductsEndpoint => '$baseUrl$apiVersion/products';
  static String get getProductEndpoint => '$baseUrl$apiVersion/products';
  static String get updateProductEndpoint => '$baseUrl$apiVersion/products';
  static String get deleteProductEndpoint => '$baseUrl$apiVersion/products';
  static String get checkBarcodeEndpoint =>
      '$baseUrl$apiVersion/products/barcode';
  static String get publicProductsEndpoint =>
      '$baseUrl$apiVersion/products/public';
  static String get publicProductsFiltersEndpoint =>
      '$baseUrl$apiVersion/products/public/filters';
  static String get uploadImageEndpoint =>
      '$baseUrl$apiVersion/products/upload-image';

  // Credenciais de teste para o backend
  // Cliente: teste@teste.com / teste123
  // Vendedor: teste@teste.com / teste123

  // Removido: mockProducts (usar sempre backend)
}
