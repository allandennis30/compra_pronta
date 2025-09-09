import '../utils/logger.dart';

enum Environment {
  development,
  production,
  auto,
}

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.production;
  static String? _cachedBaseUrl;
  static bool _isRenderAvailable = true;

  static const Map<Environment, String> _serverUrls = {
    Environment.development: 'https://backend-compra-pronta.onrender.com', // Sempre usar Render
    Environment.production: 'https://backend-compra-pronta.onrender.com',
  };



  /// Retorna a URL base sempre do Render
  static Future<String> get baseUrl async {
    // Sempre retorna o endpoint do Render
    _cachedBaseUrl = _serverUrls[Environment.production]!;
    AppLogger.info('🌐 Usando servidor Render: $_cachedBaseUrl');
    return _cachedBaseUrl!;
  }

  /// Força uma nova verificação do servidor
  static void resetCache() {
    _cachedBaseUrl = null;
    _isRenderAvailable = true;
  }

  static String get environmentName {
    if (_currentEnvironment == Environment.development) {
      return 'Desenvolvimento (Local)';
    }
    if (_currentEnvironment == Environment.production) {
      return 'Produção (Render)';
    }
    return _isRenderAvailable ? 'Auto (Render)' : 'Auto (Local)';
  }

  static bool get isDevelopment => _currentEnvironment == Environment.development;

  static bool get isProduction => _currentEnvironment == Environment.production;

  static bool get isAuto => _currentEnvironment == Environment.auto;
}
