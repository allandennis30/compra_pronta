# 🚀 Configuração para Desenvolvimento Local - Compra Pronta

## ✅ **Status Atual**

O app Flutter está configurado para se comunicar com o backend local em modo debug.

### **🔧 Configurações Realizadas:**

1. ✅ **Backend rodando**: `http://localhost:3000`
2. ✅ **App Flutter configurado** para usar servidor local
3. ✅ **Detecção automática de plataforma** (Android/iOS)
4. ✅ **URLs configuradas** para cada plataforma

## 📱 **Configuração do App Flutter**

### **Ambiente Atual:**
- **Modo**: Desenvolvimento Local
- **Detecção**: Automática por plataforma
- **Status**: ✅ **CONFIGURADO**

### **URLs por Plataforma:**

#### **🤖 Android Emulator:**
- **IP**: `192.168.3.43` (IP real da máquina)
- **Porta**: `3000`
- **URL**: `http://192.168.3.43:3000`

#### **🍎 iOS Simulator:**
- **IP**: `localhost` ou `127.0.0.1`
- **Porta**: `3000`
- **URL**: `http://localhost:3000`

#### **📱 Dispositivo Real:**
- **IP**: `192.168.3.43` (IP da máquina na rede local)
- **Porta**: `3000`
- **URL**: `http://192.168.3.43:3000`

## 🔧 **Arquivos Configurados**

### **1. Environment Config (`lib/constants/environment_config.dart`)**
```dart
static const Environment _currentEnvironment = Environment.development;

static String get baseUrl {
  if (_currentEnvironment == Environment.development) {
    return _getDevelopmentUrl();
  }
  return _serverUrls[_currentEnvironment]!;
}

static String _getDevelopmentUrl() {
  if (_isAndroidEmulator()) {
    return 'http://192.168.3.43:3000'; // IP da máquina para Android
  } else {
    return 'http://localhost:3000'; // iOS Simulator ou dispositivo real
  }
}
```

### **2. App Constants (`lib/constants/app_constants.dart`)**
```dart
// API Configuration - Usando EnvironmentConfig para detecção automática
static String get baseUrl => EnvironmentConfig.baseUrl;
static const String apiVersion = '/api';
static const String authEndpoint = '/auth';

// API Endpoints - Usando getters para detecção automática de ambiente
static String get loginEndpoint => '$baseUrl$apiVersion$authEndpoint/login';
static String get productsEndpoint => '$baseUrl$apiVersion/products';
// ... outros endpoints
```

### **3. Repositories Atualizados**
- ✅ **AuthRepository**: Usa `AppConstants.loginEndpoint`
- ✅ **ProductApiRepository**: Usa `AppConstants.productsEndpoint`
- ✅ **VendedorProductApiRepository**: Usa `AppConstants.createProductEndpoint`

## 🚀 **Como Usar**

### **1. Iniciar o Backend:**
```bash
cd backend
npm run dev
```

### **2. Verificar se o backend está funcionando:**
```bash
curl http://localhost:3000/health
```

### **3. Executar o App Flutter:**
```bash
flutter run
```

### **4. Testar as APIs:**
- **Login**: `http://192.168.3.43:3000/api/auth/login` (Android)
- **Login**: `http://localhost:3000/api/auth/login` (iOS)
- **Produtos**: `http://192.168.3.43:3000/api/products` (Android)
- **Produtos**: `http://localhost:3000/api/products` (iOS)

## 🧪 **Credenciais de Teste**

### **Backend Local:**
```
Cliente:
- Email: teste@teste.com
- Senha: teste123

Vendedor:
- Email: teste@teste.com
- Senha: teste123
```

## 🔍 **Verificações**

### **1. Verificar Ambiente no App:**
```dart
import 'package:compra_pronta/constants/app_constants.dart';

print('Ambiente: ${AppConstants.environmentName}');
print('URL Base: ${AppConstants.baseUrl}');
print('Login URL: ${AppConstants.loginEndpoint}');
```

### **2. Verificar Logs do Backend:**
```bash
# No terminal do backend
npm run dev
# Verificar logs de conexão
```

### **3. Testar Conexão:**
```bash
# Testar health check
curl http://localhost:3000/health

# Testar login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "teste@teste.com", "senha": "teste123"}'
```

## 🚨 **Troubleshooting**

### **Problema: App não conecta ao servidor local**

#### **Solução 1: Verificar se o backend está rodando**
```bash
lsof -i :3000
# Deve mostrar o processo Node.js
```

#### **Solução 2: Verificar URL no app**
```dart
print('URL Base: ${AppConstants.baseUrl}');
// Deve mostrar: http://192.168.3.43:3000 (Android) ou http://localhost:3000 (iOS)
```

#### **Solução 3: Verificar firewall/antivírus**
- Desabilitar temporariamente firewall
- Verificar se a porta 3000 não está bloqueada

#### **Solução 4: Usar IP da máquina**
Para dispositivos reais, usar o IP da sua máquina:
```dart
// Em environment_config.dart
static String _getDevelopmentUrl() {
  return 'http://192.168.3.43:3000'; // Seu IP local
}
```

### **Problema: Erro de CORS**

#### **Solução: Verificar configuração CORS no backend**
```javascript
// Em backend/server.js
app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);
    callback(null, true); // Permitir todas as origens em desenvolvimento
  },
  credentials: true
}));
```

## 🔄 **Alternar para Produção**

Para voltar ao servidor de produção (Render):

### **1. Alterar Environment Config:**
```dart
// Em lib/constants/environment_config.dart
static const Environment _currentEnvironment = Environment.production;
```

### **2. Verificar URLs:**
```dart
print('URL Base: ${AppConstants.baseUrl}');
// Deve mostrar: https://backend-compra-pronta.onrender.com
```

## 📋 **Checklist de Configuração**

- [ ] Backend rodando na porta 3000
- [ ] Environment configurado para development
- [ ] URLs detectadas automaticamente por plataforma
- [ ] Repositories usando AppConstants
- [ ] Teste de login funcionando
- [ ] Teste de produtos funcionando
- [ ] Logs do backend mostrando conexões

## 🎯 **Benefícios da Configuração Local**

### ✅ **Desenvolvimento Mais Rápido:**
- Sem latência de rede
- Debug mais fácil
- Logs em tempo real

### ✅ **Independência da Internet:**
- Funciona offline
- Não depende do Render
- Desenvolvimento estável

### ✅ **Controle Total:**
- Modificar backend facilmente
- Testar mudanças rapidamente
- Debug completo

---

**Nota**: Esta configuração é ideal para desenvolvimento. Para produção, use sempre o servidor Render.
