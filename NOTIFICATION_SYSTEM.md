# Sistema de Notificações - Mercax

Sistema completo de notificações push e locais para monitoramento de novos pedidos no aplicativo Mercax.

## 📋 Funcionalidades Implementadas

### ✅ Serviços Criados

1. **NotificationService** - Gerencia notificações locais e push
2. **AudioService** - Reproduz sinais sonoros para alertas
3. **FirebaseService** - Configura Firebase Cloud Messaging
4. **BackgroundService** - Monitora novos pedidos em background
5. **OrderNotificationService** - Integra todos os serviços
6. **NotificationTestService** - Testa o funcionamento do sistema

### ✅ Configurações

- **Firebase** configurado para Android e iOS
- **Dependências** adicionadas no pubspec.yaml
- **Permissões** configuradas nos manifestos
- **Assets de áudio** preparados

## 🚀 Como Usar

### 1. Inicialização

```dart
// No main.dart ou onde configurar os bindings
import 'lib/core/bindings/notification_binding.dart';

// Registrar o binding
Get.put(NotificationBinding());

// Inicializar serviços
await NotificationBinding.initializeServices();
```

### 2. Iniciar Monitoramento

```dart
// Iniciar monitoramento de novos pedidos
await NotificationBinding.startOrderMonitoring();
```

### 3. Parar Monitoramento

```dart
// Parar monitoramento
await NotificationBinding.stopOrderMonitoring();
```

### 4. Testes

```dart
// Executar todos os testes
await NotificationBinding.runNotificationTests();

// Teste rápido
await NotificationBinding.quickNotificationTest();
```

## 🔧 Configuração Manual

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<!-- Permissões -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Serviços -->
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### iOS (ios/Runner/Info.plist)

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 📱 Fluxo de Funcionamento

1. **Inicialização**: Todos os serviços são configurados
2. **Monitoramento**: BackgroundService verifica novos pedidos periodicamente
3. **Detecção**: Quando um novo pedido é encontrado:
   - Notificação local é exibida
   - Som de alerta é reproduzido
   - Dados são processados
4. **Firebase**: Mensagens push são recebidas e processadas
5. **Integração**: VendorOrderRepository fornece dados dos pedidos

## 🧪 Testes Disponíveis

### Teste Completo
- Inicialização de serviços
- Notificação local
- Reprodução de áudio
- Token Firebase
- Simulação de novo pedido
- Serviço de background

### Teste Rápido
- Notificação simples
- Som de alerta

## 📂 Estrutura de Arquivos

```
lib/core/services/
├── notification_service.dart      # Notificações locais e push
├── audio_service.dart             # Reprodução de sons
├── firebase_service.dart          # Firebase Cloud Messaging
├── background_service.dart        # Monitoramento em background
├── order_notification_service.dart # Integração de serviços
└── notification_test_service.dart  # Testes do sistema

lib/core/bindings/
└── notification_binding.dart      # Configuração de dependências

assets/sounds/                     # Arquivos de áudio
android/app/google-services.json   # Configuração Firebase Android
ios/Runner/GoogleService-Info.plist # Configuração Firebase iOS
```

## ⚠️ Observações Importantes

1. **Permissões**: O usuário deve conceder permissões de notificação
2. **Firebase**: Tokens FCM podem não funcionar em emuladores
3. **Áudio**: Sons podem não reproduzir em alguns emuladores
4. **Background**: Monitoramento depende das configurações do sistema
5. **Testes**: Execute em dispositivos reais para melhor experiência

## 🔍 Troubleshooting

### Notificações não aparecem
- Verificar permissões do app
- Confirmar configuração do Firebase
- Testar em dispositivo real

### Som não reproduz
- Verificar volume do dispositivo
- Testar em dispositivo real
- Verificar arquivos em assets/sounds/

### Background não funciona
- Verificar configurações de bateria
- Permitir execução em background
- Testar WorkManager no Android

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar logs do console
2. Executar testes de diagnóstico
3. Consultar documentação do Firebase
4. Testar em dispositivo real

---

**Sistema implementado seguindo boas práticas de Flutter e padrões de arquitetura limpa.**