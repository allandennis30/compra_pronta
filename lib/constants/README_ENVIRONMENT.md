# Configuração de Ambiente - Compra Pronta

## 🎯 Visão Geral

O app agora possui detecção automática de ambiente, permitindo alternar facilmente entre desenvolvimento local e produção sem modificar o código principal.

## 🔧 Como Funciona

### 1. **Detecção Automática (Padrão)**
```dart
// Em lib/constants/environment_config.dart
static const Environment _currentEnvironment = Environment.auto;
```

- **Emulador/Simulador**: Usa `http://localhost:3000`
- **Dispositivo Real**: Usa `https://backend-compra-pronta.onrender.com`

### 2. **Forçar Ambiente Específico**

#### **Forçar Desenvolvimento Local:**
```dart
// Em lib/constants/environment_config.dart
static const Environment _currentEnvironment = Environment.development;
```

#### **Forçar Produção:**
```dart
// Em lib/constants/environment_config.dart
static const Environment _currentEnvironment = Environment.production;
```

## 📱 Uso no App

### **Verificar Ambiente Atual:**
```dart
import 'package:compra_pronta/constants/app_constants.dart';

// Nome do ambiente
String env = AppConstants.environmentName;
print('Ambiente: $env'); // "Auto (Local)" ou "Auto (Produção)"

// Verificar tipo
if (AppConstants.isDevelopment) {
  print('Rodando em desenvolvimento local');
} else if (AppConstants.isProduction) {
  print('Rodando em produção');
}
```

### **URLs Automáticas:**
```dart
// As URLs são configuradas automaticamente
String loginUrl = AppConstants.loginEndpoint;
String productsUrl = AppConstants.createProductEndpoint;

// Não precisa mais se preocupar com localhost vs onrender.com
```

## 🚀 Benefícios

### ✅ **Desenvolvimento:**
- Emulador usa automaticamente servidor local
- Não precisa alterar código para testar
- Desenvolvimento mais rápido

### ✅ **Produção:**
- Dispositivos reais usam servidor de produção
- Deploy automático sem configuração manual
- Zero downtime para mudanças de ambiente

### ✅ **Manutenção:**
- Uma linha para alternar ambiente
- Configuração centralizada
- Fácil debug e troubleshooting

## 🔍 Detecção de Emulador

### **Atual (Simples):**
```dart
static bool _isEmulator() {
  return true; // Sempre assume emulador para desenvolvimento
}
```

## 🌐 IPs Especiais para Emuladores

### **Android Emulator:**
- **IP**: `10.0.2.2` (mapeia para localhost da máquina host)
- **Porta**: `3000` (sua aplicação Node.js)
- **URL completa**: `http://10.0.2.2:3000`

### **iOS Simulator:**
- **IP**: `localhost` ou `127.0.0.1`
- **Porta**: `3000`
- **URL completa**: `http://localhost:3000`

### **Dispositivo Real:**
- **IP**: IP da sua máquina na rede local (ex: `192.168.1.100`)
- **Porta**: `3000`
- **URL completa**: `http://192.168.1.100:3000`

### **Futuro (Avançado):**
```dart
static bool _isEmulator() {
  // Verificar IP do dispositivo
  // Verificar Build.FINGERPRINT no Android
  // Verificar simulador iOS
  // Verificar variáveis de ambiente
  return _detectEmulator();
}
```

## 📋 Checklist de Configuração

- [ ] Ambiente configurado em `environment_config.dart`
- [ ] AppConstants importando EnvironmentConfig
- [ ] Teste em emulador (deve usar localhost:3000)
- [ ] Teste em dispositivo real (deve usar onrender.com)
- [ ] Verificar se as URLs estão corretas

## 🎯 Exemplos de Uso

### **Desenvolvimento Local:**
```dart
// Em environment_config.dart
static const Environment _currentEnvironment = Environment.development;

// Resultado: http://10.0.2.2:3000/api/auth/login (emulador Android)
// Resultado: http://localhost:3000/api/auth/login (iOS Simulator)
```

### **Produção:**
```dart
// Em environment_config.dart
static const Environment _currentEnvironment = Environment.production;

// Resultado: https://backend-compra-pronta.onrender.com/api/auth/login
```

### **Auto (Recomendado):**
```dart
// Em environment_config.dart
static const Environment _currentEnvironment = Environment.auto;

// Resultado: Detecta automaticamente baseado no dispositivo
```

## 🚨 Troubleshooting

### **Problema: App não conecta ao servidor local**
**Solução:** Verificar se `_currentEnvironment = Environment.development`

### **Problema: App não conecta ao servidor de produção**
**Solução:** Verificar se `_currentEnvironment = Environment.production`

### **Problema: Detecção automática não funciona**
**Solução:** Verificar se `_isEmulator()` está retornando o valor correto

## 📚 Arquivos Relacionados

- `lib/constants/app_constants.dart` - URLs da API
- `lib/constants/environment_config.dart` - Configuração de ambiente
- `lib/constants/README_ENVIRONMENT.md` - Esta documentação
