/// Configurações para integração com Play Store API
/// 
/// Este arquivo contém as configurações necessárias para verificar
/// atualizações do app na Google Play Store.
class PlayStoreConfig {
  /// Package name do seu app na Play Store
  /// Deve ser o mesmo definido no android/app/build.gradle
  static const String packageName = 'com.mercax.app';
  
  /// URL base da sua API que consulta a Play Console API
  /// Deixe vazio se não estiver usando este método
  static const String apiBaseUrl = '';
  
  /// Token de autenticação para sua API (se necessário)
  /// NUNCA commite tokens reais no código!
  /// Use variáveis de ambiente ou Firebase Remote Config
  static const String apiToken = '';
  
  /// Timeout para requisições HTTP (em segundos)
  static const int requestTimeout = 10;
  
  /// Intervalo de cache para verificações (em horas)
  /// Evita fazer muitas requisições desnecessárias
  static const int cacheTimeoutHours = 1;
  
  /// User-Agent para web scraping da Play Store
  static const String userAgent = 
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
  
  /// Regex patterns para extrair versão da página da Play Store
  static const List<String> versionPatterns = [
    r'\[\[\["([0-9]+\.[0-9]+\.[0-9]+)"\]\]\]',
    r'Versão atual[\s\S]*?([0-9]+\.[0-9]+\.[0-9]+)',
    r'Current Version[\s\S]*?([0-9]+\.[0-9]+\.[0-9]+)',
    r'"softwareVersion":"([0-9]+\.[0-9]+\.[0-9]+)"',
  ];
}

/// Documentação dos métodos de verificação de atualização:
/// 
/// MÉTODO 1 - Web Scraping da Play Store:
/// Prós:
/// - Simples de implementar
/// - Não requer configuração de backend
/// - Funciona imediatamente
/// 
/// Contras:
/// - Menos confiável (Google pode mudar a estrutura da página)
/// - Pode ser bloqueado por rate limiting
/// - Não é oficialmente suportado
/// 
/// MÉTODO 2 - API própria + Play Console API:
/// Prós:
/// - Mais confiável e estável
/// - Oficialmente suportado pelo Google
/// - Permite mais controle e funcionalidades
/// 
/// Contras:
/// - Requer configuração de backend
/// - Mais complexo de implementar
/// - Requer credenciais da Google Play Console API
/// 
/// CONFIGURAÇÃO DO MÉTODO 2:
/// 
/// 1. Acesse o Google Cloud Console
/// 2. Crie um projeto ou use um existente
/// 3. Ative a Google Play Android Publisher API
/// 4. Crie credenciais de Service Account
/// 5. Baixe o arquivo JSON das credenciais
/// 6. Configure seu backend para usar essas credenciais
/// 7. Implemente endpoint que consulta a API:
///    GET /app/version/{packageName}
/// 
/// Exemplo de resposta da sua API:
/// {
///   "version": "1.2.3",
///   "versionCode": 123,
///   "releaseNotes": "Bug fixes and improvements",
///   "updatePriority": "medium"
/// }