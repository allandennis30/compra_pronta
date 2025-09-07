import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/logger.dart';
import 'play_store_config.dart';

class AppUpdateService extends GetxService {
  static AppUpdateService get to => Get.find();
  
  // Versão atual do app
  String _currentVersion = '';
  String get currentVersion => _currentVersion;
  
  // Versão mais recente disponível
  String _latestVersion = '';
  String get latestVersion => _latestVersion;
  
  // Configurações da Play Store API
  String get playStoreUrl => 'https://play.google.com/store/apps/details?id=${PlayStoreConfig.packageName}';
  
  // Cache da última verificação
  DateTime? _lastCheckTime;
  static const Duration _cacheTimeout = Duration(hours: PlayStoreConfig.cacheTimeoutHours);
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadCurrentVersion();
  }
  
  /// Carrega a versão atual do app
  Future<void> _loadCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
      AppLogger.info('📱 [UPDATE] Versão atual do app: $_currentVersion');
    } catch (e) {
      AppLogger.error('❌ [UPDATE] Erro ao obter versão atual', e);
    }
  }
  
  /// Verifica se há atualizações disponíveis
  Future<bool> checkForUpdates() async {
    try {
      AppLogger.info('🔍 [UPDATE] Verificando atualizações...');
      
      // Simula verificação de versão remota
      // Em produção, isso seria uma chamada para sua API ou Firebase Remote Config
      await _fetchLatestVersion();
      
      if (_latestVersion.isNotEmpty && _currentVersion.isNotEmpty) {
        final hasUpdate = _compareVersions(_currentVersion, _latestVersion);
        AppLogger.info('📋 [UPDATE] Versão atual: $_currentVersion, Última: $_latestVersion, Tem atualização: $hasUpdate');
        return hasUpdate;
      }
      
      return false;
    } catch (e) {
      AppLogger.error('❌ [UPDATE] Erro ao verificar atualizações', e);
      return false;
    }
  }
  
  /// Busca a versão mais recente da Play Store
  Future<void> _fetchLatestVersion() async {
    try {
      // Verifica cache
      if (_lastCheckTime != null && 
          DateTime.now().difference(_lastCheckTime!) < _cacheTimeout &&
          _latestVersion.isNotEmpty) {
        AppLogger.info('📋 [UPDATE] Usando versão em cache: $_latestVersion');
        return;
      }
      
      // Método 1: Scraping da página da Play Store (mais simples, mas menos confiável)
      await _fetchVersionFromPlayStorePage();
      
      // Método 2: Usar sua própria API que consulta a Play Console API
      // await _fetchVersionFromAPI();
      
      _lastCheckTime = DateTime.now();
      
    } catch (e) {
      AppLogger.error('❌ [UPDATE] Erro ao buscar versão mais recente', e);
      _latestVersion = '';
    }
  }
  
  /// Método 1: Extrai versão da página da Play Store (web scraping)
  Future<void> _fetchVersionFromPlayStorePage() async {
    try {
      // ignore: prefer_const_declarations
      final url = 'https://play.google.com/store/apps/details?id=${PlayStoreConfig.packageName}&hl=pt_BR';
        const headers = {
          'User-Agent': PlayStoreConfig.userAgent,
        };
        
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(const Duration(seconds: PlayStoreConfig.requestTimeout));
      
      if (response.statusCode == 200) {
        final html = response.body;
        
        // Tenta diferentes padrões de regex para encontrar a versão
         bool versionFound = false;
         
         for (final pattern in PlayStoreConfig.versionPatterns) {
           final regex = RegExp(pattern);
           final match = regex.firstMatch(html);
           
           if (match != null && match.group(1) != null) {
             _latestVersion = match.group(1)!;
             AppLogger.info('📋 [UPDATE] Versão encontrada na Play Store: $_latestVersion (padrão: $pattern)');
             versionFound = true;
             break;
           }
         }
         
         if (!versionFound) {
           AppLogger.warning('⚠️ [UPDATE] Não foi possível extrair versão da Play Store');
           _latestVersion = _currentVersion; // Assume que não há atualização
         }
      } else {
        AppLogger.error('❌ [UPDATE] Erro HTTP ${response.statusCode} ao acessar Play Store');
        _latestVersion = _currentVersion;
      }
    } catch (e) {
      AppLogger.error('❌ [UPDATE] Erro ao fazer scraping da Play Store', e);
      _latestVersion = _currentVersion;
    }
  }
  
  /// Método 2: Consulta sua própria API que usa Play Console API
   /// Este método requer configuração de backend com Google Play Console API
   /// Descomente a linha no _fetchLatestVersion() para usar este método
   // ignore: unused_element
   Future<void> _fetchVersionFromAPI() async {
    try {
      // Verifica se a API está configurada
       if (PlayStoreConfig.apiBaseUrl.isEmpty) {
         AppLogger.warning('⚠️ [UPDATE] API não configurada, usando versão atual');
         _latestVersion = _currentVersion;
         return;
       }
       
       final headers = <String, String>{
         'Content-Type': 'application/json',
       };
       
       // Adiciona token de autenticação se configurado
       if (PlayStoreConfig.apiToken.isNotEmpty) {
         headers['Authorization'] = 'Bearer ${PlayStoreConfig.apiToken}';
       }
       
       final response = await http.get(
         Uri.parse('${PlayStoreConfig.apiBaseUrl}/app/version/${PlayStoreConfig.packageName}'),
         headers: headers,
       ).timeout(const Duration(seconds: PlayStoreConfig.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestVersion = data['version'] ?? _currentVersion;
        AppLogger.info('📋 [UPDATE] Versão obtida da API: $_latestVersion');
      } else {
        AppLogger.error('❌ [UPDATE] Erro HTTP ${response.statusCode} na API');
        _latestVersion = _currentVersion;
      }
    } catch (e) {
      AppLogger.error('❌ [UPDATE] Erro ao consultar API', e);
      _latestVersion = _currentVersion;
    }
  }
  
  /// Compara duas versões no formato x.y.z
  /// Retorna true se a versão remota for maior que a atual
  bool _compareVersions(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();
      
      // Garante que ambas as listas tenham o mesmo tamanho
      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (latestParts.length < 3) {
        latestParts.add(0);
      }
      
      // Compara major.minor.patch
      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) {
          return true; // Versão mais recente disponível
        } else if (latestParts[i] < currentParts[i]) {
          return false; // Versão atual é mais recente
        }
      }
      
      return false; // Versões são iguais
    } catch (e) {
      AppLogger.error('❌ [UPDATE] Erro ao comparar versões', e);
      return false;
    }
  }
  
  /// Força verificação de atualização (para testes)
  Future<bool> forceUpdateCheck() async {
    _latestVersion = '999.999.999'; // Força uma versão maior
    return true;
  }
  
  /// Reseta o estado para não mostrar atualização
  void resetUpdateState() {
    _latestVersion = _currentVersion;
  }
}