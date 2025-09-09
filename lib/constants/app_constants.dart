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
  static Future<String> get baseUrl => EnvironmentConfig.baseUrl;
  static const String apiVersion = '/api';
  static const String authEndpoint = '/auth';

  // Informações do ambiente atual
  static String get environmentName => EnvironmentConfig.environmentName;
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;
  static bool get isProduction => EnvironmentConfig.isProduction;
  static bool get isAuto => EnvironmentConfig.isAuto;

  // API Endpoints - Métodos assíncronos para detecção automática de ambiente
  static Future<String> get loginEndpoint async => '${await baseUrl}$apiVersion$authEndpoint/login';
  static Future<String> get registerEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/register/client';
  static Future<String> get registerSellerEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/register/seller';
  static Future<String> get verifyTokenEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/verify';
  static Future<String> get refreshTokenEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/refresh';
  static Future<String> get profileEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/profile';
  static Future<String> get updateProfileEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/profile';
  static Future<String> get logoutEndpoint async => '${await baseUrl}$apiVersion$authEndpoint/logout';
  static Future<String> get usersEndpoint async => '${await baseUrl}$apiVersion$authEndpoint/users';
  static Future<String> get forgotPasswordEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/forgot-password';
  static Future<String> get resetPasswordEndpoint async =>
      '${await baseUrl}$apiVersion$authEndpoint/reset-password';

  // Products endpoints
  static Future<String> get productsEndpoint async => '${await baseUrl}$apiVersion/products';
  static Future<String> get createProductEndpoint async => '${await baseUrl}$apiVersion/products';
  static Future<String> get listProductsEndpoint async => '${await baseUrl}$apiVersion/products';
  static Future<String> get getProductEndpoint async => '${await baseUrl}$apiVersion/products';
  static Future<String> get updateProductEndpoint async => '${await baseUrl}$apiVersion/products';
  static Future<String> get deleteProductEndpoint async => '${await baseUrl}$apiVersion/products';
  static Future<String> get checkBarcodeEndpoint async =>
      '${await baseUrl}$apiVersion/products/barcode';
  static Future<String> get publicProductsEndpoint async =>
      '${await baseUrl}$apiVersion/products/public';
  static Future<String> get publicProductsFiltersEndpoint async =>
      '${await baseUrl}$apiVersion/products/public/filters';
  static Future<String> get uploadImageEndpoint async =>
      '${await baseUrl}$apiVersion/products/upload-image';

  // Credenciais de teste para o backend
  // Cliente: teste@teste.com / teste123
  // Vendedor: teste@teste.com / teste123

  // Removido: mockProducts (usar sempre backend)
}
