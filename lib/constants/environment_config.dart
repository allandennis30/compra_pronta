import 'dart:io';
import 'package:flutter/foundation.dart';

/// Tipos de ambiente disponíveis
enum Environment {
  development, // Local
  production, // Render
  auto, // Detecção automática
}

/// Configuração de ambiente para o app Compra Pronta
///
/// Este arquivo está configurado para usar o servidor local em modo debug
/// para desenvolvimento mais rápido e eficiente.
class EnvironmentConfig {
  // ========================================
  // CONFIGURAÇÃO DE AMBIENTE
  // ========================================

  /// Ambiente atual do app
  ///
  /// Configurado para usar desenvolvimento local
  /// para conectar ao servidor local na porta 3000
  static const Environment _currentEnvironment = Environment.production;

  /// URLs dos servidores
  static const Map<Environment, String> _serverUrls = {
    //  Environment.development: 'http://192.168.3.43:3000', // IP da máquina
    Environment.production: 'https://backend-compra-pronta.onrender.com',
  };

  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================

  /// Retorna a URL base do servidor baseada no ambiente atual
  static String get baseUrl {
    if (_currentEnvironment == Environment.development) {
      return _getDevelopmentUrl();
    }
    return _serverUrls[_currentEnvironment]!;
  }

  /// Retorna a URL de desenvolvimento baseada na plataforma
  static String _getDevelopmentUrl() {
    // Detectar plataforma para usar a URL correta
    if (_isAndroidEmulator()) {
      return 'http://192.168.3.43:3000'; // IP da máquina para Android
    } else {
      return 'http://localhost:3000'; // iOS Simulator ou dispositivo real
    }
  }

  /// Retorna o nome do ambiente atual
  static String get environmentName {
    if (_currentEnvironment == Environment.development) {
      return 'Desenvolvimento Local (${_isAndroidEmulator() ? "Android Emulator" : "iOS/Real"})';
    }
    return 'Produção (Render)';
  }

  /// Retorna se está em modo de desenvolvimento
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  /// Retorna se está em modo de produção
  static bool get isProduction => _currentEnvironment == Environment.production;

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Detecta se está rodando no emulador Android
  ///
  /// Para desenvolvimento local - detecta Android vs iOS
  static bool _isAndroidEmulator() {
    try {
      // Verificar se está rodando no Android
      if (Platform.isAndroid) {
        // Em desenvolvimento, assumir que é emulador Android
        // Em produção, isso seria detectado dinamicamente
        return true;
      } else if (Platform.isIOS) {
        // iOS Simulator ou dispositivo real
        return false;
      } else {
        // Web ou desktop - usar localhost
        return false;
      }
    } catch (e) {
      // Em caso de erro, assumir Android emulador para desenvolvimento
      return true;
    }
  }

  // ========================================
  // CONFIGURAÇÃO RÁPIDA
  // ========================================

  /// Configuração para desenvolvimento local
  ///
  /// Para voltar à produção, mude a linha abaixo:
  /// static const Environment _currentEnvironment = Environment.production;
  ///
  /// Desenvolvimento local:
  /// - Android Emulator: http://192.168.3.43:3000
  /// - iOS Simulator: http://localhost:3000
  /// - Dispositivo Real: http://192.168.3.43:3000
}
