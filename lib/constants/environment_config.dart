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
  /// Configurado para usar desenvolvimento local
  /// para conectar ao servidor local na porta 3000
  static const Environment _currentEnvironment = Environment.development;

  /// URLs dos servidores
  static const Map<Environment, String> _serverUrls = {
    Environment.development: 'http://10.0.2.2:3000', // Emulador Android
    Environment.production: 'https://backend-compra-pronta.onrender.com',
  };

  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================

  /// Retorna a URL base do servidor baseada no ambiente atual
  static String get baseUrl {
    // Usar desenvolvimento local (localhost:3000)
    return _serverUrls[Environment.development]!;
  }

  /// Retorna a URL de desenvolvimento baseada na plataforma
  static String _getDevelopmentUrl() {
    // Não usado - sempre em produção
    return 'http://localhost:3000';
  }

  /// Retorna o nome do ambiente atual
  static String get environmentName {
    // Desenvolvimento local
    return 'Desenvolvimento Local';
  }

  /// Retorna se está em modo de desenvolvimento
  static bool get isDevelopment => true; // Desenvolvimento local

  /// Retorna se está em modo de produção
  static bool get isProduction => false; // Desenvolvimento local

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Detecta se está rodando no emulador
  ///
  /// Para desenvolvimento local
  static bool _isEmulator() {
    return true; // Desenvolvimento local
  }

  // ========================================
  // CONFIGURAÇÃO RÁPIDA
  // ========================================

  /// Configuração para desenvolvimento local
  ///
  /// Para voltar à produção, mude a linha abaixo:
  /// static const Environment _currentEnvironment = Environment.production;
  ///
  /// Desenvolvimento local: http://localhost:3000
}
