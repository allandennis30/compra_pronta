/// Tipos de ambiente disponíveis
enum Environment {
  development, // Local
  production, // Render
  auto, // Detecção automática
}

/// Configuração de ambiente para o app Compra Pronta
///
/// Este arquivo está configurado para usar sempre o servidor de produção (Render)
/// para garantir funcionamento consistente em todos os dispositivos.
class EnvironmentConfig {
  // ========================================
  // CONFIGURAÇÃO DE AMBIENTE
  // ========================================

  /// Ambiente atual do app
  ///
  /// Configurado para sempre usar produção (Render)
  /// para garantir funcionamento consistente
  static const Environment _currentEnvironment = Environment.production;

  /// URLs dos servidores
  static const Map<Environment, String> _serverUrls = {
    Environment.development: 'http://localhost:3000', // Não usado
    Environment.production: 'https://backend-compra-pronta.onrender.com',
  };

  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================

  /// Retorna a URL base do servidor baseada no ambiente atual
  static String get baseUrl {
    // Sempre usar produção (Render) para garantir funcionamento
    return _serverUrls[Environment.production]!;
  }

  /// Retorna a URL de desenvolvimento baseada na plataforma
  static String _getDevelopmentUrl() {
    // Não usado - sempre em produção
    return 'http://localhost:3000';
  }

  /// Retorna o nome do ambiente atual
  static String get environmentName {
    // Sempre em produção (Render)
    return 'Produção (Render)';
  }

  /// Retorna se está em modo de desenvolvimento
  static bool get isDevelopment => false; // Sempre em produção

  /// Retorna se está em modo de produção
  static bool get isProduction => true; // Sempre em produção

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Detecta se está rodando no emulador
  ///
  /// Não usado - sempre em produção
  static bool _isEmulator() {
    return false; // Sempre em produção
  }

  // ========================================
  // CONFIGURAÇÃO RÁPIDA
  // ========================================

  /// Configuração fixa para produção
  ///
  /// Para voltar ao desenvolvimento, mude a linha abaixo:
  /// static const Environment _currentEnvironment = Environment.development;
  ///
  /// Mas lembre-se: produção garante funcionamento em todos os dispositivos!
}
