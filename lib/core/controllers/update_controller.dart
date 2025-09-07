import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_update_service.dart';
import '../utils/logger.dart';
import '../widgets/update_dialog.dart';

class UpdateController extends GetxController {
  static UpdateController get to => Get.find();
  
  final AppUpdateService _updateService = Get.find<AppUpdateService>();
  
  // Estado reativo
  final RxBool _isCheckingUpdate = false.obs;
  final RxBool _hasUpdateAvailable = false.obs;
  final RxBool _showUpdateDialog = false.obs;
  
  // Getters
  bool get isCheckingUpdate => _isCheckingUpdate.value;
  bool get hasUpdateAvailable => _hasUpdateAvailable.value;
  bool get showUpdateDialog => _showUpdateDialog.value;
  
  String get currentVersion => _updateService.currentVersion;
  String get latestVersion => _updateService.latestVersion;
  
  @override
  void onInit() {
    super.onInit();
    // Verifica atualizações automaticamente ao inicializar
    _checkForUpdatesOnInit();
  }
  
  /// Verifica atualizações na inicialização (com delay)
  Future<void> _checkForUpdatesOnInit() async {
    try {
      // Aguarda um pouco para não interferir com o carregamento inicial
      await Future.delayed(const Duration(seconds: 3));
      await checkForUpdates();
    } catch (e) {
      AppLogger.error('❌ [UPDATE_CONTROLLER] Erro na verificação inicial', e);
    }
  }
  
  /// Verifica se há atualizações disponíveis
  Future<void> checkForUpdates({bool showLoading = false}) async {
    try {
      if (showLoading) {
        _isCheckingUpdate.value = true;
      }
      
      AppLogger.info('🔍 [UPDATE_CONTROLLER] Iniciando verificação de atualizações...');
      
      final hasUpdate = await _updateService.checkForUpdates();
      
      _hasUpdateAvailable.value = hasUpdate;
      
      if (hasUpdate) {
          AppLogger.info('🆕 [UPDATE_CONTROLLER] Atualização disponível!');
          _showUpdateDialog.value = true;
          _showUpdateDialogUI(currentVersion, latestVersion);
        } else {
        AppLogger.info('✅ [UPDATE_CONTROLLER] App está atualizado');
        if (showLoading) {
          Get.snackbar('Sucesso', 'App está atualizado!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.primary, colorText: Get.theme.colorScheme.onPrimary);
        }
      }
      
    } catch (e) {
      AppLogger.error('❌ [UPDATE_CONTROLLER] Erro ao verificar atualizações', e);
      if (showLoading) {
        Get.snackbar('Erro', 'Erro ao verificar atualizações', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      }
    } finally {
      _isCheckingUpdate.value = false;
    }
  }
  
  /// Abre a Play Store para atualizar o app
  Future<void> openPlayStore() async {
    try {
      final url = _updateService.playStoreUrl;
      AppLogger.info('🏪 [UPDATE_CONTROLLER] Abrindo Play Store: $url');
      
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        // Fecha o dialog após abrir a Play Store
        dismissUpdateDialog();
        
        Get.snackbar('Info', 'Redirecionando para a Play Store...', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      } else {
        throw Exception('Não foi possível abrir a Play Store');
      }
      
    } catch (e) {
      AppLogger.error('❌ [UPDATE_CONTROLLER] Erro ao abrir Play Store', e);
      Get.snackbar('Erro', 'Erro ao abrir a Play Store', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    }
  }
  
  /// Exibe o dialog de atualização
   void _showUpdateDialogUI(String currentVersion, String latestVersion, {bool isForced = false}) {
      _showUpdateDialog.value = true;
      
      UpdateDialog.show(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        isForced: isForced,
      );
    }

  /// Fecha o dialog de atualização
  void dismissUpdateDialog() {
    _showUpdateDialog.value = false;
    AppLogger.info('❌ [UPDATE_CONTROLLER] Dialog de atualização fechado');
  }
  
  /// Força verificação de atualização (para testes)
  Future<void> forceUpdateCheck() async {
    try {
      AppLogger.info('🧪 [UPDATE_CONTROLLER] Forçando verificação de atualização...');
      
      _isCheckingUpdate.value = true;
      
      final hasUpdate = await _updateService.forceUpdateCheck();
      
      _hasUpdateAvailable.value = hasUpdate;
      _showUpdateDialog.value = hasUpdate;
      
      if (hasUpdate) {
        Get.snackbar('Info', 'Atualização forçada ativada!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      }
      
    } catch (e) {
      AppLogger.error('❌ [UPDATE_CONTROLLER] Erro ao forçar atualização', e);
      Get.snackbar('Erro', 'Erro ao forçar verificação', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
      _isCheckingUpdate.value = false;
    }
  }
  
  /// Reseta o estado de atualização
  void resetUpdateState() {
    _updateService.resetUpdateState();
    _hasUpdateAvailable.value = false;
    _showUpdateDialog.value = false;
    AppLogger.info('🔄 [UPDATE_CONTROLLER] Estado de atualização resetado');
  }
  
  /// Verifica atualizações manualmente (com feedback visual)
  Future<void> manualUpdateCheck() async {
    await checkForUpdates(showLoading: true);
  }
}