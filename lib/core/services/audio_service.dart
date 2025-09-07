import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

/// Serviço responsável por reproduzir sinais sonoros
class AudioService extends GetxService {
  static AudioService get to => Get.find();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Configurações de áudio
  static const double _defaultVolume = 0.8;
  static const int _notificationRepeatCount = 3;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeAudio();
  }
  
  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
  
  /// Inicializa o serviço de áudio
  Future<void> _initializeAudio() async {
    try {
      await _audioPlayer.setVolume(_defaultVolume);
      AppLogger.info('✅ [AUDIO] Serviço de áudio inicializado');
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao inicializar serviço de áudio', e);
    }
  }
  
  /// Reproduz som de notificação para novo pedido
  Future<void> playNewOrderSound() async {
    try {
      // Usar som do sistema para notificação
      await _playSystemNotificationSound();
      
      AppLogger.info('🔊 [AUDIO] Som de novo pedido reproduzido');
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao reproduzir som de novo pedido', e);
    }
  }
  
  /// Reproduz som de notificação do sistema
  Future<void> _playSystemNotificationSound() async {
    try {
      // Reproduzir som de notificação múltiplas vezes para chamar atenção
      for (int i = 0; i < _notificationRepeatCount; i++) {
        await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
        
        // Aguardar um pouco entre as reproduções
        if (i < _notificationRepeatCount - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      // Se não conseguir reproduzir o arquivo, usar som alternativo
      await _playAlternativeSound();
    }
  }
  
  /// Reproduz som alternativo usando frequências
  Future<void> _playAlternativeSound() async {
    try {
      // Criar um som de alerta simples usando tons
      for (int i = 0; i < _notificationRepeatCount; i++) {
        // Tom alto
        await _playTone(800, 200);
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Tom baixo
        await _playTone(600, 200);
        
        if (i < _notificationRepeatCount - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao reproduzir som alternativo', e);
    }
  }
  
  /// Reproduz um tom específico (simulado)
  Future<void> _playTone(int frequency, int duration) async {
    try {
      // Como não temos geração de tom nativa, vamos usar um som curto
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
      await Future.delayed(Duration(milliseconds: duration));
    } catch (e) {
      // Se falhar, apenas aguardar o tempo
      await Future.delayed(Duration(milliseconds: duration));
    }
  }
  
  /// Reproduz som de confirmação
  Future<void> playConfirmationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/confirmation.mp3'));
      AppLogger.info('✅ [AUDIO] Som de confirmação reproduzido');
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao reproduzir som de confirmação', e);
    }
  }
  
  /// Reproduz som de erro
  Future<void> playErrorSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
      AppLogger.info('❌ [AUDIO] Som de erro reproduzido');
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao reproduzir som de erro', e);
    }
  }
  
  /// Para a reprodução atual
  Future<void> stopCurrentSound() async {
    try {
      await _audioPlayer.stop();
      AppLogger.info('⏹️ [AUDIO] Reprodução parada');
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao parar reprodução', e);
    }
  }
  
  /// Define o volume do áudio
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      AppLogger.info('🔊 [AUDIO] Volume definido para: ${(clampedVolume * 100).toInt()}%');
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao definir volume', e);
    }
  }
  
  /// Verifica se o áudio está sendo reproduzido
  bool get isPlaying {
    return _audioPlayer.state == PlayerState.playing;
  }
  
  /// Reproduz som personalizado
  Future<void> playCustomSound(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
      AppLogger.info('🎵 [AUDIO] Som personalizado reproduzido: $assetPath');
    } catch (e) {
      AppLogger.error('❌ [AUDIO] Erro ao reproduzir som personalizado', e);
    }
  }
}