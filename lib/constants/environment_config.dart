enum Environment {
  development,
  production,
  auto,
}

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.production;

  static const Map<Environment, String> _serverUrls = {
    Environment.development: 'https://backend-compra-pronta.onrender.com',
    Environment.production: 'https://backend-compra-pronta.onrender.com',
  };

  static String get baseUrl {
    return _serverUrls[_currentEnvironment]!;
  }

  static String get environmentName {
    return 'Produção (Render)';
  }

  static bool get isDevelopment => false;

  static bool get isProduction => true;
}
