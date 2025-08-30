# Autenticação Automática - Compra Pronta

## 🎯 Visão Geral

O app agora possui um sistema de autenticação automática que verifica e renova tokens JWT automaticamente na inicialização, garantindo que o usuário sempre tenha uma sessão válida.

## 🔄 Como Funciona

### **1. Inicialização do App**
```dart
// Em lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Hive.initFlutter();
  runApp(const MyApp());
}
```

### **2. AuthController.onInit()**
```dart
@override
void onInit() {
  super.onInit();
  _isLoading.value = true;
  _autoAuthenticate(); // ← Autenticação automática
}
```

### **3. Fluxo de Autenticação Automática**
```
App Inicia
    ↓
AuthController.onInit()
    ↓
_autoAuthenticate()
    ↓
Verificar se tem token salvo
    ↓
Se tem token → Verificar validade
    ↓
Token válido → Carregar usuário
Token inválido → Tentar renovar
    ↓
Se renovou → Carregar usuário
Se não renovou → Fazer logout
```

## 📱 Interface do Usuário

### **Tela de Carregamento:**
- **CircularProgressIndicator** com mensagem
- **"Verificando autenticação..."**
- **"Carregando dados do usuário"**

### **Redirecionamento Automático:**
- **Token válido**: Redireciona para dashboard
- **Token inválido**: Redireciona para login
- **Sem token**: Redireciona para login

## 🔧 Métodos Implementados

### **AuthController:**
```dart
/// Autenticação automática na inicialização
void _autoAuthenticate()

/// Verifica se o token atual é válido
Future<bool> _verifyTokenValidity()

/// Tenta renovar o token atual
Future<void> _refreshToken()

/// Verifica e renova o token automaticamente
Future<bool> verifyAndRefreshToken()

/// Força a renovação do token
Future<void> forceTokenRefresh()
```

### **AuthRepository:**
```dart
/// Salva o token JWT no storage
Future<void> saveToken(String token)

/// Obtém o token JWT salvo no storage
Future<String?> getToken()

/// Verifica se o usuário está autenticado
Future<bool> isAuthenticated()
```

## 🌐 Endpoints Utilizados

### **Verificação de Token:**
```
POST /api/auth/verify
Authorization: Bearer <token>
```

### **Renovação de Token:**
```
POST /api/auth/refresh
Authorization: Bearer <token>
```

## 📊 Logs de Sistema

### **Inicialização:**
```
🔄 Iniciando autenticação automática...
🔑 Token encontrado, verificando validade...
✅ Token válido, carregando usuário...
✅ Usuário carregado: Nome do Usuário
```

### **Token Expirado:**
```
⚠️ Token expirado, tentando renovar...
🔄 Tentando renovar token...
✅ Token renovado com sucesso
✅ Usuário carregado: Nome do Usuário
```

### **Erro na Renovação:**
```
⚠️ Não foi possível renovar o token
❌ Erro ao renovar token
```

## 🚀 Benefícios

### ✅ **Para o Usuário:**
- **Zero interrupções**: App sempre funciona
- **Sessão persistente**: Não precisa fazer login toda vez
- **Experiência fluida**: Transição automática entre telas

### ✅ **Para o Desenvolvedor:**
- **Código limpo**: Lógica centralizada
- **Fácil debug**: Logs detalhados
- **Manutenção simples**: Um lugar para mudanças

### ✅ **Para a Segurança:**
- **Tokens sempre válidos**: Verificação automática
- **Renovação transparente**: Usuário não percebe
- **Logout automático**: Limpeza de dados corrompidos

## 🔍 Debug e Troubleshooting

### **Verificar Logs:**
```dart
// No console do Flutter
flutter logs
```

### **Verificar Token Manualmente:**
```dart
final authController = Get.find<AuthController>();
final token = await authController.getAuthToken();
print('Token: $token');
```

### **Forçar Renovação:**
```dart
final authController = Get.find<AuthController>();
await authController.forceTokenRefresh();
```

### **Verificar Autenticação:**
```dart
final authController = Get.find<AuthController>();
final isAuth = await authController.checkAuthentication();
print('Autenticado: $isAuth');
```

## 📋 Checklist de Teste

- [ ] App inicia com tela de carregamento
- [ ] Mensagem "Verificando autenticação..." aparece
- [ ] Token válido redireciona para dashboard
- [ ] Token expirado é renovado automaticamente
- [ ] Token inválido redireciona para login
- [ ] Logs mostram o processo completo
- [ ] Usuário não precisa fazer login manualmente

## 🎯 Casos de Uso

### **1. Primeira Abertura:**
- Usuário não autenticado
- Redireciona para tela de login
- Após login, token é salvo

### **2. Reabertura com Token Válido:**
- Token é verificado automaticamente
- Usuário é carregado do storage
- Redireciona para dashboard

### **3. Reabertura com Token Expirado:**
- Token é detectado como inválido
- Sistema tenta renovar automaticamente
- Se renovar, carrega usuário
- Se não renovar, faz logout

### **4. Token Corrompido:**
- Erro na verificação
- Sistema limpa dados automaticamente
- Redireciona para login

## 🚨 Troubleshooting

### **Problema: App fica na tela de carregamento**
**Solução:** Verificar logs para identificar onde está travando

### **Problema: Token não é renovado**
**Solução:** Verificar se o endpoint `/api/auth/refresh` está funcionando

### **Problema: Usuário sempre vai para login**
**Solução:** Verificar se o token está sendo salvo corretamente no storage

### **Problema: Erro 401 persistente**
**Solução:** Usar `forceTokenRefresh()` para forçar renovação

## 📚 Arquivos Relacionados

- `lib/modules/auth/controllers/auth_controller.dart` - Controller principal
- `lib/modules/auth/repositories/auth_repository.dart` - Repository de autenticação
- `lib/main.dart` - Inicialização do app
- `lib/constants/app_constants.dart` - Endpoints da API
- `lib/constants/environment_config.dart` - Configuração de ambiente
