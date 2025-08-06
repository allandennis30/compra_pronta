import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/cliente/repositories/product_repository.dart';
import '../../modules/cliente/repositories/cart_repository.dart';
import '../../modules/cliente/repositories/order_repository.dart';
import '../../modules/vendedor/repositories/vendor_metrics_repository.dart';
import '../../modules/vendedor/repositories/vendedor_product_repository.dart';

/// Factory para gerenciar repositories
/// Permite trocar facilmente entre implementações mock e reais
class RepositoryFactory {
  static const bool _useMockData =
      true; // Alterar para false para usar APIs reais

  static AuthRepository createAuthRepository() {
    if (_useMockData) {
      return AuthRepositoryImpl();
    } else {
      // return AuthApiRepository(); // Implementação real da API
      return AuthRepositoryImpl(); // Fallback para mock
    }
  }

  static ProductRepository createProductRepository() {
    if (_useMockData) {
      return ProductRepositoryImpl();
    } else {
      // return ProductApiRepository(); // Implementação real da API
      return ProductRepositoryImpl(); // Fallback para mock
    }
  }

  static CartRepository createCartRepository() {
    if (_useMockData) {
      return CartRepositoryImpl();
    } else {
      // return CartApiRepository(); // Implementação real da API
      return CartRepositoryImpl(); // Fallback para mock
    }
  }

  static OrderRepository createOrderRepository() {
    if (_useMockData) {
      return OrderRepositoryImpl();
    } else {
      // return OrderApiRepository(); // Implementação real da API
      return OrderRepositoryImpl(); // Fallback para mock
    }
  }

  static VendorMetricsRepository createVendorMetricsRepository() {
    if (_useMockData) {
      return VendorMetricsRepositoryImpl();
    } else {
      // return VendorMetricsApiRepository(); // Implementação real da API
      return VendorMetricsRepositoryImpl(); // Fallback para mock
    }
  }

  static VendedorProductRepository createVendedorProductRepository() {
    if (_useMockData) {
      return VendedorProductRepositoryImpl();
    } else {
      // return VendedorProductApiRepository(); // Implementação real da API
      return VendedorProductRepositoryImpl(); // Fallback para mock
    }
  }
}

/// Configuração de ambiente
class Environment {
  static const String dev = 'development';
  static const String prod = 'production';
  static const String test = 'testing';

  static const String current = dev; // Alterar conforme ambiente

  static bool get isDevelopment => current == dev;
  static bool get isProduction => current == prod;
  static bool get isTesting => current == test;

  /// URLs das APIs por ambiente
  static String get apiBaseUrl {
    switch (current) {
      case dev:
        return 'https://dev-api.supermercado.com/v1';
      case prod:
        return 'https://api.supermercado.com/v1';
      case test:
        return 'https://test-api.supermercado.com/v1';
      default:
        return 'https://dev-api.supermercado.com/v1';
    }
  }

  /// Configurações de timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Configurações de cache
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int maxCacheSize = 100;
}
