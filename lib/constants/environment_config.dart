/// Tipos de ambiente disponíveis
enum Environment {
  development, // Local
  production, // Render
  auto, // Detecção automática
}

/// Configuração de ambiente para o app Compra Pronta
///
/// Este arquivo permite alternar facilmente entre ambientes de desenvolvimento e produção
/// sem precisar modificar o código principal.
class EnvironmentConfig {
  // ========================================
  // CONFIGURAÇÃO DE AMBIENTE
  // ========================================

  /// Ambiente atual do app
  ///
  /// Opções:
  /// - development: Usa servidor local (localhost:3000)
  /// - production: Usa servidor de produção (Render)
  /// - auto: Detecta automaticamente baseado no dispositivo
  static const Environment _currentEnvironment = Environment.production;

  /// URLs dos servidores
  static const Map<Environment, String> _serverUrls = {
    Environment.development:
        'http://10.0.2.2:3000', // IP especial para emulador Android
    Environment.production: 'https://backend-compra-pronta.onrender.com',
  };

  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================

  /// Retorna a URL base do servidor baseada no ambiente atual
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return _getDevelopmentUrl();
      case Environment.production:
        return _serverUrls[Environment.production]!;
      case Environment.auto:
        return _isEmulator()
            ? _getDevelopmentUrl()
            : _serverUrls[Environment.production]!;
    }
  }

  /// Retorna a URL de desenvolvimento baseada na plataforma
  static String _getDevelopmentUrl() {
    // Para emulador Android, usar 10.0.2.2
    // Para iOS Simulator, usar localhost
    // Para dispositivo real, usar IP da máquina
    return 'http://10.0.2.2:3000'; // IP especial para emulador Android
  }

  /// Retorna o nome do ambiente atual
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Desenvolvimento Local';
      case Environment.production:
        return 'Produção (Render)';
      case Environment.auto:
        return _isEmulator() ? 'Auto (Local)' : 'Auto (Produção)';
    }
  }

  /// Retorna se está em modo de desenvolvimento
  static bool get isDevelopment => baseUrl.contains('localhost');

  /// Retorna se está em modo de produção
  static bool get isProduction => baseUrl.contains('onrender.com');

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Detecta se está rodando no emulador
  ///
  /// Por enquanto, sempre retorna true para desenvolvimento
  /// Em produção, você pode implementar uma detecção mais sofisticada
  static bool _isEmulator() {
    // TODO: Implementar detecção real de emulador
    // Por exemplo:
    // - Verificar IP do dispositivo
    // - Verificar Build.FINGERPRINT no Android
    // - Verificar se está no simulador iOS

    // Por enquanto, sempre assume emulador para desenvolvimento
    return true;
  }

  // ========================================
  // CONFIGURAÇÃO RÁPIDA
  // ========================================

  /// Para alternar rapidamente entre ambientes, mude a linha abaixo:
  ///
  /// Exemplos:
  /// - static const Environment _currentEnvironment = Environment.development;  // Força local
  /// - static const Environment _currentEnvironment = Environment.production; // Força produção
  /// - static const Environment _currentEnvironment = Environment.auto;        // Detecção automática (padrão)
}
